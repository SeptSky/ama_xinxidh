import 'dart:convert';

import 'package:fish_redux/fish_redux.dart';

import '../../common/consts/constants.dart';
import '../../common/consts/keys.dart';
import '../../common/consts/param_names.dart';
import '../../common/data_access/webApi/info_nav_services.dart';
import '../../common/utilities/dialogs.dart';
import '../../common/utilities/shared_util.dart';
import '../../common/utilities/tools.dart';
import '../../global_store/global_action.dart';
import '../../global_store/global_store.dart';
import '../../models/keywords/keyword.dart';
import '../../models/keywords/keyword_nav_env.dart';
import '../info_nav_page/info_nav_action.dart';
import '../keyword_nav_page/keyword_item_component/keyword_action.dart';
import '../keyword_nav_page/keyword_item_component/keyword_state.dart';
import '../keyword_nav_page/keyword_nav_action.dart';
import 'keyword_related_action.dart';
import 'keyword_related_state.dart';

Effect<KeywordRelatedPageState> buildEffect() {
  /// 建立Action名称与Action实现之间的映射关系
  /// 这里定义了首页所有操作行为的入口
  return combineEffects(<Object, Effect<KeywordRelatedPageState>>{
    Lifecycle.initState: _init,
    Lifecycle.dispose: _dispose,
    KeywordRelatedPageActionEnum.onRefreshPage: _onRefreshPage,
    KeywordRelatedPageActionEnum.onGetNextPageKeywords: _onGetNextPageKeywords,
    KeywordRelatedPageActionEnum.onPressFilterAction: _onPressFilterAction,
    KeywordRelatedPageActionEnum.onPressKeywordAction: _onPressKeywordAction,
  });
}

Future _init(Action action, Context<KeywordRelatedPageState> ctx) async {
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
      _onGetNextPageKeywords(action, ctx);
    }
  });

  /// 不使用Future.Delayed方法将会抛出异常，通过Delayed可以跳过首次执行顺序
  Future.delayed(Duration.zero, () async {
    if (_isLoading(ctx.state)) return;
    _initKeywordNavEnvironment(action, ctx);
  });
}

Future _dispose(Action action, Context<KeywordRelatedPageState> ctx) async {
  ctx.state.scrollController.dispose();
  await _saveKeywordNavEnv(ctx.state);
}

Future _onRefreshPage(
    Action action, Context<KeywordRelatedPageState> ctx) async {
  if (_isLoading(ctx.state)) return;
  GlobalStore.store.dispatch(GlobalReducerCreator.setErrorStatusReducer(false));
  ctx.dispatch(KeywordReducerCreator.resetFilterReducer());
  _initKeywordNavEnvironment(action, ctx, forceUpdate: true);
}

Future _onGetFirstPageKeywords(
    Action action, Context<KeywordRelatedPageState> ctx,
    {bool forceUpdate = false}) async {
  if (_isLoading(ctx.state)) return;
  // 需要考虑重复读取的情况
  if (forceUpdate ||
      GlobalStore.hasError ||
      Tools.hasNotElements(ctx.state.keywords)) {
    ctx.dispatch(
        KeywordRelatedPageReducerCreator.setIsLoadingFlagReducer(true));
    try {
      final keywords = await _getFilteredKeywords(ctx.state, true);
      if (await _isLoadingSuccess(keywords)) {
        _resetIndex(keywords);
        ctx.dispatch(
            KeywordRelatedPageReducerCreator.initKeywordsReducer(keywords));
        try {
          final scrollController = ctx.state.scrollController;
          scrollController.jumpTo(scrollController.position.minScrollExtent);
        } catch (err) {}
      }
    } finally {
      ctx.dispatch(
          KeywordRelatedPageReducerCreator.setIsLoadingFlagReducer(false));
    }
  }
}

Future _onGetNextPageKeywords(
    Action action, Context<KeywordRelatedPageState> ctx) async {
  if (_isLoading(ctx.state)) return;
  final loadedCount = ctx.state.keywords.length;
  if (loadedCount / Constants.keywordPageSize == ctx.state.nextPageNo) {
    ctx.dispatch(
        KeywordRelatedPageReducerCreator.setIsLoadingFlagReducer(true));
    try {
      List<Keyword> keywords = await _getFilteredKeywords(ctx.state, false);
      if (await _isLoadingSuccess(keywords)) {
        ctx.dispatch(
            KeywordRelatedPageReducerCreator.setNextPageKeywordsReducer(
                keywords));
      }
    } finally {
      ctx.dispatch(
          KeywordRelatedPageReducerCreator.setIsLoadingFlagReducer(false));
    }
  }
}

Future _onPressFilterAction(
    Action action, Context<KeywordRelatedPageState> ctx) async {
  String filterKeywords = action.payload;
  if (filterKeywords == ctx.state.filterKeywords) return;
  if (_isLoading(ctx.state)) return;
  ctx.dispatch(KeywordRelatedPageReducerCreator.setFilterKeywordsReducer(
      filterKeywords));
  _onGetFirstPageKeywords(action, ctx, forceUpdate: true);
}

Future _onPressKeywordAction(
    Action action, Context<KeywordRelatedPageState> ctx) async {
  if (_isLoading(ctx.state)) return;
  final KeywordState relatedKeyword = action.payload;
  final filteredKeywords =
      '${ctx.state.filterKeywords},${relatedKeyword.title}';
  _clearOtherKeywordsStatus(relatedKeyword.title, ctx.state);
  ctx.dispatch(KeywordReducerCreator.pressFilterReducer(relatedKeyword.index));
  ctx.broadcast(
      InfoNavPageActionCreator.onSetFilteredKeyword(filteredKeywords));
  _incFilterRankValue(
      GlobalStore.currentTopicDef.indexKeyword, relatedKeyword.title);
}

