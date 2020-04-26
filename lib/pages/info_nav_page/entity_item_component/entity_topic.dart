import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart';

import '../../../global_store/global_store.dart';
import '../../widgets/single_widgets.dart';
import '../info_nav_action.dart';
import 'entity_standard.dart';
import 'entity_state.dart';

GestureDetector buildEntityBodyTopic(
    EntityState entityState, Dispatch dispatch, ViewService viewService) {
  final Color itemBackgroundColor =
      entityState.pressed ? Colors.grey[200] : GlobalStore.themeItemBackground;
  final isKeywordNav = entityState.isKeywordNav;
  return GestureDetector(
    child: Container(
        padding: const EdgeInsets.all(5.0),
        decoration: buildShadowBox(itemBackgroundColor, Colors.grey[300], 6.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildEntityTitleTopic(entityState, dispatch, viewService),
          _buildTopicContentSection(entityState, dispatch, viewService),
          isKeywordNav ? SizedBox() : buildScrollTagsRow(entityState, dispatch),
        ]),
        alignment: AlignmentDirectional.centerStart),
    onTap: () => onTopicTitlePressed(entityState, dispatch, viewService),
    onLongPress: () => onEntityLongPressed(entityState, dispatch),
  );
}

Widget _buildEntityTitleTopic(
    EntityState entityState, Dispatch dispatch, ViewService viewService) {
  return Row(children: [
    buildIcon(Icons.menu, color: GlobalStore.themePrimaryIcon),
    Expanded(child: buildEntityTitleText(entityState))
  ]);
}

Widget _buildTopicContentSection(
    EntityState entityState, Dispatch dispatch, ViewService viewService) {
  switch (entityState.displayMode) {
    case DisplayMode.entityAction:
      return buildEntityActionSection(entityState, dispatch, viewService);
    case DisplayMode.tagAction:
      return buildTagActionSection(entityState, dispatch, viewService);
    default:
      return _buildTopicOverviewText(entityState);
  }
}

void onTopicTitlePressed(
    EntityState entityState, Dispatch dispatch, ViewService viewService) async {
  final int topicId = int.tryParse(entityState.subtitle);
  if (topicId != null) {
    dispatch(InfoNavPageActionCreator.onChangeTopicDef(topicId));
  }
}

Widget _buildTopicOverviewText(EntityState entityState) {
  var subtitle = entityState.overview != null ? entityState.overview : '';
  if (subtitle.isNotEmpty)
    return Text(subtitle,
        style: GlobalStore.subtitleStyle, softWrap: true, maxLines: 5);
  return SizedBox();
}
