import 'dart:convert';

import 'package:fish_redux/fish_redux.dart';
import 'package:fluwx_no_pay/fluwx_no_pay.dart';

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
import '../../models/entities/info_entity.dart';
import '../../models/messages/pub_message.dart';
import '../home_page/home_action.dart';
import '../keyword_nav_page/keyword_nav_action.dart';
import 'entity_item_component/entity_action.dart';
import 'entity_item_component/entity_state.dart';
import 'info_nav_action.dart';
import 'info_nav_state.dart';

Effect<InfoNavPageState> buildEffect() {
  /// 建立Action名称与Action实现之间的映射关系
  /// 这里定义了首页所有操作行为的入口
  return combineEffects(<Object, Effect<InfoNavPageState>>{
    Lifecycle.initState: _init,
    Lifecycle.dispose: _dispose,
    InfoNavPageActionEnum.onRefreshPage: _onRefreshPage,
    InfoNavPageActionEnum.onSetFilteredKeyword: _onSetFilteredKeyword,
    InfoNavPageActionEnum.onChangeTopicDef: _onChangeTopicDef,
    InfoNavPageActionEnum.onJumpToTopicDef: _onJumpToTopicDef,
    InfoNavPageActionEnum.onInfoEntityPressed: _onInfoEntityPressed,
    InfoNavPageActionEnum.onParagraphPressed: _onParagraphPressed,
    InfoNavPageActionEnum.onTagPressed: _onTagPressed,
    InfoNavPageActionEnum.onToggleKeywordNav: _onToggleKeywordNav,
    InfoNavPageActionEnum.onAddInfoEntity: _onAddInfoEntity,
    InfoNavPageActionEnum.onEditInfoEntity: _onEditInfoEntity,
    InfoNavPageActionEnum.onDelInfoEntity: _onDelInfoEntity,
    InfoNavPageActionEnum.onAddInfoEntityTags: _onAddInfoEntityTags,
    InfoNavPageActionEnum.onDelInfoEntityTag: _onDelInfoEntityTag,
    InfoNavPageActionEnum.onDelTagFromTopic: _onDelTagFromTopic,
    InfoNavPageActionEnum.onSharePageUrl: _onSharePageUrl,
    InfoNavPageActionEnum.onClearCache: _onClearCache,
    InfoNavPageActionEnum.onShowNormal: _onShowNormal,
    InfoNavPageActionEnum.onShowHistory: _onShowHistory,
    InfoNavPageActionEnum.onShowFavorite: _onShowFavorite,
    InfoNavPageActionEnum.onFavoriteInfoEntity: _onFavoriteInfoEntity,
    InfoNavPageActionEnum.onSetSearchMode: _onSetSearchMode,
    InfoNavPageActionEnum.onSearchMatching: _onSearchMatching,
    InfoNavPageActionEnum.onClearSearchText: _onClearSearchText,
    InfoNavPageActionEnum.onSearchRelatedTopics: _onSearchRelatedTopics,
  });
}

Future _init(Action action, Context<InfoNavPageState> ctx) async {
  final scrollController = ctx.state.scrollController;
  scrollController.addListener(() {
    if (scrollController.position.pixels ==
        scrollController.position.minScrollExtent) {
      if (GlobalStore.contentType == ContentType.infoEntity &&
          ctx.state.nextPageNo > 0) {
        _onGetPrevPageInfoEntities(action, ctx);
      }
    }
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      final contentType = GlobalStore.contentType;
      switch (contentType) {
        case ContentType.infoEntity:
        case ContentType.pageLink:
          _onGetNextPageInfoEntities(action, ctx);
          break;
        case ContentType.keyword:
          final searchStr = ctx.state.textController.text.trim();
          _getSearchMatchingKeywordsNextPage(ctx, searchStr);
          break;
        default:
      }
    }
  });

  /// 不使用Future.Delayed方法将会抛出异常，通过Delayed可以跳过首次执行顺序
  Future.delayed(Duration.zero, () async {
    if (_isLoading(ctx.state)) return;
    await _showInfoEntitiesBySourceType(ctx, action);
    await _checkLatestMessage(ctx);
  });
}

void _dispose(Action action, Context<InfoNavPageState> ctx) {
  ctx.state.scrollController.dispose();
  ctx.state.textController.dispose();
}

Future _onRefreshPage(Action action, Context<InfoNavPageState> ctx) async {
  GlobalStore.store.dispatch(GlobalReducerCreator.setErrorStatusReducer(false));
  if (_isLoading(ctx.state)) return;
  await _showInfoEntitiesBySourceType(ctx, action);
  await _checkLatestMessage(ctx);
}

Future _onSetFilteredKeyword(
    Action action, Context<InfoNavPageState> ctx) async {
  if (_isLoading(ctx.state)) return;
  final String filterKeywords = action.payload;
  GlobalStore.store
      .dispatch(GlobalReducerCreator.setFilterKeywordsReducer(filterKeywords));
  Future.delayed(Duration.zero, () async {
    await _showInfoEntitiesBySourceType(ctx, action);
    if (filterKeywords != null) {
      GlobalStore.store
          .dispatch(GlobalReducerCreator.setWebLoadingStatusReducer(false));
    }
    _jumpToListTop(ctx.state);
  });
}

Future _onChangeTopicDef(Action action, Context<InfoNavPageState> ctx) async {
  if (GlobalStore.hasError) return;
  if (_isLoading(ctx.state)) return;
  final int topicId = action.payload;
  try {
    ctx.state.textController.clear();
    if (ctx.state.topicEmpty) {
      ctx.dispatch(InfoNavPageReducerCreator.setTopicEmptyReducer(false));
    }
    final sourceType = GlobalStore.sourceType;
    final contentType = GlobalStore.contentType;
    if (sourceType != SourceType.normal ||
        contentType != ContentType.infoEntity) {
      _changeSourceContentType(SourceType.normal, ContentType.infoEntity, ctx);
    }
    if (ctx.state.filterKeywords != null &&
        contentType != ContentType.relatedTopic) {
      GlobalStore.store
          .dispatch(GlobalReducerCreator.setFilterKeywordsReducer(null));
    }
    await SharedUtil.instance.removeString(_buildKeywordNavKeyName());
    final topicDef = await InfoNavServices.getAppTopicFromWebApi(
        Xinxidh_App_Guid, topicId, true);
    if (topicDef != null) {
      GlobalStore.store
          .dispatch(GlobalReducerCreator.changeTopicDefReducer(topicDef));
      await _showInfoEntitiesBySourceType(ctx, action);
      if (ctx.state.infoEntities.isNotEmpty) {
        ctx.broadcast(KeywordNavPageActionCreator.onRefreshPage());
        _jumpToListTop(ctx.state);
      } else {
        ctx.dispatch(InfoNavPageReducerCreator.setTopicEmptyReducer(true));
      }
    }
  } catch (err) {
    GlobalStore.store
        .dispatch(GlobalReducerCreator.setErrorStatusReducer(true));
    return;
  }
}