Future _initKeywordNavEnvironment(
    Action action, Context<KeywordRelatedPageState> ctx,
    {bool forceUpdate = false}) async {
  final keywordNavEnv = await _loadKeywordNavEnv(ctx);
  if (keywordNavEnv == null ||
      keywordNavEnv != null &&
          keywordNavEnv.filteredKeywords != ctx.state.filterKeywords) {
    _onGetFirstPageKeywords(action, ctx, forceUpdate: forceUpdate);
  } else {
    ctx.dispatch(
        KeywordRelatedPageReducerCreator.restoreStateReducer(keywordNavEnv));
    final filterKeywords = ctx.state.getPressedFilterKeywords();
    ctx.broadcast(
        InfoNavPageActionCreator.onSetFilteredKeyword(filterKeywords));
    _scrollToPressedKeyword(ctx);
  }
}

void _scrollToPressedKeyword(Context<KeywordRelatedPageState> ctx) {
  final keyword = ctx.state.getPressedKeyword();
  if (keyword == null) return;
  final params = <String, dynamic>{
    ParamNames.contextParam: ctx,
    ParamNames.keywordIdParam: keyword.keyId,
  };
  ctx.broadcast(KeywordNavPageActionCreator.onScrollToKeyword(params));
}

void _resetIndex(List<Keyword> keywords) {
  if (Tools.hasNotElements(keywords)) return;
  for (var i = 0; i < keywords.length; i++) {
    keywords[i].index = i;
  }
}

void _clearOtherKeywordsStatus(
    String filteredKeyword, KeywordRelatedPageState state) {
  var pressedKeyword = state.getPressedKeyword();
  if (pressedKeyword != null) {
    pressedKeyword.pressed = false;
  }
}

Future<KeywordNavEnv> _loadKeywordNavEnv(
    Context<KeywordRelatedPageState> ctx) async {
  final jsonString =
      await SharedUtil.instance.getString(Keys.currentRelatedKeyword);
  if (jsonString == null) return null;
  return KeywordNavEnv.fromJson(jsonDecode(jsonString));
}

/// 保存关键词导航状态数据
Future _saveKeywordNavEnv(KeywordRelatedPageState state) async {
  if (state.keywords == null) return;
  final keywordNavEnv = KeywordNavEnv(true, state.hasMoreKeywords,
      state.nextPageNo, state.keywords, state.filterKeywords);
  await SharedUtil.instance.saveString(
      Keys.currentRelatedKeyword, jsonEncode(keywordNavEnv.toJson()));
}

Future<List<Keyword>> _getFilteredKeywords(
    KeywordRelatedPageState pageState, bool firstPage) async {
  if (GlobalStore.hasError) return pageState.keywords;
  final pageNo = firstPage ? 0 : pageState.nextPageNo;
  final filterKeywords = pageState.filterKeywords;
  final condition = filterKeywords == null ? '' : "$filterKeywords";
  final topic = GlobalStore.currentTopicDef;
  try {
    final currKeyName = _buildKeywordKeyName(
        topic.topicName, topic.topicKeyword, pageNo, condition);
    var keywords = await _loadRelatedKeywordsPage(currKeyName);
    if (keywords != null) return keywords;
    keywords = await InfoNavServices.getFilteredKeywords(
        "${topic.indexKeyword}_",
        ParamNames.defaultRelationTypeParam,
        "$condition",
        true,
        pageNo,
        Constants.keywordPageSize,
        Constants.cacheFlagKeyword,
        1,
        topic.topicFirst);
    await _saveRelatedKeywordsPage(currKeyName, keywords);
    return keywords;
  } catch (err) {
    GlobalStore.store
        .dispatch(GlobalReducerCreator.setErrorStatusReducer(true));
    return null;
  }
}

Future<List<Keyword>> _loadRelatedKeywordsPage(String currKeyName) async {
  var jsonString = await SharedUtil.instance.getString(currKeyName);
  if (jsonString != null) {
    var jsonItems = json.decode(jsonString);
    var keywords =
        jsonItems.map<Keyword>((item) => Keyword.fromJson(item)).toList();
    if (keywords != null && keywords.length > 0) return keywords;
  }
  return null;
}

Future _saveRelatedKeywordsPage(
    String currKeyName, List<Keyword> keywords) async {
  if (keywords != null && keywords.length > 0) {
    await SharedUtil.instance.saveString(currKeyName, jsonEncode(keywords));
  }
}

String _buildKeywordKeyName(
    String topicName, String topicKeyword, int pageNo, String condition) {
  return '${topicName}_${topicKeyword}_${pageNo}_$condition';
}

bool _isLoading(KeywordRelatedPageState state) {
  if (state.isLoading) {
    final bgColor = GlobalStore.themePrimaryIcon;
    Dialogs.showInfoToast('数据加载中...', bgColor);
  }
  return state.isLoading;
}

Future<bool> _isLoadingSuccess(List<Keyword> keywords) async {
  if (GlobalStore.hasError) return false;
  if (keywords == null) {
    try {
      await InfoNavServices.clearDataCache();
    } catch (err) {}
  }
  return true;
}

void _incFilterRankValue(String topicKeyword, String filterName) {
  try {
    InfoNavServices.incFilterRankValue(topicKeyword, filterName, 1);
  } catch (err) {}
}
