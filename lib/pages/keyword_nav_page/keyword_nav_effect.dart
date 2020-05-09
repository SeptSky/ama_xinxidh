import 'dart:convert';

import 'package:fish_redux/fish_redux.dart';

import '../../common/consts/constants.dart';
import '../../common/consts/enum_types.dart';
import '../../common/consts/keys.dart';
import '../../common/consts/param_names.dart';
import '../../common/data_access/app_def.dart';
import '../../common/data_access/webApi/info_nav_services.dart';
import '../../common/utilities/dialogs.dart';
import '../../common/utilities/environment.dart';
import '../../common/utilities/shared_util.dart';
import '../../common/utilities/tools.dart';
import '../../global_store/global_action.dart';
import '../../global_store/global_store.dart';
import '../../models/configs/topic_def.dart';
import '../../models/keywords/keyword.dart';
import '../../models/keywords/keyword_nav_env.dart';
import '../home_page/home_action.dart';
import '../info_nav_page/info_nav_action.dart';
import '../keyword_related_page/keyword_related_action.dart';
import 'keyword_item_component/keyword_action.dart';
import 'keyword_nav_action.dart';
import 'keyword_nav_state.dart';

Effect<KeywordNavPageState> buildEffect() {
  /// 建立Action名称与Action实现之间的映射关系
  /// 这里定义了首页所有操作行为的入口
  return combineEffects(<Object, Effect<KeywordNavPageState>>{
    Lifecycle.initState: _init,
    Lifecycle.dispose: _dispose,
    KeywordNavPageActionEnum.onRefreshPage: _onRefreshPage,
    KeywordNavPageActionEnum.onGetNextPageFilters: _onGetNextPageFilters,
    KeywordNavPageActionEnum.onPressFilterAction: _onPressFilterAction,
    KeywordNavPageActionEnum.onPressAlphabetAction: _onPressAlphabetAction,
    KeywordNavPageActionEnum.onUnpressParentAction: _onUnpressParentAction,
    KeywordNavPageActionEnum.onCancelFilterAction: _onCancelFilterAction,
    KeywordNavPageActionEnum.onCombineFilterAction: _onCombineFilterAction,
    KeywordNavPageActionEnum.onResetFilterAction: _onResetFilterAction,
    KeywordNavPageActionEnum.onChangeTopicDef: _onChangeTopicDef,
    KeywordNavPageActionEnum.onScrollToKeyword: _onScrollToKeyword,
    KeywordNavPageActionEnum.onShowFilters: _onShowFilters,
    KeywordNavPageActionEnum.onShowPyCodes: _onShowPyCodes,
  });
}

Future _init(Action action, Context<KeywordNavPageState> ctx) async {
  var scrollController = ctx.state.scrollController;
  scrollController.addListener(() {
    if (scrollController.position.pixels ==
        scrollController.position.minScrollExtent) {
      if (ctx.state.nextPageNo > 1) {
        // 刷新没有必要
        // _onGetFirstPageKeywords(action, ctx);
      }
    }
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      _onGetNextPageFilters(action, ctx);
    }
  });

  /// 不使用Future.Delayed方法将会抛出异常，通过Delayed可以跳过首次执行顺序
  Future.delayed(Duration.zero, () async {
    if (_isLoading(ctx.state)) return;
    _onRefreshPage(action, ctx);
  });
}

Future _dispose(Action action, Context<KeywordNavPageState> ctx) async {
  ctx.state.scrollController.dispose();
  var params = <String, dynamic>{
    ParamNames.contextParam: null,
    ParamNames.keywordSwitchParam: 2,
  };
  // 重置因为下划关闭关键词导航界面的图标状态
  ctx.broadcast(HomeActionCreator.onToggleKeywordSheet(params));
  await _saveKeywordNavEnv(ctx.state);
}

