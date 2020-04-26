import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart';

import '../../../global_store/global_store.dart';
import '../../widgets/single_widgets.dart';
import '../info_nav_action.dart';
import 'entity_state.dart';
import 'entity_topic.dart';

Widget buildEntityBodyPageLink(
    EntityState entityState, Dispatch dispatch, ViewService viewService) {
  if (entityState.keyId < 0) return SizedBox();
  return Container(
      decoration: buildCommonBox(null, Colors.grey[300], 6.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildEntityTitleKeyword(entityState, dispatch, viewService),
      ]),
      alignment: AlignmentDirectional.centerStart);
}

Widget _buildEntityTitleKeyword(
    EntityState entityState, Dispatch dispatch, ViewService viewService) {
  final pageTitles = entityState.title.split(',');
  return Row(children: [
    buildIcon(Icons.category, color: GlobalStore.themePrimaryIcon),
    Expanded(
        child: _buildPageLinkCell(
            pageTitles[0], entityState, dispatch, viewService)),
    pageTitles.length > 1
        ? buildIcon(Icons.category, color: GlobalStore.themePrimaryIcon)
        : SizedBox(),
    pageTitles.length > 1
        ? Expanded(
            child: _buildPageLinkCell(
                pageTitles[1], entityState, dispatch, viewService))
        : SizedBox(),
  ]);
}

Widget _buildPageLinkCell(String pageTitle, EntityState entityState,
    Dispatch dispatch, ViewService viewService) {
  return GestureDetector(
    child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        child: Text('$pageTitle', style: GlobalStore.titleStyle)),
    onTap: () => _onPageLinkPressed(entityState, dispatch, viewService),
  );
}

void _onPageLinkPressed(
    EntityState entityState, Dispatch dispatch, ViewService viewService) async {
  if (entityState.infoDisplayer == EntityType.topicDefType) {
    onTopicTitlePressed(entityState, dispatch, viewService);
  } else {
    dispatch(InfoNavPageActionCreator.onInfoEntityPressed(entityState));
  }
}
