import 'package:fish_redux/fish_redux.dart';

import 'entity_state.dart';

enum InfoEntityAction { onEdit, edit, done, onRemove, onScrollToEntity }

class InfoEntityActionCreator {
  static Action onEditAction(int keyId) {
    return Action(InfoEntityAction.onEdit, payload: keyId);
  }

  static Action editAction(EntityState infoEntity) {
    return Action(InfoEntityAction.edit, payload: infoEntity);
  }

  static Action doneAction(int keyId) {
    return Action(InfoEntityAction.done, payload: keyId);
  }

  static Action onRemoveAction(int keyId) {
    return Action(InfoEntityAction.onRemove, payload: keyId);
  }

  static Action onScrollToEntity(dynamic params) {
    return Action(InfoEntityAction.onScrollToEntity, payload: params);
  }
}

enum InfoEntityReducerEnum {
  setPressedFlagReducer,
  setFilteredKeywordReducer,
  setDisplayModeReducer,
  toggleFavoriteReducer,
  addEntityTagsReducer,
  delEntityTagReducer,
}

class InfoEntityReducerCreator {
  static Action setPressedFlagReducer(int index) {
    return Action(InfoEntityReducerEnum.setPressedFlagReducer, payload: index);
  }

  static Action setFilteredKeywordReducer(String filterKeywords) {
    return Action(InfoEntityReducerEnum.setFilteredKeywordReducer,
        payload: filterKeywords);
  }

  static Action setDisplayModeReducer(dynamic displayMode) {
    return Action(InfoEntityReducerEnum.setDisplayModeReducer,
        payload: displayMode);
  }

  static Action toggleFavoriteReducer(int index) {
    return Action(InfoEntityReducerEnum.toggleFavoriteReducer, payload: index);
  }

  static Action addEntityTagsReducer(dynamic tagParam) {
    return Action(InfoEntityReducerEnum.addEntityTagsReducer,
        payload: tagParam);
  }

  static Action delEntityTagReducer(dynamic tagParam) {
    return Action(InfoEntityReducerEnum.delEntityTagReducer, payload: tagParam);
  }
}