Future _onRefreshPage(Action action, Context<KeywordNavPageState> ctx) async {
  GlobalStore.store.dispatch(GlobalReducerCreator.setErrorStatusReducer(false));
  ctx.dispatch(KeywordReducerCreator.resetFilterReducer());
  var keywordMode = ctx.state.keywordMode;
  final keywordNavEnv = await _readKeywordNavEnv(ctx);
  if (keywordNavEnv != null) {
    ctx.dispatch(
        KeywordNavPageReducerCreator.resotreStateReducer(keywordNavEnv));
    keywordMode = keywordNavEnv.keywordMode;
  }
  // 使用同步状态，不要使用异步状态
  if (keywordMode) {
    _onShowFilters(action, ctx);
  } else {
    _onShowPyCodes(action, ctx);
  }
}

Future _onGetFirstPageFilters(Action action, Context<KeywordNavPageState> ctx,
    {bool forceUpdate = false}) async {
  if (_isLoading(ctx.state)) return;
  // 需要考虑重复读取的情况
  if (forceUpdate ||
      GlobalStore.hasError ||
      Tools.hasNotElements(ctx.state.filters)) {
    ctx.dispatch(KeywordNavPageReducerCreator.setIsLoadingFlagReducer(true));
    try {
      List<Keyword> keywords;
      switch (GlobalStore.sourceType) {
        case SourceType.favorite:
          keywords = await _getFiltersFavorite(ctx.state, true);
          break;
        case SourceType.history:
          keywords = await _getFiltersHistory(ctx.state, true);
          break;
        default:
          keywords = await _getFilters(ctx.state, true);
      }
      if (_isLoadingSuccess(keywords)) {
        _clearAllFiltersStatus(ctx.state);
        final filterKeywords = GlobalStore.filterKeywords;
        var newFilters =
            ctx.state.buildPressedFilterKeywordList(keywords, filterKeywords);
        var appendFilters =
            await _appendFilterKeywords(filterKeywords, newFilters);
        _resetIndex(appendFilters);
        ctx.dispatch(
            KeywordNavPageReducerCreator.initKeywordsReducer(appendFilters));
        _resetScrollController(ctx);
      }
    } finally {
      ctx.dispatch(KeywordNavPageReducerCreator.setIsLoadingFlagReducer(false));
    }
  }
}

Future<List<Keyword>> _appendFilterKeywords(
    String filterKeywords, List<Keyword> newFilters) async {
  if (filterKeywords == null || filterKeywords.length == 0) return newFilters;
  final filterKeywordArray = filterKeywords.split(',');
  for (var i = filterKeywordArray.length - 1; i >= 0; i--) {
    final filter = newFilters.firstWhere(
        (element) => element.title == filterKeywordArray[i] && element.pressed,
        orElse: () => null);
    if (filter != null) filterKeywordArray.removeAt(i);
  }
  if (filterKeywordArray.length == 0) return newFilters;
  final newFilterKeywords = filterKeywordArray.join(',');
  final appendedFilters = await InfoNavServices.getFilteredKeywordDetails(
      newFilterKeywords, Constants.cacheFlagKeyword);
  if (appendedFilters == null || appendedFilters.length == 0) return newFilters;
  appendedFilters.forEach((element) => element.pressed = true);
  appendedFilters.addAll(newFilters);
  return appendedFilters;
}

Future _onGetNextPageFilters(
    Action action, Context<KeywordNavPageState> ctx) async {
  if (_isLoading(ctx.state) || !ctx.state.keywordMode) return;
  var pressedParents = ctx.state.getPressedParentFilterList();
  if (pressedParents != null && pressedParents.length > 0) return;
  var loadedCount = ctx.state.getUnpressedPropertyFilterCount();
  if (loadedCount / Constants.filterPageSize == ctx.state.nextPageNo) {
    ctx.dispatch(KeywordNavPageReducerCreator.setIsLoadingFlagReducer(true));
    try {
      List<Keyword> keywords;
      switch (GlobalStore.sourceType) {
        case SourceType.favorite:
          keywords = await _getFiltersFavorite(ctx.state, false);
          break;
        case SourceType.history:
          keywords = await _getFiltersHistory(ctx.state, false);
          break;
        default:
          keywords = await _getFilters(ctx.state, false);
      }
      if (_isLoadingSuccess(keywords)) {
        ctx.dispatch(
            KeywordNavPageReducerCreator.setNextPageFiltersReducer(keywords));
      }
    } finally {
      ctx.dispatch(KeywordNavPageReducerCreator.setIsLoadingFlagReducer(false));
    }
  }
}

