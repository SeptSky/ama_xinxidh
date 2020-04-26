import 'package:fish_redux/fish_redux.dart';

import '../../models/entities/info_entity.dart';
import 'entity_item_component/entity_state.dart';

enum InfoNavPageActionEnum {
  onRefreshPage,
  onSetFilteredKeyword,
  onChangeTopicDef,
  onJumpToTopicDef,
  onInfoEntityPressed,
  onParagraphPressed,
  onTagPressed,
  onToggleKeywordNav,
  onAddInfoEntity,
  onEditInfoEntity,
  onDelInfoEntity,
  onAddInfoEntityTags,
  onDelInfoEntityTag,
  onSharePageUrl,
  onClearCache,
  onShowNormal,
  onShowHistory,
  onShowFavorite,
  onFavoriteInfoEntity,
  onSetSearchMode,
  onSearchMatching,
  onClearSearchText,
}

enum InfoNavPageReducerEnum {
  initEntitiesReducer,
  setPrevPageEntitiesReducer,
  setNextPageEntitiesReducer,
  setJumpPageEntitiesReducer,
  setIsLoadingFlagReducer,
  setFilteredKeywordReducer,
  setJumpCompletedFlagReducer,
  setIsKeywordNavReducer,
  setAutoSearchReducer,
  updateEntityItemReducer,
}

class InfoNavPageActionCreator {
  static Action onRefreshPage() {
    return Action(InfoNavPageActionEnum.onRefreshPage);
  }

  static Action onSetFilteredKeyword(String filteredKeywords) {
    return Action(InfoNavPageActionEnum.onSetFilteredKeyword,
        payload: filteredKeywords);
  }

  static Action onChangeTopicDef(int topicId) {
    return Action(InfoNavPageActionEnum.onChangeTopicDef, payload: topicId);
  }

  static Action onJumpToTopicDef(String topicName) {
    return Action(InfoNavPageActionEnum.onJumpToTopicDef, payload: topicName);
  }

  static Action onInfoEntityPressed(EntityState entityState) {
    return Action(InfoNavPageActionEnum.onInfoEntityPressed,
        payload: entityState);
  }

  static Action onParagraphPressed(int entityId) {
    return Action(InfoNavPageActionEnum.onParagraphPressed, payload: entityId);
  }

  static Action onTagPressed(String tag) {
    return Action(InfoNavPageActionEnum.onTagPressed, payload: tag);
  }

  static Action onToggleKeywordNav(bool isKeywordNav) {
    return Action(InfoNavPageActionEnum.onToggleKeywordNav,
        payload: isKeywordNav);
  }

  static Action onAddInfoEntity(dynamic addEntityParam) {
    return Action(InfoNavPageActionEnum.onAddInfoEntity,
        payload: addEntityParam);
  }

  static Action onEditInfoEntity(dynamic editEntityParam) {
    return Action(InfoNavPageActionEnum.onEditInfoEntity,
        payload: editEntityParam);
  }

  static Action onDelInfoEntity(int entityId) {
    return Action(InfoNavPageActionEnum.onDelInfoEntity, payload: entityId);
  }

  static Action onAddInfoEntityTags(dynamic addTagParam) {
    return Action(InfoNavPageActionEnum.onAddInfoEntityTags,
        payload: addTagParam);
  }

  static Action onDelInfoEntityTag(dynamic delTagParam) {
    return Action(InfoNavPageActionEnum.onDelInfoEntityTag,
        payload: delTagParam);
  }

  static Action onSharePageUrl(EntityState entity) {
    return Action(InfoNavPageActionEnum.onSharePageUrl, payload: entity);
  }

  static Action onClearCache() {
    return Action(InfoNavPageActionEnum.onClearCache);
  }

  static Action onShowNormal() {
    return const Action(InfoNavPageActionEnum.onShowNormal);
  }

  static Action onShowHistory() {
    return const Action(InfoNavPageActionEnum.onShowHistory);
  }

  static Action onShowFavorite() {
    return const Action(InfoNavPageActionEnum.onShowFavorite);
  }

  static Action onFavoriteInfoEntity(EntityState entityState) {
    return Action(InfoNavPageActionEnum.onFavoriteInfoEntity,
        payload: entityState);
  }

  static Action onSetSearchMode(bool searchMode) {
    return Action(InfoNavPageActionEnum.onSetSearchMode, payload: searchMode);
  }

  static Action onSearchMatching(String searchStr) {
    return Action(InfoNavPageActionEnum.onSearchMatching, payload: searchStr);
  }

  static Action onClearSearchText() {
    return Action(InfoNavPageActionEnum.onClearSearchText);
  }
}

class InfoNavPageReducerCreator {
  static Action initEntitiesReducer(List<InfoEntity> infoEntities) {
    return Action(InfoNavPageReducerEnum.initEntitiesReducer,
        payload: infoEntities);
  }

  static Action setPrevPageEntitiesReducer(List<InfoEntity> infoEntities) {
    return Action(InfoNavPageReducerEnum.setPrevPageEntitiesReducer,
        payload: infoEntities);
  }

  static Action setNextPageEntitiesReducer(List<InfoEntity> infoEntities) {
    return Action(InfoNavPageReducerEnum.setNextPageEntitiesReducer,
        payload: infoEntities);
  }

  static Action setJumpPageEntitiesReducer(dynamic infoEntityPack) {
    return Action(InfoNavPageReducerEnum.setJumpPageEntitiesReducer,
        payload: infoEntityPack);
  }

  static Action setIsLoadingFlagReducer(bool isLoading) {
    return Action(InfoNavPageReducerEnum.setIsLoadingFlagReducer,
        payload: isLoading);
  }

  static Action setFilteredKeywordReducer(String filteredKeyword) {
    return Action(InfoNavPageReducerEnum.setFilteredKeywordReducer,
        payload: filteredKeyword);
  }

  static Action setJumpCompletedFlagReducer() {
    return Action(InfoNavPageReducerEnum.setJumpCompletedFlagReducer);
  }

  static Action setIsKeywordNavReducer(bool isKeywordNav) {
    return Action(InfoNavPageReducerEnum.setIsKeywordNavReducer,
        payload: isKeywordNav);
  }

  static Action setAutoSearchReducer(bool autoSearch) {
    return Action(InfoNavPageReducerEnum.setAutoSearchReducer,
        payload: autoSearch);
  }

  static Action updateEntityItemReducer(int index) {
    return Action(InfoNavPageReducerEnum.updateEntityItemReducer,
        payload: index);
  }
}
