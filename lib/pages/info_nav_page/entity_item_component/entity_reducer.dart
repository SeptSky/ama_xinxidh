import 'package:fish_redux/fish_redux.dart';

import '../../../common/consts/param_names.dart';
import 'entity_action.dart';
import 'entity_state.dart';

Reducer<EntityState> buildReducer() {
  return asReducer(<Object, Reducer<EntityState>>{
    InfoEntityAction.edit: _edit,
    InfoEntityAction.done: _markDone,
    InfoEntityReducerEnum.setPressedFlagReducer: _setPressedFlagReducer,
    InfoEntityReducerEnum.setDisplayModeReducer: _setDisplayModeReducer,
    InfoEntityReducerEnum.toggleFavoriteReducer: _toggleFavoriteReducer,
    InfoEntityReducerEnum.addEntityTagsReducer: _addEntityTagsReducer,
    InfoEntityReducerEnum.delEntityTagReducer: _delEntityTagReducer,
  });
}

EntityState _edit(EntityState entity, Action action) {
  final EntityState newEntity = action.payload;
  if (entity.keyId == newEntity.keyId) {
    return entity.clone()
      ..title = newEntity.title
      ..subtitle = newEntity.subtitle;
  }
  return entity;
}

EntityState _markDone(EntityState entity, Action action) {
  final int keyId = action.payload;
  if (entity.keyId == keyId) {
    // return entity.clone()..enabled = !entity.enabled;
  }
  return entity;
}

EntityState _setPressedFlagReducer(EntityState entityState, Action action) {
  final int index = action.payload;
  // 无状态变化的Item不需要Clone操作
  if (index == null || !entityState.pressed && entityState.index != index) {
    return entityState;
  }
  final newEntityState = entityState.clone()
    ..pressed = index == entityState.index;
  return newEntityState;
}

EntityState _setDisplayModeReducer(EntityState entityState, Action action) {
  final int index = action.payload[ParamNames.indexParam];
  final DisplayMode displayMode = action.payload[ParamNames.displayModeParam];
  final String tag = action.payload[ParamNames.tagParam];
  final newEntityState = entityState.clone();
  if (entityState.index == index) {
    newEntityState.performedTag = tag;
    newEntityState.displayMode = displayMode;
  } else {
    newEntityState.performedTag = null;
    newEntityState.displayMode = DisplayMode.normal;
  }
  return newEntityState;
}

EntityState _toggleFavoriteReducer(EntityState entityState, Action action) {
  final int index = action.payload;
  if (entityState.index == index) {
    final newEntityState = entityState.clone();
    newEntityState.favorite = !entityState.favorite;
    return newEntityState;
  }
  return entityState;
}

EntityState _addEntityTagsReducer(EntityState entityState, Action action) {
  final int index = action.payload[ParamNames.indexParam];
  if (entityState.index != index) {
    return entityState;
  }
  final String newTags = action.payload[ParamNames.tagParam];
  var oldTags = entityState.entityTags;
  final newEntityState = entityState.clone()
    ..entityTags = oldTags + ',' + newTags;
  return newEntityState;
}

EntityState _delEntityTagReducer(EntityState entityState, Action action) {
  final int index = action.payload[ParamNames.indexParam];
  if (entityState.index != index) {
    return entityState;
  }
  final String tag = action.payload[ParamNames.tagParam];
  var oldTagList = entityState.entityTags.split(',');
  oldTagList.removeWhere((oldTag) => oldTag == tag);
  final newTags = oldTagList.join(',');
  final newEntityState = entityState.clone()..entityTags = newTags;
  return newEntityState;
}
