import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action;

import '../../models/entities/info_entity.dart';
import 'entity_edit_action.dart';
import 'entity_edit_state.dart';

Effect<EntityEditState> buildEffect() {
  return combineEffects(<Object, Effect<EntityEditState>>{
    EntityEditActionEnum.onDone: _onDone,
    EntityEditActionEnum.onChangeTheme: _onChangeTheme,
  });
}

/// 关闭页面并返回最新数据对象
void _onDone(Action action, Context<EntityEditState> ctx) {
  Navigator.of(ctx.context).pop<InfoEntity>(
    ctx.state.infoEntity.clone()
      ..subtitle = ctx.state.descEditController.text
      ..title = ctx.state.nameEditController.text,
  );
}

void _onChangeTheme(Action action, Context<EntityEditState> ctx) {
}
