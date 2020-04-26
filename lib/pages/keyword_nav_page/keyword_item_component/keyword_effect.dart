import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action;

import '../../../common/consts/page_names.dart';
import '../../../common/consts/param_names.dart';
import '../../keyword_related_page/keyword_related_state.dart';
import 'keyword_action.dart';
import 'keyword_state.dart';

Effect<KeywordState> buildEffect() {
  return combineEffects(<Object, Effect<KeywordState>>{
    KeywordAction.onEdit: _onEdit,
    KeywordAction.onRemove: _onRemove,
    KeywordAction.onScrollToKeyword: _onScrollToKeyword,
  });
}

void _onEdit(Action action, Context<KeywordState> ctx) {
  if (action.payload == ctx.state.keyId) {
    Navigator.of(ctx.context)
        .pushNamed(PageNames.keywordEditPage, arguments: ctx.state)
        .then((dynamic keyword) {
      if (keyword != null) {
        ctx.dispatch(KeywordActionCreator.editAction(keyword));
      }
    });
  }
}

void _onRemove(Action action, Context<KeywordState> ctx) async {
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
    ctx.dispatch(KeywordActionCreator.removeAction(ctx.state.keyId));
  }
}

void _onScrollToKeyword(Action action, Context<KeywordState> ctx) {
  final int keywordId = action.payload[ParamNames.keywordIdParam];
  final Context<KeywordRelatedPageState> parentContext =
      action.payload[ParamNames.contextParam];
  final pressedKeyword = parentContext.state.getPressedKeyword();
  if (keywordId == pressedKeyword.keyId) {
    _scrollToKeyword(ctx, parentContext, pressedKeyword.index);
  }
}

void _scrollToKeyword(Context<KeywordState> childContext,
    Context<KeywordRelatedPageState> parentContext, int index) {
  final scrollController = parentContext.state.scrollController;
  final RenderBox box = childContext.context.findRenderObject();
  final Duration duration = Duration(milliseconds: 500);
  scrollController.animateTo(index * box.size.height,
      duration: duration, curve: Curves.decelerate);
}
