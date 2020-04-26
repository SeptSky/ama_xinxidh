import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action;

import '../../../common/consts/enum_types.dart';
import '../../../global_store/global_store.dart';
import 'entity_keyword.dart';
import 'entity_page_link.dart';
import 'entity_paragraph.dart';
import 'entity_standard.dart';
import 'entity_state.dart';
import 'entity_topic.dart';

Widget buildView(
  EntityState entityState,
  Dispatch dispatch,
  ViewService viewService,
) {
  return buildEntityItem(entityState, dispatch, viewService);
}

Container buildEntityItem(
    EntityState entityState, Dispatch dispatch, ViewService viewService) {
  return Container(
    padding: buildEntityItemPadding(entityState.infoDisplayer),
    child: buildInfoEntityBody(entityState, dispatch, viewService),
  );
}

EdgeInsets buildEntityItemPadding(String infoDisplayer) {
  switch (infoDisplayer) {
    case EntityType.paragraphType:
    case EntityType.paragraphUrlType:
      return null;
    default:
      return const EdgeInsets.all(2.0);
  }
}

Widget buildInfoEntityBody(
    EntityState entityState, Dispatch dispatch, ViewService viewService) {
  try {
    switch (entityState.infoDisplayer) {
      case EntityType.topicDefType:
        if (GlobalStore.contentType == ContentType.pageLink) {
          return buildEntityBodyPageLink(entityState, dispatch, viewService);
        }
        return buildEntityBodyTopic(entityState, dispatch, viewService);
      case EntityType.paragraphType:
      case EntityType.paragraphUrlType:
        return buildEntityBodyParagraph(entityState, dispatch, viewService);
      case EntityType.keywordType:
        return buildEntityBodyKeyword(entityState, dispatch, viewService);
      default:
        if (GlobalStore.contentType == ContentType.pageLink) {
          return buildEntityBodyPageLink(entityState, dispatch, viewService);
        }
        return buildEntityBody(entityState, dispatch, viewService);
    }
  } catch (err) {
    return SizedBox();
  }
}