Future _onPressFilterAction(
    Action action, Context<KeywordNavPageState> ctx) async {
  final String pressedFilter = action.payload;
  final isProperty = ctx.state.isPropertyFilter(pressedFilter);
  if (isProperty == null) return;

  _triggerRelatedKeywords(pressedFilter, ctx);

  // 逻辑判断分治模式，避免复杂逻辑集中判断，也可以分享某个模块逻辑判断的结果
  var processed = false;
  processed = _pressPropertyFilter(processed, isProperty, action, ctx);
  processed = await _pressParentFilter(processed, isProperty, action, ctx);
}

Future _onPressAlphabetAction(
    Action action, Context<KeywordNavPageState> ctx) async {
  final keywordState = action.payload;
  _clearAlphabetsStatus(ctx.state);
  ctx.dispatch(KeywordReducerCreator.pressFilterReducer(keywordState.index));
}

Future _onUnpressParentAction(
    Action action, Context<KeywordNavPageState> ctx) async {
  if (_isLoading(ctx.state)) return;
  ctx.dispatch(KeywordNavPageReducerCreator.setIsLoadingFlagReducer(true));
  try {
    List<Keyword> keywords;
    switch (GlobalStore.sourceType) {
      case SourceType.favorite:
        keywords = await _getFiltersFavorite(ctx.state, true);
        break;
      case SourceType.history:
        keywords = await _getFiltersHistory(ctx.state, true);
        break;
      default:
        keywords = await _getFilters(ctx.state, true);
    }
    if (_isLoadingSuccess(keywords)) {
      ctx.dispatch(KeywordNavPageReducerCreator.initKeywordsReducer(keywords));
    }
  } finally {
    ctx.dispatch(KeywordNavPageReducerCreator.setIsLoadingFlagReducer(false));
  }
}

Future _onCancelFilterAction(
    Action action, Context<KeywordNavPageState> ctx) async {
  if (_isLoading(ctx.state)) {
    ctx.dispatch(KeywordNavPageReducerCreator.setIsLoadingFlagReducer(false));
  }
  final filterKeywords = GlobalStore.removeRelatedKeyword();
  _triggerRelatedKeywords(filterKeywords, ctx);
  _onGetFirstPageFilters(action, ctx, forceUpdate: true);
  // broadcast负责跨页面调用Effect
  ctx.broadcast(InfoNavPageActionCreator.onSetFilteredKeyword(filterKeywords));
}

Future _onCombineFilterAction(
    Action action, Context<KeywordNavPageState> ctx) async {
  final filterKeywords = GlobalStore.removeRelatedKeyword();
  _triggerRelatedKeywords(filterKeywords, ctx);
  _onGetFirstPageFilters(action, ctx, forceUpdate: true);
  // broadcast负责跨页面调用Effect
  ctx.broadcast(InfoNavPageActionCreator.onSetFilteredKeyword(filterKeywords));
}

Future _onResetFilterAction(
    Action action, Context<KeywordNavPageState> ctx) async {
  ctx.dispatch(KeywordReducerCreator.resetFilterReducer());
  if (_isLoading(ctx.state)) {
    ctx.dispatch(KeywordNavPageReducerCreator.setIsLoadingFlagReducer(false));
  }
  // broadcast负责跨页面调用Effect
  ctx.broadcast(InfoNavPageActionCreator.onSetFilteredKeyword(null));
  // 上述代码清空了筛选条件
  _onGetFirstPageFilters(action, ctx, forceUpdate: true);
}

