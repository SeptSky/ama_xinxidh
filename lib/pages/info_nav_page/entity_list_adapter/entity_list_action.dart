import 'package:fish_redux/fish_redux.dart';

import '../../../models/entities/info_entity.dart';

enum InfoEntityReducerEnum {
  addEntity,
  addEntities,
  removeEntity,
}

class InfoEntityReducerCreator {
  static Action addEntity(InfoEntity state) {
    return Action(InfoEntityReducerEnum.addEntity, payload: state);
  }

  static Action addEntities(List<InfoEntity> entities) {
    return Action(InfoEntityReducerEnum.addEntities, payload: entities);
  }

  static Action removeEntity(int keyId) {
    return Action(InfoEntityReducerEnum.removeEntity, payload: keyId);
  }
}