Future _onJumpToTopicDef(Action action, Context<InfoNavPageState> ctx) async {
  if (GlobalStore.hasError) return;
  if (_isLoading(ctx.state)) return;
  final topicNames = action.payload;
  final topicNameList = topicNames.split(',');
  if (topicNameList.length != 2) return;
  try {
    GlobalStore.store.dispatch(
        GlobalReducerCreator.setFilterKeywordsReducer(topicNameList[1]));
    await SharedUtil.instance.removeString(Keys.currentKeywordNav);
    final topicDef = await InfoNavServices.getAppTopicFromWebApiByName(
        Xinxidh_App_Guid, topicNameList[0], true);
    if (topicDef != null) {
      GlobalStore.pushTopic();
      GlobalStore.store
          .dispatch(GlobalReducerCreator.changeTopicDefReducer(topicDef));
      await _getFirstPageInfoEntities(action, ctx, forceUpdate: true);
      ctx.broadcast(KeywordNavPageActionCreator.onRefreshPage());
      _jumpToListTop(ctx.state);
    }
  } catch (err) {
    GlobalStore.store
        .dispatch(GlobalReducerCreator.setErrorStatusReducer(true));
    return;
  }
}

Future _onInfoEntityPressed(
    Action action, Context<InfoNavPageState> ctx) async {
  if (_isLoading(ctx.state)) return;
  final EntityState entityState = action.payload;
  ctx.dispatch(
      InfoEntityReducerCreator.setPressedFlagReducer(entityState.index));
  ctx.dispatch(
      InfoNavPageReducerCreator.updateEntityItemReducer(entityState.index));
  await _openInfoEntity(entityState);
  final userName = GlobalStore.userInfo.userName;
  await InfoNavServices.incInfoEntityViewCount(userName, entityState.keyId);
}

Future _onParagraphPressed(Action action, Context<InfoNavPageState> ctx) async {
  if (GlobalStore.hasError) return;
  if (ctx.state.unjumpable) return;
  if (_isLoading(ctx.state)) return;
  final entityId = action.payload;
  final topicKeyword = GlobalStore.currentTopicDef.topicKeyword;
  try {
    final pageNo = await InfoNavServices.getEntityPageNoInTopic(
        topicKeyword, entityId, Constants.pageSize);
    if (pageNo >= 0) {
      ctx.broadcast(HomeActionCreator.onCloseKeywordSheet());
      await _onJumpToPageInfoEntities(action, ctx, pageNo, entityId);
      await _onGetNextPageInfoEntities(action, ctx);
      _scrollToPressedEntity(entityId, ctx);
    }
  } catch (err) {
    GlobalStore.store
        .dispatch(GlobalReducerCreator.setErrorStatusReducer(true));
  }
}

Future _onTagPressed(Action action, Context<InfoNavPageState> ctx) async {
  if (GlobalStore.hasError) return;
  if (_isLoading(ctx.state)) return;
  final tag = action.payload;
  var filterKeywords = ctx.state.filterKeywords;
  final newFilterKeywords = _getNewFilterKeywords(filterKeywords, tag);
  GlobalStore.store.dispatch(
      GlobalReducerCreator.setFilterKeywordsReducer(newFilterKeywords));
  ctx.dispatch(
      InfoEntityReducerCreator.setFilteredKeywordReducer(newFilterKeywords));
  await _showInfoEntitiesBySourceType(ctx, action);
}

Future _onToggleKeywordNav(Action action, Context<InfoNavPageState> ctx) async {
  final bool isKeywordNav = action.payload;
  if (ctx.state.isLoading ||
      isKeywordNav == ctx.state.isKeywordNav ||
      GlobalStore.contentType == ContentType.keyword ||
      GlobalStore.contentType == ContentType.relatedTopic) return;
  ctx.dispatch(InfoNavPageReducerCreator.setIsKeywordNavReducer(isKeywordNav));
  await _showInfoEntitiesBySourceType(ctx, action);
  if (isKeywordNav) {
    ctx.broadcast(KeywordNavPageActionCreator.onRefreshPage());
  }
}

Future _onAddInfoEntity(Action action, Context<InfoNavPageState> ctx) async {
  if (GlobalStore.hasError) return;
  try {
    final userName = GlobalStore.userInfo.userName;
    final int entityId = action.payload[ParamNames.entityIdParam];
    final String entityTitle = action.payload[ParamNames.entityTitleParam];
    final String entityOverview =
        action.payload[ParamNames.entityOverviewParam];
    final String entityContent = action.payload[ParamNames.entityContentParam];
    final String tagNames = action.payload[ParamNames.tagParam];
    final newTagNames = _buildEntityTagNames(tagNames);
    final result = await InfoNavServices.refAddInfoEntityTopic(userName,
        entityId, entityTitle, entityOverview, entityContent, newTagNames);
    final bgColor = GlobalStore.themePrimaryIcon;
    if (result.contains('ok')) {
      Dialogs.showInfoToast('添加信息成功！', bgColor);
      await _reloadFirstPageInfoEntities(action, ctx);
    } else {
      Dialogs.showInfoToast(result, bgColor);
    }
  } catch (err) {
    GlobalStore.store
        .dispatch(GlobalReducerCreator.setErrorStatusReducer(true));
  }
}

Future _onEditInfoEntity(Action action, Context<InfoNavPageState> ctx) async {
  if (GlobalStore.hasError) return;
  try {
    final userName = GlobalStore.userInfo.userName;
    final int entityId = action.payload[ParamNames.entityIdParam];
    final String entityTitle = action.payload[ParamNames.entityTitleParam];
    final String entityOverview =
        action.payload[ParamNames.entityOverviewParam];
    final String entityContent = action.payload[ParamNames.entityContentParam];
    final String tagNames = action.payload[ParamNames.tagParam];
    final newTagNames = _buildEntityTagNames(tagNames);
    final result = await InfoNavServices.saveInfoEntityTopic(userName, entityId,
        entityTitle, entityOverview, entityContent, newTagNames);
    final bgColor = GlobalStore.themePrimaryIcon;
    if (result.contains('ok')) {
      Dialogs.showInfoToast('修改信息成功！', bgColor);
      await _reloadFirstPageInfoEntities(action, ctx);
    } else {
      Dialogs.showInfoToast(result, bgColor);
    }
  } catch (err) {
    GlobalStore.store
        .dispatch(GlobalReducerCreator.setErrorStatusReducer(true));
  }
}