Future _onChangeTopicDef(
    Action action, Context<KeywordNavPageState> ctx) async {
  if (GlobalStore.hasError) return;
  if (_isLoading(ctx.state)) return;
  final int topicId = action.payload;
  try {
    ctx.dispatch(KeywordReducerCreator.resetFilterReducer());
    final TopicDef topicDef = await InfoNavServices.getAppTopicFromWebApi(
        Xinxidh_App_Guid, topicId, true);
    if (topicDef != null) {
      GlobalStore.store
          .dispatch(GlobalReducerCreator.changeTopicDefReducer(topicDef));
      await _onResetFilterAction(action, ctx);
      await SharedUtil.instance.removeString(_buildKeywordNavKeyName());
    }
  } catch (err) {
    GlobalStore.store
        .dispatch(GlobalReducerCreator.setErrorStatusReducer(true));
    return;
  }
}

Future _onScrollToKeyword(
    Action action, Context<KeywordNavPageState> ctx) async {
  if (GlobalStore.hasError) return;
  if (_isLoading(ctx.state)) return;
  ctx.dispatch(KeywordActionCreator.onScrollToKeyword(action.payload));
}

Future _onShowFilters(Action action, Context<KeywordNavPageState> ctx) async {
  if (GlobalStore.hasError) return;
  if (_isLoading(ctx.state)) return;
  await _onGetFirstPageFilters(action, ctx, forceUpdate: true);
  // 确保保存最新的keywordMode状态
  _saveKeywordNavEnv(ctx.state);
}

Future _onShowPyCodes(Action action, Context<KeywordNavPageState> ctx) async {
  if (GlobalStore.hasError) return;
  if (_isLoading(ctx.state)) return;
  ctx.dispatch(KeywordNavPageReducerCreator.setIsLoadingFlagReducer(true));
  try {
    List<Keyword> keywords;
    final userName = GlobalStore.userInfo.userName;
    switch (GlobalStore.sourceType) {
      case SourceType.favorite:
        keywords = await _getAlphabetFiltersFavorite(userName);
        break;
      case SourceType.history:
        keywords = await _getAlphabetFiltersHistory(userName);
        break;
      default:
        final topicKeyword = GlobalStore.currentTopicDef.topicKeyword;
        keywords = await _getAlphabetFilters(topicKeyword);
    }
    // 确保保存最新的keywordMode状态
    _saveKeywordNavEnv(ctx.state);
    if (_isLoadingSuccess(keywords)) {
      ctx.dispatch(KeywordNavPageReducerCreator.initKeywordsReducer(keywords));
      _resetScrollController(ctx);
    }
  } finally {
    ctx.dispatch(KeywordNavPageReducerCreator.setIsLoadingFlagReducer(false));
  }
}

void _triggerRelatedKeywords(
    String filteredKeywords, Context<KeywordNavPageState> ctx) {
  final gridColCount = ctx.state.getGridColCount();
  if (gridColCount == 1) {
    ctx.broadcast(
        KeywordRelatedPageActionCreator.onPressFilterAction(filteredKeywords));
  }
}

bool _pressPropertyFilter(bool processed, bool isProperty, Action action,
    Context<KeywordNavPageState> ctx) {
  if (processed || !isProperty) return processed;

  final filterKeywords = action.payload;
  _clearOtherFiltersStatus(filterKeywords, ctx.state);
  _onGetFirstPageFilters(action, ctx, forceUpdate: true);
  // broadcast负责跨页面调用Effect
  ctx.broadcast(
      KeywordRelatedPageActionCreator.onPressFilterAction(filterKeywords));
  ctx.broadcast(InfoNavPageActionCreator.onSetFilteredKeyword(filterKeywords));

  // 返回true，意味着终止后续处理逻辑
  return true;
}

Future<bool> _pressParentFilter(bool processed, bool isProperty, Action action,
    Context<KeywordNavPageState> ctx) async {
  if (processed || isProperty) return processed;

  _getPressedParentSubFilters(action, ctx);
  // broadcast负责跨页面调用Effect
  ctx.broadcast(InfoNavPageActionCreator.onSetFilteredKeyword(
      GlobalStore.filterKeywords));

  // 返回true，意味着终止后续处理逻辑
  return true;
}

