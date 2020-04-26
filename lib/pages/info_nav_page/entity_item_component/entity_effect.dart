import 'dart:ui';

import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action;

import '../../../common/consts/page_names.dart';
import '../../../common/consts/param_names.dart';
import '../info_nav_action.dart';
import '../info_nav_state.dart';
import 'entity_action.dart';
import 'entity_state.dart';

Effect<EntityState> buildEffect() {
  return combineEffects(<Object, Effect<EntityState>>{
    InfoEntityAction.onEdit: _onEdit,
    InfoEntityAction.onRemove: _onRemove,
    InfoEntityAction.onScrollToEntity: _onScrollToEntity,
  });
}

void _onEdit(Action action, Context<EntityState> ctx) {
  if (action.payload == ctx.state.keyId) {
    Navigator.of(ctx.context)
        .pushNamed(PageNames.entityEditPage, arguments: ctx.state)
        .then((dynamic entity) {
      if (entity != null) {
        ctx.dispatch(InfoEntityActionCreator.editAction(entity));
      }
    });
  }
}

void _onRemove(Action action, Context<EntityState> ctx) async {
  final String select = await showDialog<String>(
      context: ctx.context,
      builder: (BuildContext buildContext) {
        return AlertDialog(
          title: Text('Are you sure to delete "${ctx.state.title}"?'),
          actions: <Widget>[
            GestureDetector(
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 16.0),
              ),
              onTap: () => Navigator.of(buildContext).pop(),
            ),
            GestureDetector(
              child: const Text('Yes', style: TextStyle(fontSize: 16.0)),
              onTap: () => Navigator.of(buildContext).pop('Yes'),
            )
          ],
        );
      });

  if (select == 'Yes') {
    ctx.dispatch(InfoEntityActionCreator.onScrollToEntity(ctx.state.keyId));
  }
}

void _onScrollToEntity(Action action, Context<EntityState> ctx) {
  final int entityId = action.payload[ParamNames.entityIdParam];
  final Context<InfoNavPageState> parentContext =
      action.payload[ParamNames.contextParam];
  if (entityId == ctx.state.keyId) {
    _scrollToEntity(ctx, parentContext, 80.0, ctx.state.pressed);
    ctx.dispatch(InfoNavPageReducerCreator.setJumpCompletedFlagReducer());
  } else if (!parentContext.state.jumpComplete) {
    _scrollToEntity(ctx, parentContext, -80.0, ctx.state.pressed);
  }
}

void _scrollToEntity(Context<EntityState> childContext,
    Context<InfoNavPageState> parentContext, double offsetY, bool pressed) {
  final ScrollController scrollController =
      parentContext.state.scrollController;
  final RenderBox box = childContext.context.findRenderObject();
  final Offset offset = box.localToGlobal(Offset.zero);
  if (pressed) {
    final Duration duration = Duration(milliseconds: 500);
    scrollController.animateTo(offset.dy - offsetY,
        duration: duration, curve: Curves.decelerate);
  } else {
    scrollController.jumpTo(offset.dy - offsetY);
  }
}
