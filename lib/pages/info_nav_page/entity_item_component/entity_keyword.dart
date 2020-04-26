import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart';

import '../../../common/utilities/dialogs.dart';
import '../../../global_store/global_store.dart';
import '../../widgets/single_widgets.dart';
import '../info_nav_action.dart';
import 'entity_state.dart';

Widget buildEntityBodyKeyword(
    EntityState entityState, Dispatch dispatch, ViewService viewService) {
  if (entityState.keyId < 0) return SizedBox();
  return Container(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildEntityTitleKeyword(entityState, dispatch, viewService),
      ]),
      alignment: AlignmentDirectional.centerStart);
}

Widget _buildEntityTitleKeyword(
    EntityState entityState, Dispatch dispatch, ViewService viewService) {
  final keywords = entityState.title.split(',');
  return Row(children: [
    buildIcon(Icons.category, color: GlobalStore.themePrimaryIcon),
    Expanded(child: _buildKeywordCell(keywords[0], dispatch)),
    keywords.length > 1
        ? buildIcon(Icons.category, color: GlobalStore.themePrimaryIcon)
        : SizedBox(),
    keywords.length > 1
        ? Expanded(child: _buildKeywordCell(keywords[1], dispatch))
        : SizedBox(),
  ]);
}

Widget _buildKeywordCell(String keyword, Dispatch dispatch) {
  return GestureDetector(
    child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        child: Text('$keyword', style: GlobalStore.titleStyle)),
    onTap: () => _onKeywordTitlePressed(keyword, dispatch),
  );
}

void _onKeywordTitlePressed(String keyword, Dispatch dispatch) async {
  final bgColor = GlobalStore.themePrimaryIcon;
  Dialogs.showInfoToast(keyword, bgColor);
  dispatch(InfoNavPageActionCreator.onSetFilteredKeyword(keyword));
}