Future _getPressedParentSubFilters(
    Action action, Context<KeywordNavPageState> ctx) async {
  List<Keyword> keywords = List<Keyword>();
  String filteredKeyword = action.payload;
  var subFilters = await _getSubFilters(filteredKeyword);
  if (subFilters == null) return;
  var pressedFilters = ctx.state.getPressedPropertyFilterList();
  if (pressedFilters != null) {
    keywords.addAll(pressedFilters);
  }
  var pressedParentFilters = ctx.state.getPressedParentFilterList();
  if (pressedParentFilters != null) {
    keywords.addAll(pressedParentFilters);
  }
  if (subFilters != null) {
    keywords.addAll(subFilters);
  }
  var unpressedParentFilters = ctx.state.getUnpressedParentFilterList();
  if (unpressedParentFilters != null) {
    keywords.addAll(unpressedParentFilters);
  }
  _resetIndex(keywords);
  ctx.dispatch(KeywordNavPageReducerCreator.initKeywordsReducer(keywords));
  _resetScrollController(ctx);
}

void _resetScrollController(Context<KeywordNavPageState> ctx) {
  try {
    final scrollController = ctx.state.scrollController;
    scrollController.jumpTo(scrollController.position.minScrollExtent);
  } catch (err) {}
}

void _resetIndex(List<Keyword> keywords) {
  if (Tools.hasNotElements(keywords)) return;
  for (var i = 0; i < keywords.length; i++) {
    keywords[i].index = i;
  }
}

void _clearAlphabetsStatus(KeywordNavPageState state) {
  var pressedAlphabets = state.getPressedAlphabetList();
  if (pressedAlphabets != null) {
    for (var i = 0; i < pressedAlphabets.length; i++) {
      if (pressedAlphabets[i].pressed) {
        pressedAlphabets[i].pressed = false;
      }
    }
  }
}

void _clearOtherFiltersStatus(
    String filteredKeyword, KeywordNavPageState state) {
  var pressedFilters = state.getPressedPropertyFilterList();
  if (pressedFilters != null) {
    for (var i = 0; i < pressedFilters.length; i++) {
      if (pressedFilters[i].title != filteredKeyword) {
        pressedFilters[i].pressed = false;
      }
    }
  }
}

void _clearAllFiltersStatus(KeywordNavPageState state) {
  var pressedFilters = state.getPressedPropertyFilterList();
  if (pressedFilters != null) {
    for (var i = 0; i < pressedFilters.length; i++) {
      pressedFilters[i].pressed = false;
    }
  }
}

Future<KeywordNavEnv> _readKeywordNavEnv(
    Context<KeywordNavPageState> ctx) async {
  final jsonString =
      await SharedUtil.instance.getString(_buildKeywordNavKeyName());
  if (jsonString == null) return null;
  return KeywordNavEnv.fromJson(jsonDecode(jsonString));
}

/// 保存关键词导航状态数据
Future _saveKeywordNavEnv(KeywordNavPageState state) async {
  if (Tools.hasNotElements(state.filters)) return;
  final keywordNavEnv = KeywordNavEnv(state.keywordMode, state.hasMoreFilters,
      state.nextPageNo, state.filters, '');
  await SharedUtil.instance.saveString(
      _buildKeywordNavKeyName(), jsonEncode(keywordNavEnv.toJson()));
}

Future<List<Keyword>> _getFilters(
    KeywordNavPageState pageState, bool firstPage) async {
  if (GlobalStore.hasError) return pageState.filters;
  final pageNo = firstPage ? 0 : pageState.nextPageNo;
  final filterKeywords = GlobalStore.filterKeywords;
  final condition =
      filterKeywords == null || filterKeywords == '' ? '' : ",$filterKeywords";
  final topic = GlobalStore.currentTopicDef;
  try {
    final currKeyName = _buildFilterKeyName(
        topic.topicName, pageNo, condition, pageState.keywordMode);
    var filters = await _loadTopicFiltersPage(currKeyName);
    if (filters != null) return filters;
    filters = await InfoNavServices.getKeywordProperties(
        "${topic.indexKeyword}${condition}_",
        ParamNames.defaultRelationTypeParam,
        pageNo,
        Constants.filterPageSize,
        Constants.cacheFlagKeyword,
        topic.topicFirst,
        propertyMode: topic.propertyMode);
    await _saveTopicFiltersPage(currKeyName, filters);
    return filters;
  } catch (err) {
    GlobalStore.store
        .dispatch(GlobalReducerCreator.setErrorStatusReducer(true));
    return null;
  }
}