Future _onDelInfoEntity(Action action, Context<InfoNavPageState> ctx) async {
  if (GlobalStore.hasError) return;
  try {
    final userName = GlobalStore.userInfo.userName;
    final int entityId = action.payload;
    final result =
        await InfoNavServices.deleteInfoEntityTopic(userName, entityId);
    final bgColor = GlobalStore.themePrimaryIcon;
    if (result.contains('ok')) {
      Dialogs.showInfoToast('删除信息成功！', bgColor);
      await _reloadFirstPageInfoEntities(action, ctx);
    } else {
      Dialogs.showInfoToast(result, bgColor);
    }
  } catch (err) {
    GlobalStore.store
        .dispatch(GlobalReducerCreator.setErrorStatusReducer(true));
  }
}

Future _onAddInfoEntityTags(
    Action action, Context<InfoNavPageState> ctx) async {
  if (GlobalStore.hasError) return;
  try {
    final userName = GlobalStore.userInfo.userName;
    final int entityId = action.payload[ParamNames.entityIdParam];
    final String tagNames = action.payload[ParamNames.tagParam];
    var newTagNames = _buildEntityTagNames(tagNames);
    await InfoNavServices.addInfoEntityTags(userName, entityId, newTagNames);
    _addInfoEntityTagsToPage(ctx, entityId, newTagNames);
  } catch (err) {
    GlobalStore.store
        .dispatch(GlobalReducerCreator.setErrorStatusReducer(true));
  }
}

Future _onDelInfoEntityTag(Action action, Context<InfoNavPageState> ctx) async {
  if (GlobalStore.hasError) return;
  try {
    final userName = GlobalStore.userInfo.userName;
    final int entityId = action.payload[ParamNames.entityIdParam];
    final String tagName = action.payload[ParamNames.tagParam];
    await InfoNavServices.delInfoEntityTag(userName, entityId, tagName);
    _delInfoEntityTagFromPage(ctx, entityId, tagName);
  } catch (err) {
    GlobalStore.store
        .dispatch(GlobalReducerCreator.setErrorStatusReducer(true));
  }
}

Future _onDelTagFromTopic(Action action, Context<InfoNavPageState> ctx) async {
  if (GlobalStore.hasError) return;
  try {
    final userName = GlobalStore.userInfo.userName;
    final topicKeyword = GlobalStore.currentTopicDef.topicKeyword;
    final tagName = action.payload;
    await InfoNavServices.delTagFromTopic(userName, topicKeyword, tagName);
    _clearInfoEntityCache(ctx.state);
    await _showInfoEntitiesBySourceType(ctx, action);
  } catch (err) {
    GlobalStore.store
        .dispatch(GlobalReducerCreator.setErrorStatusReducer(true));
  }
}

Future _onSharePageUrl(Action action, Context<InfoNavPageState> ctx) async {
  final EntityState entityState = action.payload;
  shareToWeChat(
      WeChatShareWebPageModel(entityState.subtitle, title: entityState.title));
}

Future _onClearCache(Action action, Context<InfoNavPageState> ctx) async {
  try {
    await GlobalStore.clearLocalCache();
    await InfoNavServices.clearDataCache();
    final bgColor = GlobalStore.themePrimaryIcon;
    Dialogs.showInfoToast('已清除数据缓存！', bgColor);
  } catch (err) {}
}

Future _onShowNormal(Action action, Context<InfoNavPageState> ctx) async {
  if (_isLoading(ctx.state)) return;
  ctx.state.textController.clear();
  if (ctx.state.topicEmpty) {
    ctx.dispatch(InfoNavPageReducerCreator.setTopicEmptyReducer(false));
  }
  GlobalStore.store
      .dispatch(GlobalReducerCreator.setSourceTypeReducer(SourceType.normal));
  await _getFirstPageInfoEntities(action, ctx, forceUpdate: true);
  ctx.broadcast(KeywordNavPageActionCreator.onRefreshPage());
}

Future _onShowHistory(Action action, Context<InfoNavPageState> ctx) async {
  if (_isLoading(ctx.state)) return;
  if (ctx.state.topicEmpty) {
    ctx.dispatch(InfoNavPageReducerCreator.setTopicEmptyReducer(false));
  }
  GlobalStore.store
      .dispatch(GlobalReducerCreator.setSourceTypeReducer(SourceType.history));
  final filterKeywords = ctx.state.filterKeywords;
  final infoEntities = filterKeywords == null || filterKeywords == ''
      ? await _getHistoryInfoEntities(ctx.state, 0)
      : await _getFilteredHistoryInfoEntities(ctx.state, filterKeywords, 0);
  if (_isLoadingSuccess(infoEntities)) {
    ctx.dispatch(InfoNavPageReducerCreator.initEntitiesReducer(infoEntities));
  }
  ctx.broadcast(KeywordNavPageActionCreator.onRefreshPage());
}

Future _onShowFavorite(Action action, Context<InfoNavPageState> ctx) async {
  if (_isLoading(ctx.state)) return;
  if (ctx.state.topicEmpty) {
    ctx.dispatch(InfoNavPageReducerCreator.setTopicEmptyReducer(false));
  }
  GlobalStore.store
      .dispatch(GlobalReducerCreator.setSourceTypeReducer(SourceType.favorite));
  final filterKeywords = ctx.state.filterKeywords;
  final infoEntities = filterKeywords == null || filterKeywords == ''
      ? await _getFavoriteInfoEntities(ctx.state, 0)
      : await _getFilteredFavoriteInfoEntities(ctx.state, filterKeywords, 0);
  if (_isLoadingSuccess(infoEntities)) {
    ctx.dispatch(InfoNavPageReducerCreator.initEntitiesReducer(infoEntities));
  }
  ctx.broadcast(KeywordNavPageActionCreator.onRefreshPage());
}

