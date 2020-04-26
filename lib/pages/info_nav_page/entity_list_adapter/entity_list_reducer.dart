import 'package:fish_redux/fish_redux.dart';

import '../../../common/consts/constants.dart';
import '../../../models/entities/info_entity.dart';
import '../info_nav_state.dart';
import 'entity_list_action.dart';

Reducer<InfoNavPageState> buildReducer() {
  return asReducer(<Object, Reducer<InfoNavPageState>>{
    InfoEntityReducerEnum.addEntity: _addEntity,
    InfoEntityReducerEnum.addEntities: _addEntities,
    InfoEntityReducerEnum.removeEntity: _removeEntity
  });
}

InfoNavPageState _addEntity(InfoNavPageState state, Action action) {
  final InfoEntity infoEntity = action.payload;
  return state.clone()..infoEntities = (state.infoEntities..add(infoEntity));
}

InfoNavPageState _addEntities(InfoNavPageState state, Action action) {
  final List<InfoEntity> infoEntities = action.payload;
  if (infoEntities.isNotEmpty && state.infoEntities.length == Constants.pageSize) {
    final InfoNavPageState newState = state.clone();
    newState.infoEntities.addAll(infoEntities);
    return newState;
  }
  return state;
}

InfoNavPageState _removeEntity(InfoNavPageState state, Action action) {
  final int keyId = action.payload;
  return state.clone()
    ..infoEntities = (state.infoEntities
      ..removeWhere((InfoEntity state) => state.keyId == keyId));
}
