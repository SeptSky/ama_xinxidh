import 'dart:convert';

import 'package:amainfoindex/common/consts/enum_types.dart';
import 'package:fish_redux/fish_redux.dart';

import '../../common/consts/constants.dart';
import '../../common/consts/keys.dart';
import '../../common/consts/param_names.dart';
import '../../common/data_access/app_def.dart';
import '../../common/data_access/webApi/info_nav_services.dart';
import '../../common/utilities/dialogs.dart';
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
    var keywordNavEnv = await _readKeywordNavEnv(ctx);
    if (keywordNavEnv == null) {
      _onGetFirstPageFilters(action, ctx);
    } else {
      ctx.dispatch(
          KeywordNavPageReducerCreator.resotreStateReducer(keywordNavEnv));
      // 恢复后重新刷新特征组合条件：只有1列时，交给关联关键词页面刷新信息列表
      if (ctx.state.keywordMode &&
          ctx.state.getGridColCount() == Constants.maxColCount) {
        final filterKeywords = ctx.state.getPressedPropertyFilterText();
        ctx.broadcast(
            InfoNavPageActionCreator.onSetFilteredKeyword(filterKeywords));
      }
    }
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
  final keywordNavEnv = await _readKeywordNavEnv(ctx);
  if (keywordNavEnv != null) {
    ctx.dispatch(
        KeywordNavPageReducerCreator.resotreStateReducer(keywordNavEnv));
  }
  if (ctx.state.keywordMode) {
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
        var pressedFilters = ctx.state.getPressedPropertyFilterList();
        if (pressedFilters != null) {
          pressedFilters.addAll(keywords);
          keywords = pressedFilters;
        }
        _resetIndex(keywords);
        ctx.dispatch(
            KeywordNavPageReducerCreator.initKeywordsReducer(keywords));
        _resetScrollController(ctx);
      }
    } finally {
      ctx.dispatch(KeywordNavPageReducerCreator.setIsLoadingFlagReducer(false));
    }
  }
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
  int excludeIndex = action.payload;
  final filteredKeywords =
      ctx.state.getPressedPropertyFilterText(excludeIndex: excludeIndex);
  _triggerRelatedKeywords(filteredKeywords, ctx);
  _onGetFirstPageFilters(action, ctx, forceUpdate: true);
  // broadcast负责跨页面调用Effect
  ctx.broadcast(
      InfoNavPageActionCreator.onSetFilteredKeyword(filteredKeywords));
}

Future _onCombineFilterAction(
    Action action, Context<KeywordNavPageState> ctx) async {
  final filteredKeywords = ctx.state.getPressedPropertyFilterText();
  _triggerRelatedKeywords(filteredKeywords, ctx);
  _onGetFirstPageFilters(action, ctx, forceUpdate: true);
  // broadcast负责跨页面调用Effect
  ctx.broadcast(
      InfoNavPageActionCreator.onSetFilteredKeyword(filteredKeywords));
}

Future _onResetFilterAction(
    Action action, Context<KeywordNavPageState> ctx) async {
  ctx.dispatch(KeywordReducerCreator.resetFilterReducer());
  if (_isLoading(ctx.state)) {
    ctx.dispatch(KeywordNavPageReducerCreator.setIsLoadingFlagReducer(false));
  }
  _onGetFirstPageFilters(action, ctx, forceUpdate: true);
  // broadcast负责跨页面调用Effect
  ctx.broadcast(InfoNavPageActionCreator.onSetFilteredKeyword(null));
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
      await SharedUtil.instance.removeString(Keys.currentKeywordNav);
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

  String filteredKeywords = action.payload;
  _clearOtherFiltersStatus(filteredKeywords, ctx.state);
  _onGetFirstPageFilters(action, ctx, forceUpdate: true);
  // broadcast负责跨页面调用Effect
  ctx.broadcast(
      KeywordRelatedPageActionCreator.onPressFilterAction(filteredKeywords));
  ctx.broadcast(
      InfoNavPageActionCreator.onSetFilteredKeyword(filteredKeywords));

  // 返回true，意味着终止后续处理逻辑
  return true;
}

Future<bool> _pressParentFilter(bool processed, bool isProperty, Action action,
    Context<KeywordNavPageState> ctx) async {
  if (processed || isProperty) return processed;

  _getPressedParentSubFilters(action, ctx);
  var pressedFiltersText = ctx.state.getPressedPropertyFilterText();
  // broadcast负责跨页面调用Effect
  ctx.broadcast(
      InfoNavPageActionCreator.onSetFilteredKeyword(pressedFiltersText));

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

Future<KeywordNavEnv> _readKeywordNavEnv(
    Context<KeywordNavPageState> ctx) async {
  final jsonString =
      await SharedUtil.instance.getString(Keys.currentKeywordNav);
  if (jsonString == null) return null;
  return KeywordNavEnv.fromJson(jsonDecode(jsonString));
}

/// 保存关键词导航状态数据
Future _saveKeywordNavEnv(KeywordNavPageState state) async {
  if (Tools.hasNotElements(state.filters)) return;
  final keywordNavEnv = KeywordNavEnv(state.keywordMode, state.hasMoreFilters,
      state.nextPageNo, state.filters, '');
  await SharedUtil.instance
      .saveString(Keys.currentKeywordNav, jsonEncode(keywordNavEnv.toJson()));
}

Future<List<Keyword>> _getFilters(
    KeywordNavPageState pageState, bool firstPage) async {
  if (GlobalStore.hasError) return pageState.filters;
  final pageNo = firstPage ? 0 : pageState.nextPageNo;
  final pressedFilterText = pageState.getPressedPropertyFilterText();
  final condition = pressedFilterText == null ? '' : ",$pressedFilterText";
  final topic = GlobalStore.currentTopicDef;
  try {
    final currKeyName = _buildFilterKeyName(topic.topicName, pageNo, condition);
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
  final pressedFilterText = pageState.getPressedPropertyFilterText();
  final condition = pressedFilterText == null ? '' : ",$pressedFilterText";
  final userName = GlobalStore.userInfo.userName;
  try {
    final currKeyName = _buildFilterKeyName(
        Constants.favoriteEntity + userName, pageNo, condition);
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
  final pressedFilterText = pageState.getPressedPropertyFilterText();
  final condition = pressedFilterText == null ? '' : ",$pressedFilterText";
  final userName = GlobalStore.userInfo.userName;
  try {
    final currKeyName = _buildFilterKeyName(
        Constants.historyEntity + userName, pageNo, condition);
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

String _buildFilterKeyName(String topicName, int pageNo, String condition) {
  return '${topicName}_filter_${pageNo}_$condition';
}

String _buildSubFilterKeyName(String topicName, String parentFilter) {
  return '${topicName}_subfilter_$parentFilter';
}

String _buildAlphabetKeyName(String topicKeyword) {
  return '${topicKeyword}_alphabet';
}

bool _isLoading(KeywordNavPageState state) {
  if (state.isLoading) {
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
