import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../common/consts/constants.dart';
import '../../../common/utilities/tools.dart';
import '../../../global_store/global_store.dart';
import '../info_nav_action.dart';
import 'entity_standard.dart';
import 'entity_state.dart';

GestureDetector buildEntityBodyParagraph(
    EntityState entityState, Dispatch dispatch, ViewService viewService) {
  return GestureDetector(
    child: Container(
      padding: const EdgeInsets.all(3.0),
      color: Colors.yellow[100],
      constraints: const BoxConstraints(minHeight: 10),
      child: _buildParagraphBodyWithTags(entityState, dispatch, viewService),
    ),
    onTap: () => onParagraphPressed(entityState, dispatch, viewService),
    onLongPress: () => onEntityLongPressed(entityState, dispatch),
  );
}

Widget _buildParagraphBodyWithTags(
    EntityState entityState, Dispatch dispatch, ViewService viewService) {
  final tagShown = _isTagShown(entityState);
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _buildParagraphBody(entityState, dispatch),
    _buildParagraphContentSection(entityState, dispatch, viewService),
    tagShown ? buildScrollTagsRow(entityState, dispatch) : SizedBox(),
  ]);
}

Widget _buildParagraphBody(EntityState entityState, Dispatch dispatch) {
  return MarkdownBody(
      selectable: entityState.selectable &&
          entityState.infoDisplayer == EntityType.paragraphType,
      data: entityState.overview,
      onTapLink: (url) => Tools.openUrl(url));
}

Widget _buildParagraphContentSection(
    EntityState entityState, Dispatch dispatch, ViewService viewService) {
  switch (entityState.displayMode) {
    case DisplayMode.entityAction:
      return buildEntityActionSection(entityState, dispatch, viewService);
    case DisplayMode.tagAction:
      return buildTagActionSection(entityState, dispatch, viewService);
    default:
      return SizedBox();
  }
}

bool _isTagShown(EntityState entityState) {
  final filterKeywords = GlobalStore.filterKeywords;
  var tagShown = filterKeywords != null &&
      filterKeywords != '' &&
      !entityState.isKeywordNav;
  if (tagShown) {
    var filterList = filterKeywords.split(',');
    filterList.removeWhere((filter) => filter == Constants.refReadingMode);
    if (filterList.length == 0) {
      tagShown = false;
    }
  }
  return tagShown;
}

void onParagraphPressed(
    EntityState entityState, Dispatch dispatch, ViewService viewService) async {
  final int entityId = entityState.keyId;
  dispatch(InfoNavPageActionCreator.onParagraphPressed(entityId));
}