Future _onFavoriteInfoEntity(
    Action action, Context<InfoNavPageState> ctx) async {
  if (GlobalStore.hasError) return;
  try {
    final userName = GlobalStore.userInfo.userName;
    final EntityState entityState = action.payload;
    final result =
        await InfoNavServices.favoriteInfoEntity(userName, entityState.keyId);
    final bgColor = GlobalStore.themePrimaryIcon;
    Dialogs.showInfoToast(result, bgColor);
    if (result.contains('成功')) {
      ctx.dispatch(
          InfoEntityReducerCreator.toggleFavoriteReducer(entityState.index));
      ctx.dispatch(
          InfoNavPageReducerCreator.updateEntityItemReducer(entityState.index));
      GlobalStore.clearLocalCache();
      await InfoNavServices.clearDataCache();
      if (GlobalStore.sourceType == SourceType.favorite) {
        _onShowFavorite(action, ctx);
      }
    }
  } catch (err) {
    GlobalStore.store
        .dispatch(GlobalReducerCreator.setErrorStatusReducer(true));
  }
}

Future _onSetSearchMode(Action action, Context<InfoNavPageState> ctx) async {
  final bool searchMode = action.payload;
  GlobalStore.store
      .dispatch(GlobalReducerCreator.setSearchModeReducer(searchMode));
  if (!searchMode) {
    ctx.state.textController.clear();
  }
}

Future _onSearchMatching(Action action, Context<InfoNavPageState> ctx) async {
  if (GlobalStore.hasError) return;
  String searchStr = action.payload;
  if (searchStr == null) {
    searchStr = ctx.state.textController.text;
    if (searchStr.isNotEmpty) {
      ctx.dispatch(InfoNavPageReducerCreator.setAutoSearchReducer(true));
      GlobalStore.store
          .dispatch(GlobalReducerCreator.setFilterKeywordsReducer(null));
    }
  }
  if (searchStr == '') {
    if (GlobalStore.sourceType == SourceType.normal) {
      GlobalStore.store
          .dispatch(GlobalReducerCreator.setSearchModeReducer(false));
    }
    _changeSourceContentType(
        GlobalStore.sourceType, ContentType.infoEntity, ctx);
    await _showInfoEntitiesBySourceType(ctx, action);
    return;
  }
  _changeSourceContentType(GlobalStore.sourceType, ContentType.keyword, ctx);
  ctx.dispatch(InfoNavPageReducerCreator.setIsLoadingFlagReducer(true));
  try {
    final infoEntities =
        await _getSearchMatchingKeywordsFirstPage(ctx, searchStr);
    if (_isLoadingSuccess(infoEntities)) {
      ctx.dispatch(InfoNavPageReducerCreator.initEntitiesReducer(infoEntities));
    }
  } finally {
    ctx.dispatch(InfoNavPageReducerCreator.setIsLoadingFlagReducer(false));
  }
}

Future _onClearSearchText(Action action, Context<InfoNavPageState> ctx) async {
  if (GlobalStore.hasError) {
    GlobalStore.store
        .dispatch(GlobalReducerCreator.setErrorStatusReducer(false));
  }
  ctx.state.textController.clear();
  ctx.dispatch(InfoNavPageReducerCreator.setAutoSearchReducer(true));
  GlobalStore.store
      .dispatch(GlobalReducerCreator.setFilterKeywordsReducer(null));
  await _showInfoEntitiesBySourceType(ctx, action);
}

Future _onSearchRelatedTopics(
    Action action, Context<InfoNavPageState> ctx) async {
  if (GlobalStore.hasError) {
    GlobalStore.store
        .dispatch(GlobalReducerCreator.setErrorStatusReducer(false));
  }
  final filterKeyword = action.payload;
  final bgColor = GlobalStore.themePrimaryIcon;
  Dialogs.showInfoToast('查找【$filterKeyword】关联专题', bgColor);
  ctx.dispatch(InfoNavPageReducerCreator.setIsLoadingFlagReducer(true));
  try {
    final infoEntities = await _getRelatedTopics(ctx.state, filterKeyword, 0);
    if (_isLoadingSuccess(infoEntities)) {
      _changeSourceContentType(
          GlobalStore.sourceType, ContentType.relatedTopic, ctx);
      GlobalStore.store.dispatch(
          GlobalReducerCreator.setFilterKeywordsReducer(filterKeyword));
      ctx.dispatch(InfoNavPageReducerCreator.initEntitiesReducer(infoEntities));
    } else {
      Dialogs.showInfoToast('无【$filterKeyword】关联专题', bgColor);
    }
  } finally {
    ctx.dispatch(InfoNavPageReducerCreator.setIsLoadingFlagReducer(false));
  }
}

void _scrollToPressedEntity(int entityId, Context<InfoNavPageState> ctx) {
  final infoEntity = ctx.state.getInfoEntityById(entityId);
  if (infoEntity == null) return;
  final params = <String, dynamic>{
    ParamNames.contextParam: ctx,
    ParamNames.entityIdParam: entityId,
  };
  ctx.dispatch(InfoEntityActionCreator.onScrollToEntity(params));
}

Future _getFirstPageInfoEntities(Action action, Context<InfoNavPageState> ctx,
    {bool forceUpdate = false}) async {
  if (_isLoading(ctx.state)) return;
  // 需要考虑重复读取的情况
  if (forceUpdate ||
      GlobalStore.hasError ||
      Tools.hasNotElements(ctx.state.infoEntities)) {
    final infoEntities =
        ctx.state.filterKeywords == null || ctx.state.filterKeywords == ''
            ? await _getInfoEntities(ctx.state, true, forceUpdate: forceUpdate)
            : await _getFilteredInfoEntities(ctx.state, true);
    if (_isLoadingSuccess(infoEntities)) {
      ctx.dispatch(InfoNavPageReducerCreator.initEntitiesReducer(infoEntities));
    }
    await _getExtraPageInfoEntities(action, ctx);
  }
}

Future _reloadFirstPageInfoEntities(
    Action action, Context<InfoNavPageState> ctx) async {
  if (_isLoading(ctx.state)) return;
  await _clearInfoEntityCache(ctx.state);
  final infoEntities =
      ctx.state.filterKeywords == null || ctx.state.filterKeywords == ''
          ? await _reloadInfoEntities(ctx.state, 0)
          : await _reloadFilteredInfoEntities(ctx.state, 0);
  if (_isLoadingSuccess(infoEntities)) {
    ctx.dispatch(InfoNavPageReducerCreator.initEntitiesReducer(infoEntities));
  }
  await _reloadExtraPageInfoEntities(action, ctx);
}

Future _getExtraPageInfoEntities(
    Action action, Context<InfoNavPageState> ctx) async {
  final extraPage = GlobalStore.currentTopicDef.extraPage;
  if (extraPage == null ||
      extraPage <= 0 ||
      extraPage >= 3 ||
      GlobalStore.sourceType != SourceType.normal) return;
  for (var i = 0; i < extraPage; i++) {
    _onGetNextPageInfoEntities(action, ctx);
  }
}