Future<List<Keyword>> _getFiltersFavorite(
    KeywordNavPageState pageState, bool firstPage) async {
  if (GlobalStore.hasError) return pageState.filters;
  final pageNo = firstPage ? 0 : pageState.nextPageNo;
  final filterKeywords = GlobalStore.filterKeywords;
  final condition =
      filterKeywords == null || filterKeywords == '' ? '' : ",$filterKeywords";
  final userName = GlobalStore.userInfo.userName;
  try {
    final currKeyName = _buildFilterKeyName(Constants.favoriteEntity + userName,
        pageNo, condition, pageState.keywordMode);
    var filters = await _loadTopicFiltersPage(currKeyName);
    if (filters != null) return filters;
    filters = await InfoNavServices.getKeywordPropertiesFavorite(
        userName,
        condition,
        pageNo,
        Constants.filterPageSize,
        Constants.cacheFlagKeyword);
    await _saveTopicFiltersPage(currKeyName, filters);
    return filters;
  } catch (err) {
    GlobalStore.store
        .dispatch(GlobalReducerCreator.setErrorStatusReducer(true));
    return null;
  }
}

Future<List<Keyword>> _getFiltersHistory(
    KeywordNavPageState pageState, bool firstPage) async {
  if (GlobalStore.hasError) return pageState.filters;
  final pageNo = firstPage ? 0 : pageState.nextPageNo;
  final filterKeywords = GlobalStore.filterKeywords;
  final condition =
      filterKeywords == null || filterKeywords == '' ? '' : ",$filterKeywords";
  final userName = GlobalStore.userInfo.userName;
  try {
    final currKeyName = _buildFilterKeyName(Constants.historyEntity + userName,
        pageNo, condition, pageState.keywordMode);
    var filters = await _loadTopicFiltersPage(currKeyName);
    if (filters != null) return filters;
    filters = await InfoNavServices.getKeywordPropertiesHistory(
        userName,
        condition,
        pageNo,
        Constants.filterPageSize,
        Constants.cacheFlagKeyword);
    await _saveTopicFiltersPage(currKeyName, filters);
    return filters;
  } catch (err) {
    GlobalStore.store
        .dispatch(GlobalReducerCreator.setErrorStatusReducer(true));
    return null;
  }
}

Future<List<Keyword>> _getSubFilters(String parentFilterName) async {
  if (GlobalStore.hasError) return null;
  try {
    final topicName = GlobalStore.currentTopicDef.topicName;
    final currKeyName = _buildSubFilterKeyName(topicName, parentFilterName);
    var filters = await _loadTopicFiltersPage(currKeyName);
    if (filters != null) return filters;
    filters =
        await InfoNavServices.getFilterSubKeywords(parentFilterName, true);
    await _saveTopicFiltersPage(currKeyName, filters);
    return filters;
  } catch (err) {
    GlobalStore.store
        .dispatch(GlobalReducerCreator.setErrorStatusReducer(true));
    return null;
  }
}

Future<List<Keyword>> _getAlphabetFilters(String topicKeyword) async {
  if (GlobalStore.hasError) return null;
  try {
    final currKeyName = _buildAlphabetKeyName(topicKeyword);
    var filters = await _loadTopicFiltersPage(currKeyName);
    if (filters != null) return filters;
    final pyCodes = await InfoNavServices.getTopicTagsPyCodes(topicKeyword);
    filters = _buildAlphabetKeywords(pyCodes);
    await _saveTopicFiltersPage(currKeyName, filters);
    return filters;
  } catch (err) {
    GlobalStore.store
        .dispatch(GlobalReducerCreator.setErrorStatusReducer(true));
    return null;
  }
}