Future _reloadExtraPageInfoEntities(
    Action action, Context<InfoNavPageState> ctx) async {
  final extraPage = GlobalStore.currentTopicDef.extraPage;
  if (extraPage == null || extraPage <= 0 || extraPage >= 3) return;
  for (var i = 0; i < extraPage; i++) {
    final nextPageNo = ctx.state.nextPageNo;
    final infoEntities =
        ctx.state.filterKeywords == null || ctx.state.filterKeywords == ''
            ? await _reloadInfoEntities(ctx.state, nextPageNo)
            : await _reloadFilteredInfoEntities(ctx.state, nextPageNo);
    if (_isLoadingSuccess(infoEntities)) {
      ctx.dispatch(
          InfoNavPageReducerCreator.setNextPageEntitiesReducer(infoEntities));
    }
  }
}

Future _onGetPrevPageInfoEntities(
    Action action, Context<InfoNavPageState> ctx) async {
  if (ctx.state.nextPageNo <= 0) return;
  final itemCount = ctx.state.infoEntities.length;
  final loadedPageCount = itemCount ~/ Constants.pageSize +
      (itemCount % Constants.pageSize == 0 ? 0 : 1);
  final prevPageNo = ctx.state.nextPageNo - loadedPageCount - 1;
  if (prevPageNo < 0) return;
  if (_isLoading(ctx.state)) return;
  ctx.dispatch(InfoNavPageReducerCreator.setIsLoadingFlagReducer(true));
  try {
    var infoEntities = await _getInfoEntitiesByPageNo(ctx.state, prevPageNo);
    if (_isLoadingSuccess(infoEntities)) {
      ctx.dispatch(
          InfoNavPageReducerCreator.setPrevPageEntitiesReducer(infoEntities));
      if (infoEntities.length > itemCount) {
        final entityId = ctx.state.infoEntities[Constants.pageSize - 1].keyId;
        _scrollToPressedEntity(entityId, ctx);
      }
    }
  } finally {
    ctx.dispatch(InfoNavPageReducerCreator.setIsLoadingFlagReducer(false));
  }
}

Future _onGetNextPageInfoEntities(
    Action action, Context<InfoNavPageState> ctx) async {
  if (_isLoading(ctx.state)) return;
  // 需要考虑重复读取的情况
  if (ctx.state.hasMoreEntities) {
    ctx.dispatch(InfoNavPageReducerCreator.setIsLoadingFlagReducer(true));
    try {
      final filterKeywords = ctx.state.filterKeywords;
      var infoEntities = List<InfoEntity>();
      switch (GlobalStore.sourceType) {
        case SourceType.history:
          infoEntities = filterKeywords == null || filterKeywords == ''
              ? await _getHistoryInfoEntities(ctx.state, ctx.state.nextPageNo)
              : await _getFilteredHistoryInfoEntities(
                  ctx.state, filterKeywords, ctx.state.nextPageNo);
          break;
        case SourceType.favorite:
          infoEntities = filterKeywords == null || filterKeywords == ''
              ? await _getFavoriteInfoEntities(ctx.state, ctx.state.nextPageNo)
              : await _getFilteredFavoriteInfoEntities(
                  ctx.state, filterKeywords, ctx.state.nextPageNo);
          break;
        default:
          infoEntities = ctx.state.jumpFlag ||
                  filterKeywords == null ||
                  filterKeywords == ''
              ? await _getInfoEntities(ctx.state, false)
              : await _getFilteredInfoEntities(ctx.state, false);
          break;
      }
      if (_isLoadingSuccess(infoEntities)) {
        ctx.dispatch(
            InfoNavPageReducerCreator.setNextPageEntitiesReducer(infoEntities));
      }
    } finally {
      ctx.dispatch(InfoNavPageReducerCreator.setIsLoadingFlagReducer(false));
    }
  }
}

Future _onJumpToPageInfoEntities(Action action, Context<InfoNavPageState> ctx,
    int pageNo, int entityId) async {
  if (_isLoading(ctx.state)) return;
  ctx.dispatch(InfoNavPageReducerCreator.setIsLoadingFlagReducer(true));
  try {
    var infoEntities = await _getInfoEntitiesByPageNo(ctx.state, pageNo);
    if (_isLoadingSuccess(infoEntities)) {
      ctx.state.getInfoEntityById(entityId, exInfoEntities: infoEntities)
        ..pressed = true;
      var infoEntityPack = <String, dynamic>{
        ParamNames.infoEntitiesParam: infoEntities,
        ParamNames.pageNoParam: pageNo,
      };
      ctx.dispatch(
          InfoNavPageReducerCreator.setJumpPageEntitiesReducer(infoEntityPack));
    }
  } finally {
    ctx.dispatch(InfoNavPageReducerCreator.setIsLoadingFlagReducer(false));
  }
}

Future _showInfoEntitiesBySourceType(
    Context<InfoNavPageState> ctx, Action action) async {
  switch (GlobalStore.sourceType) {
    case SourceType.history:
      await _onShowHistory(action, ctx);
      break;
    case SourceType.favorite:
      await _onShowFavorite(action, ctx);
      break;
    default:
      await _getFirstPageInfoEntities(action, ctx, forceUpdate: true);
      break;
  }
}

Future<List<InfoEntity>> _getInfoEntities(
    InfoNavPageState pageState, bool firstPage,
    {bool forceUpdate = false}) async {
  final pageNo = firstPage ? 0 : pageState.nextPageNo;
  return await _getInfoEntitiesByPageNo(pageState, pageNo,
      forceUpdate: forceUpdate);
}

Future<List<InfoEntity>> _reloadInfoEntities(
    InfoNavPageState pageState, int pageNo) async {
  if (GlobalStore.hasError) return pageState.infoEntities;
  final TopicDef topic = GlobalStore.currentTopicDef;
  final currKeyName = _buildEntityKeyName(topic.topicName, pageNo, '');
  try {
    final infoEntities = await InfoNavServices.getInfoEntities(
        topic.bgKeyword,
        topic.topicKeyword,
        "",
        ParamNames.defaultRelationTypeParam,
        ParamNames.defaultEntityTypeParam,
        pageNo,
        Constants.pageSize,
        false,
        topic.topicFirst);
    await _saveLocalEntitiesPage(currKeyName, infoEntities);
    return infoEntities;
  } catch (err) {
    GlobalStore.store
        .dispatch(GlobalReducerCreator.setErrorStatusReducer(true));
    return null;
  }
}

Future<List<InfoEntity>> _getInfoEntitiesByPageNo(
    InfoNavPageState pageState, int pageNo,
    {bool forceUpdate = false}) async {
  if (GlobalStore.hasError) return pageState.infoEntities;
  final topic = GlobalStore.currentTopicDef;
  final userName = GlobalStore.userInfo.userName;
  final currKeyName = _buildEntityKeyName(topic.topicName, pageNo, '');
  try {
    var infoEntities =
        forceUpdate ? null : await _loadLocalEntitiesPage(currKeyName);
    if (infoEntities != null) return infoEntities;
    infoEntities = await InfoNavServices.getInfoEntities(
        topic.topicFirst ? userName : topic.bgKeyword,
        topic.topicKeyword,
        "",
        ParamNames.defaultRelationTypeParam,
        ParamNames.defaultEntityTypeParam,
        pageNo,
        Constants.pageSize,
        Constants.cacheFlagEntity,
        topic.topicFirst);
    await _saveLocalEntitiesPage(currKeyName, infoEntities);
    return infoEntities;
  } catch (err) {
    GlobalStore.store
        .dispatch(GlobalReducerCreator.setErrorStatusReducer(true));
    return null;
  }
}

Future<List<InfoEntity>> _getFilteredInfoEntities(
    InfoNavPageState pageState, bool firstPage,
    {bool forceUpdate = false}) async {
  if (GlobalStore.hasError) return pageState.infoEntities;
  final userName = GlobalStore.userInfo.userName;
  final pageNo = firstPage ? 0 : pageState.nextPageNo;
  final condition = pageState.filterKeywords ?? '';
  final topic = GlobalStore.currentTopicDef;
  final currKeyName = _buildEntityKeyName(topic.topicName, pageNo, condition);
  try {
    var infoEntities =
        forceUpdate ? null : await _loadLocalEntitiesPage(currKeyName);
    if (infoEntities != null) return infoEntities;
    infoEntities = await InfoNavServices.getFilteredInfoEntities(
        topic.topicFirst ? userName : topic.bgKeyword,
        "${topic.indexKeyword}_",
        ParamNames.defaultRelationTypeParam,
        "$condition",
        ParamNames.defaultEntityTypeParam,
        false,
        pageNo,
        Constants.pageSize,
        Constants.cacheFlagEntity,
        topic.topicFirst);
    await _saveLocalEntitiesPage(currKeyName, infoEntities);
    return infoEntities;
  } catch (err) {
    GlobalStore.store
        .dispatch(GlobalReducerCreator.setErrorStatusReducer(true));
    return null;
  }
}

Future<List<InfoEntity>> _reloadFilteredInfoEntities(
    InfoNavPageState pageState, int pageNo) async {
  if (GlobalStore.hasError) return pageState.infoEntities;
  final condition = pageState.filterKeywords ?? '';
  final topic = GlobalStore.currentTopicDef;
  final currKeyName = _buildEntityKeyName(topic.topicName, pageNo, condition);
  try {
    final infoEntities = await InfoNavServices.getFilteredInfoEntities(
        topic.bgKeyword,
        "${topic.indexKeyword}_",
        ParamNames.defaultRelationTypeParam,
        "$condition",
        ParamNames.defaultEntityTypeParam,
        false,
        pageNo,
        Constants.pageSize,
        false,
        topic.topicFirst);
    await _saveLocalEntitiesPage(currKeyName, infoEntities);
    return infoEntities;
  } catch (err) {
    GlobalStore.store
        .dispatch(GlobalReducerCreator.setErrorStatusReducer(true));
    return null;
  }
}

Future<List<InfoEntity>> _getHistoryInfoEntities(
    InfoNavPageState pageState, int pageNo) async {
  if (GlobalStore.hasError) return pageState.infoEntities;
  final condition = pageState.filterKeywords ?? '';
  final userName = GlobalStore.userInfo.userName;
  final currKeyName =
      _buildEntityKeyName(Constants.historyEntity, pageNo, condition);
  try {
    var infoEntities = await _loadLocalEntitiesPage(currKeyName);
    if (infoEntities != null) return infoEntities;
    infoEntities = await InfoNavServices.getInfoEntityViewHistoryList(
        userName, pageNo, Constants.pageSize, Constants.cacheFlagEntity);
    await _saveLocalEntitiesPage(currKeyName, infoEntities);
    return infoEntities;
  } catch (err) {
    GlobalStore.store
        .dispatch(GlobalReducerCreator.setErrorStatusReducer(true));
    return null;
  }
}

Future<List<InfoEntity>> _getFilteredHistoryInfoEntities(
    InfoNavPageState pageState, String filterKeywords, int pageNo) async {
  if (GlobalStore.hasError) return pageState.infoEntities;
  final condition = pageState.filterKeywords ?? '';
  final userName = GlobalStore.userInfo.userName;
  final currKeyName =
      _buildEntityKeyName(Constants.historyEntity, pageNo, condition);
  try {
    var infoEntities = await _loadLocalEntitiesPage(currKeyName);
    if (infoEntities != null) return infoEntities;
    infoEntities = await InfoNavServices.getFilteredInfoEntityViewHistoryList(
        userName,
        filterKeywords,
        pageNo,
        Constants.pageSize,
        Constants.cacheFlagEntity);
    await _saveLocalEntitiesPage(currKeyName, infoEntities);
    return infoEntities;
  } catch (err) {
    GlobalStore.store
        .dispatch(GlobalReducerCreator.setErrorStatusReducer(true));
    return null;
  }
}

Future<List<InfoEntity>> _getFavoriteInfoEntities(
    InfoNavPageState pageState, int pageNo) async {
  if (GlobalStore.hasError) return pageState.infoEntities;
  final condition = pageState.filterKeywords ?? '';
  final userName = GlobalStore.userInfo.userName;
  final currKeyName =
      _buildEntityKeyName(Constants.favoriteEntity, pageNo, condition);
  try {
    var infoEntities = await _loadLocalEntitiesPage(currKeyName);
    if (infoEntities != null) return infoEntities;
    infoEntities = await InfoNavServices.getFavoriteInfoEntitiesByUserName(
        -1, userName, pageNo, Constants.pageSize, Constants.cacheFlagEntity);
    await _saveLocalEntitiesPage(currKeyName, infoEntities);
    return infoEntities;
  } catch (err) {
    GlobalStore.store
        .dispatch(GlobalReducerCreator.setErrorStatusReducer(true));
    return null;
  }
}