Future<List<Keyword>> _getAlphabetFiltersFavorite(String userName) async {
  if (GlobalStore.hasError) return null;
  try {
    final currKeyName =
        _buildAlphabetKeyName(Constants.favoriteEntity + userName);
    var filters = await _loadTopicFiltersPage(currKeyName);
    if (filters != null) return filters;
    final pyCodes = await InfoNavServices.getFavoriteTagsPyCodes(userName);
    filters = _buildAlphabetKeywords(pyCodes);
    if (filters.length > 0) {
      await _saveTopicFiltersPage(currKeyName, filters);
    }
    return filters;
  } catch (err) {
    GlobalStore.store
        .dispatch(GlobalReducerCreator.setErrorStatusReducer(true));
    return null;
  }
}

Future<List<Keyword>> _getAlphabetFiltersHistory(String userName) async {
  if (GlobalStore.hasError) return null;
  try {
    final currKeyName =
        _buildAlphabetKeyName(Constants.historyEntity + userName);
    var filters = await _loadTopicFiltersPage(currKeyName);
    if (filters != null) return filters;
    final pyCodes = await InfoNavServices.getHistoryTagsPyCodes(userName);
    filters = _buildAlphabetKeywords(pyCodes);
    if (filters.length > 0) {
      await _saveTopicFiltersPage(currKeyName, filters);
    }
    return filters;
  } catch (err) {
    GlobalStore.store
        .dispatch(GlobalReducerCreator.setErrorStatusReducer(true));
    return null;
  }
}

List<Keyword> _buildAlphabetKeywords(String pyCodes) {
  var keywords = List<Keyword>();
  if (pyCodes == null) return keywords;
  final alphabets = pyCodes.trim().split(',');
  var index = 0;
  alphabets.forEach((alphabet) {
    if (alphabet != '') {
      keywords.add(Keyword(index: index, title: alphabet, keyId: -1));
    }
    index++;
  });
  return keywords;
}

Future<List<Keyword>> _loadTopicFiltersPage(String currKeyName) async {
  var jsonString = await SharedUtil.instance.getString(currKeyName);
  if (jsonString != null) {
    var jsonItems = json.decode(jsonString);
    var filters =
        jsonItems.map<Keyword>((item) => Keyword.fromJson(item)).toList();
    if (filters != null && filters.length > 0) return filters;
  }
  return null;
}

Future _saveTopicFiltersPage(String currKeyName, List<Keyword> filters) async {
  if (filters != null && filters.length > 0) {
    await SharedUtil.instance.saveString(currKeyName, jsonEncode(filters));
  }
}

String _buildFilterKeyName(
    String topicName, int pageNo, String condition, bool keywordMode) {
  return '${topicName}_filter_${pageNo}_${condition}_$keywordMode';
}

String _buildSubFilterKeyName(String topicName, String parentFilter) {
  return '${topicName}_subfilter_$parentFilter';
}

String _buildAlphabetKeyName(String topicKeyword) {
  return '${topicKeyword}_alphabet';
}

String _buildKeywordNavKeyName() {
  final sourceType = GlobalStore.sourceType.toString();
  final topicName = GlobalStore.currentTopicDef.topicName;
  return Keys.currentKeywordNav + sourceType + topicName;
}

bool _isLoading(KeywordNavPageState state) {
  if (state.isLoading && Environment.isInDebugMode) {
    final bgColor = GlobalStore.themePrimaryIcon;
    Dialogs.showInfoToast('数据加载中...', bgColor);
  }
  return state.isLoading;
}

bool _isLoadingSuccess(List<Keyword> keywords) {
  if (GlobalStore.hasError) return false;
  if (keywords == null) {
    try {
      InfoNavServices.clearDataCache();
    } catch (err) {}
  }
  return true;
}