Future<List<InfoEntity>> _getFilteredFavoriteInfoEntities(
    InfoNavPageState pageState, String filterKeywords, int pageNo) async {
  if (GlobalStore.hasError) return pageState.infoEntities;
  final condition = pageState.filterKeywords ?? '';
  final userName = GlobalStore.userInfo.userName;
  final currKeyName =
      _buildEntityKeyName(Constants.favoriteEntity, pageNo, condition);
  try {
    var infoEntities = await _loadLocalEntitiesPage(currKeyName);
    if (infoEntities != null) return infoEntities;
    infoEntities =
        await InfoNavServices.getFilteredFavoriteInfoEntitiesByUserName(
            userName,
            filterKeywords,
            pageNo,
            Constants.pageSize,
            Constants.cacheFlagEntity);
    await _saveLocalEntitiesPage(currKeyName, infoEntities);
    return infoEntities;
  } catch (err) {
    GlobalStore.store
        .dispatch(GlobalReducerCreator.setErrorStatusReducer(true));
    return null;
  }
}

Future<List<InfoEntity>> _getSearchMatchingKeywords(
    InfoNavPageState pageState, String searchStr, int pageNo) async {
  if (GlobalStore.hasError) return pageState.infoEntities;
  final topicKeyword = GlobalStore.currentTopicDef.topicKeyword;
  final currKeyName = _buildEntityKeyName(
      Constants.searchKeyword + topicKeyword, pageNo, searchStr);
  try {
    var infoEntities = await _loadLocalEntitiesPage(currKeyName);
    if (infoEntities != null) return infoEntities;
    infoEntities = await InfoNavServices.getSearchingMatchedKeywords(
        topicKeyword,
        searchStr,
        pageNo,
        Constants.filterPageSize,
        Constants.cacheFlagEntity);
    _mergeMatchingKeywords(infoEntities);
    await _saveLocalEntitiesPage(currKeyName, infoEntities);
    return infoEntities;
  } catch (err) {
    GlobalStore.store
        .dispatch(GlobalReducerCreator.setErrorStatusReducer(true));
    return null;
  }
}

Future<List<InfoEntity>> _getSearchMatchingKeywordsFavorite(
    InfoNavPageState pageState, String searchStr, int pageNo) async {
  if (GlobalStore.hasError) return pageState.infoEntities;
  final userName = GlobalStore.userInfo.userName;
  final currKeyName = _buildEntityKeyName(
      Constants.searchKeyword + Constants.favoriteEntity, pageNo, searchStr);
  try {
    var infoEntities = await _loadLocalEntitiesPage(currKeyName);
    if (infoEntities != null) return infoEntities;
    infoEntities = await InfoNavServices.getSearchingMatchedKeywordsFavorite(
        userName,
        searchStr,
        pageNo,
        Constants.filterPageSize,
        Constants.cacheFlagEntity);
    _mergeMatchingKeywords(infoEntities);
    await _saveLocalEntitiesPage(currKeyName, infoEntities);
    return infoEntities;
  } catch (err) {
    GlobalStore.store
        .dispatch(GlobalReducerCreator.setErrorStatusReducer(true));
    return null;
  }
}

Future<List<InfoEntity>> _getSearchMatchingKeywordsHistory(
    InfoNavPageState pageState, String searchStr, int pageNo) async {
  if (GlobalStore.hasError) return pageState.infoEntities;
  final userName = GlobalStore.userInfo.userName;
  final currKeyName = _buildEntityKeyName(
      Constants.searchKeyword + Constants.historyEntity, pageNo, searchStr);
  try {
    var infoEntities = await _loadLocalEntitiesPage(currKeyName);
    if (infoEntities != null) return infoEntities;
    infoEntities = await InfoNavServices.getSearchingMatchedKeywordsHistory(
        userName,
        searchStr,
        pageNo,
        Constants.filterPageSize,
        Constants.cacheFlagEntity);
    _mergeMatchingKeywords(infoEntities);
    await _saveLocalEntitiesPage(currKeyName, infoEntities);
    return infoEntities;
  } catch (err) {
    GlobalStore.store
        .dispatch(GlobalReducerCreator.setErrorStatusReducer(true));
    return null;
  }
}

Future<List<InfoEntity>> _getRelatedTopics(
    InfoNavPageState pageState, String filterKeyword, int pageNo) async {
  if (GlobalStore.hasError) return pageState.infoEntities;
  final userName = GlobalStore.userInfo.userName;
  final topicKeyword = GlobalStore.currentTopicDef.topicKeyword;
  final condition = topicKeyword + '_' + filterKeyword;
  final currKeyName =
      _buildEntityKeyName(Constants.relatedTopic, pageNo, condition);
  try {
    var infoEntities = await _loadLocalEntitiesPage(currKeyName);
    if (infoEntities != null) return infoEntities;
    infoEntities = await InfoNavServices.getRelatedTopicEntities(
        userName,
        topicKeyword,
        filterKeyword,
        pageNo,
        Constants.pageSize,
        Constants.cacheFlagEntity);
    await _saveLocalEntitiesPage(currKeyName, infoEntities);
    return infoEntities;
  } catch (err) {
    GlobalStore.store
        .dispatch(GlobalReducerCreator.setErrorStatusReducer(true));
    return null;
  }
}

void _mergeMatchingKeywords(List<InfoEntity> infoEntities) {
  for (var i = 0; i < infoEntities.length; i++) {
    if (i % 2 == 1) continue;
    if (i + 1 < infoEntities.length) {
      infoEntities[i].title =
          '${infoEntities[i].title},${infoEntities[i + 1].title}';
      infoEntities[i + 1].keyId = -infoEntities[i + 1].keyId;
    }
  }
}

Future _checkLatestMessage(Context<InfoNavPageState> ctx) async {
  if (GlobalStore.hasError) return;
  try {
    var latestMessage = await InfoNavServices.getLatestPubMessage();
    if (latestMessage == null) return;
    var jsonString = await SharedUtil.instance.getString(Keys.latestMessage);
    if (jsonString != null) {
      var localMessage = PubMessage.fromJson(jsonDecode(jsonString));
      if (latestMessage.msgTitle == localMessage.msgTitle) return; // 已阅读
    }
    Dialogs.showMessageDialogWithButton(
        ctx.context, latestMessage.msgTitle, latestMessage.msgContent);
    await SharedUtil.instance
        .saveString(Keys.latestMessage, jsonEncode(latestMessage.toJson()));
  } catch (err) {
    GlobalStore.store
        .dispatch(GlobalReducerCreator.setErrorStatusReducer(true));
  }
}

Future<List<InfoEntity>> _loadLocalEntitiesPage(String currKeyName) async {
  final jsonString = await SharedUtil.instance.getString(currKeyName);
  if (jsonString != null) {
    final jsonItems = json.decode(jsonString);
    final infoEntities =
        jsonItems.map<InfoEntity>((item) => InfoEntity.fromJson(item)).toList();
    if (infoEntities != null && infoEntities.length > 0) return infoEntities;
  }
  return null;
}

Future _saveLocalEntitiesPage(
    String currKeyName, List<InfoEntity> infoEntities) async {
  if (infoEntities != null && infoEntities.length > 0) {
    await SharedUtil.instance.saveString(currKeyName, jsonEncode(infoEntities));
  }
}

String _buildEntityKeyName(String topicName, int pageNo, String condition) {
  return '${topicName}_entity_${pageNo}_$condition';
}

String _buildEntityTagNames(String orgTagNames) {
  var newTagNames = orgTagNames.replaceAll(' ', ',');
  newTagNames = newTagNames.replaceAll('，', ',');
  final tagList = newTagNames.split(',');
  tagList.removeWhere((tag) => tag == '');
  return tagList.join(',');
}

bool _isLoadingSuccess(List<InfoEntity> infoEntities) {
  if (GlobalStore.hasError) return false;
  var success = true;
  if (infoEntities == null) {
    try {
      InfoNavServices.clearDataCache();
    } catch (err) {}
  } else {
    _removeTopicIndex(infoEntities);
    success = infoEntities.length > 0;
  }
  return success;
}

Future _openInfoEntity(EntityState entityState) async {
  switch (entityState.infoDisplayer) {
    case ParamNames.browserUrlType:
      await Tools.openUrl(entityState.subtitle);
      break;
  }
}

bool _isLoading(InfoNavPageState state) {
  if (state.isLoading && Environment.isInDebugMode) {
    final bgColor = GlobalStore.themePrimaryIcon;
    Dialogs.showInfoToast('数据加载中...', bgColor);
  }
  return state.isLoading;
}

String _getNewFilterKeywords(String filterKeywords, String tag) {
  if (filterKeywords == null || filterKeywords == '') return tag;
  var filterList = filterKeywords.split(',');
  if (filterList.indexOf(tag) >= 0) {
    filterList.remove(tag);
  } else {
    filterList.add(tag);
  }
  return filterList.join(',');
}

Future<List<InfoEntity>> _getSearchMatchingKeywordsFirstPage(
    Context<InfoNavPageState> ctx, String searchStr) async {
  List<InfoEntity> infoEntities;
  switch (GlobalStore.sourceType) {
    case SourceType.favorite:
      infoEntities =
          await _getSearchMatchingKeywordsFavorite(ctx.state, searchStr, 0);
      break;
    case SourceType.history:
      infoEntities =
          await _getSearchMatchingKeywordsHistory(ctx.state, searchStr, 0);
      break;
    default:
      infoEntities = await _getSearchMatchingKeywords(ctx.state, searchStr, 0);
      break;
  }
  return infoEntities;
}

Future<List<InfoEntity>> _getSearchMatchingKeywordsNextPage(
    Context<InfoNavPageState> ctx, String searchStr) async {
  final nextPageNo = ctx.state.nextPageNo;
  List<InfoEntity> infoEntities;
  switch (GlobalStore.sourceType) {
    case SourceType.favorite:
      infoEntities = await _getSearchMatchingKeywordsFavorite(
          ctx.state, searchStr, nextPageNo);
      break;
    case SourceType.history:
      infoEntities = await _getSearchMatchingKeywordsHistory(
          ctx.state, searchStr, nextPageNo);
      break;
    default:
      infoEntities =
          await _getSearchMatchingKeywords(ctx.state, searchStr, nextPageNo);
      break;
  }
  return infoEntities;
}

void _addInfoEntityTagsToPage(
    Context<InfoNavPageState> ctx, int entityId, String tagNames) {
  final entityState = ctx.state.getInfoEntityById(entityId);
  if (entityState != null) {
    final index = entityState.id;
    final tagParam = {
      ParamNames.indexParam: index,
      ParamNames.tagParam: tagNames
    };
    ctx.dispatch(InfoEntityReducerCreator.addEntityTagsReducer(tagParam));
    ctx.dispatch(InfoNavPageReducerCreator.updateEntityItemReducer(index));
  }
}

void _delInfoEntityTagFromPage(
    Context<InfoNavPageState> ctx, int entityId, String tagName) {
  final entityState = ctx.state.getInfoEntityById(entityId);
  if (entityState != null) {
    final index = entityState.id;
    final tagParam = {
      ParamNames.indexParam: index,
      ParamNames.tagParam: tagName
    };
    ctx.dispatch(InfoEntityReducerCreator.delEntityTagReducer(tagParam));
    ctx.dispatch(InfoNavPageReducerCreator.updateEntityItemReducer(index));
  }
}

Future _clearInfoEntityCache(InfoNavPageState pageState) async {
  final condition = pageState.filterKeywords ?? '';
  final topicName = GlobalStore.currentTopicDef.topicName;
  for (var i = 0; i < pageState.nextPageNo; i++) {
    var keyName = _buildEntityKeyName(topicName, i, condition);
    await SharedUtil.instance.removeString(keyName);
  }
  try {
    InfoNavServices.clearDataCache();
  } catch (err) {}
}

void _changeSourceContentType(SourceType sourceType, ContentType contentType,
    Context<InfoNavPageState> ctx) {
  GlobalStore.store
      .dispatch(GlobalReducerCreator.setSourceTypeReducer(sourceType));
  GlobalStore.store
      .dispatch(GlobalReducerCreator.setContentTypeReducer(contentType));
}

void _jumpToListTop(InfoNavPageState state) {
  final scrollController = state.scrollController;
  if (!GlobalStore.hasError && scrollController.hasClients) {
    scrollController.jumpTo(scrollController.position.minScrollExtent);
  }
}

void _removeTopicIndex(List<InfoEntity> infoEntities) {
  if (GlobalStore.currentTopicDef.topicName == Constants.topIndexName) {
    infoEntities
        .removeWhere((entity) => entity.title == Constants.topIndexName);
  }
}

String _buildKeywordNavKeyName() {
  final sourceType = GlobalStore.sourceType.toString();
  final topicName = GlobalStore.currentTopicDef.topicName;
  return Keys.currentKeywordNav + sourceType + topicName;
}
