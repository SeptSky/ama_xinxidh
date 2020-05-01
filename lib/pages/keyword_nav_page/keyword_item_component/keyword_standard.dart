import 'package:amainfoindex/common/utilities/dialogs.dart';
import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart';

import '../../../common/consts/enum_types.dart';
import '../../../global_store/global_action.dart';
import '../../../global_store/global_store.dart';
import '../../info_nav_page/info_nav_action.dart';
import '../../keyword_related_page/keyword_related_action.dart';
import '../../widgets/single_widgets.dart';
import '../keyword_item_component/keyword_action.dart';
import '../keyword_item_component/keyword_state.dart';
import '../keyword_nav_action.dart';

Container buildKeywordBody(
    KeywordState keywordState, Dispatch dispatch, ViewService viewService) {
  var itemBackgroundColor = GlobalStore.isLoadingWebData && keywordState.pressed
      ? Colors.grey[200]
      : GlobalStore.themeItemBackground;
  if (keywordState.isProperty == false) {
    itemBackgroundColor = Colors.yellow[100];
  }
  return Container(
    padding: const EdgeInsets.all(0.0),
    decoration: buildCommonBox(itemBackgroundColor, Colors.grey[300], 6.0),
    // 关键词在单元格内垂直居中对齐
    child:
        Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      buildKeywordTitle(keywordState, dispatch, viewService),
    ]),
  );
}

Container buildKeywordTitle(
    KeywordState keywordState, Dispatch dispatch, ViewService viewService) {
  var statusIconName = Icons.keyboard_arrow_right;
  var filterIconName = Icons.category;
  if (keywordState.isProperty == false) {
    statusIconName = keywordState.pressed ? Icons.cancel : null;
    filterIconName = keywordState.pressed ? Icons.folder_open : Icons.folder;
  } else if (keywordState.isProperty == null) {
    statusIconName = null;
    filterIconName = Icons.vpn_key;
  }
  final showActionIcon =
      keywordState.keyId > 0 && GlobalStore.sourceType == SourceType.normal;
  return Container(
    child: Row(children: [
      _buildKeywordTitle(filterIconName, keywordState, dispatch, viewService),
      showActionIcon
          ? _buildKeywordActionIcon(
              keywordState, dispatch, viewService, statusIconName)
          : SizedBox(),
    ]),
  );
}

Widget _buildKeywordTitle(IconData iconName, KeywordState keywordState,
    Dispatch dispatch, ViewService viewService) {
  final bgColor = GlobalStore.themePrimaryIcon;
  return Expanded(
      child: InkWell(
          child: _buildKeywordButton(iconName, keywordState),
          onTap:
              _buildKeywordTitleTapAction(keywordState, dispatch, viewService),
          onLongPress: () =>
              Dialogs.showInfoToast(keywordState.title, bgColor)));
}

Function _buildKeywordTitleTapAction(
    KeywordState keywordState, Dispatch dispatch, ViewService viewService) {
  if (keywordState.keyId < 0) {
    return () => _onAlphabetPressed(keywordState, dispatch, viewService);
  } else if (keywordState.isProperty == true) {
    return () => _onAddKeywordIconPressed(keywordState, dispatch, viewService);
  } else if (keywordState.isProperty == false) {
    return () => _onKeywordTitlePressed(keywordState, dispatch, viewService);
  }
  return () => _onTriggerRelatedKeywords(keywordState, dispatch, viewService);
}

Widget _buildKeywordActionIcon(KeywordState keywordState, Dispatch dispatch,
    ViewService viewService, IconData statusIconName) {
  final iconColor = GlobalStore.themePrimaryIcon;
  if (keywordState.isProperty == true) {
    return buildIconWithTap(statusIconName,
        () => _onKeywordTitlePressed(keywordState, dispatch, viewService),
        color: iconColor);
  } else if (keywordState.isProperty == false) {
    return buildIconWithTap(statusIconName,
        () => _onUnpresseParentFilter(keywordState, dispatch, viewService),
        color: iconColor);
  }
  return SizedBox();
}

void _onAlphabetPressed(
    KeywordState keywordState, Dispatch dispatch, ViewService viewService) {
  dispatch(KeywordReducerCreator.pressFilterReducer(keywordState.index));
  viewService
      .broadcast(InfoNavPageActionCreator.onSearchMatching(keywordState.title));
}

void _onKeywordTitlePressed(
    KeywordState keywordState, Dispatch dispatch, ViewService viewService) {
  if (keywordState.isProperty == false && keywordState.pressed) {
    _onUnpresseParentFilter(keywordState, dispatch, viewService);
    return;
  }
  if (keywordState.isProperty == true) {
    GlobalStore.store
        .dispatch(GlobalReducerCreator.setWebLoadingStatusReducer(true));
  }
  // 负责修改符合条件Item的状态，并取消已经press的状态
  dispatch(KeywordReducerCreator.pressFilterReducer(keywordState.index));
  // 修改Item状态，并跨页面调用InfoNavPage的Effect行为
  dispatch(KeywordNavPageActionCreator.onPressFilterAction(keywordState.title));
}

void _onAddKeywordIconPressed(
    KeywordState keywordState, Dispatch dispatch, ViewService viewService) {
  final index = keywordState.index;
  if (keywordState.pressed) {
    dispatch(KeywordReducerCreator.cancelFilterReducer(index));
    dispatch(KeywordNavPageActionCreator.onCancelFilterAction(index));
  } else {
    GlobalStore.store
        .dispatch(GlobalReducerCreator.setWebLoadingStatusReducer(true));
    dispatch(KeywordReducerCreator.combineFilterReducer(index));
    dispatch(KeywordNavPageActionCreator.onCombineFilterAction());
  }
}

void _onTriggerRelatedKeywords(
    KeywordState keywordState, Dispatch dispatch, ViewService viewService) {
  dispatch(KeywordRelatedPageActionCreator.onPressKeywordAction(keywordState));
}

void _onUnpresseParentFilter(
    KeywordState keywordState, Dispatch dispatch, ViewService viewService) {
  dispatch(KeywordReducerCreator.unpressParentReducer(keywordState.index));
  dispatch(KeywordNavPageActionCreator.onUnpressParentAction());
}

Widget _buildKeywordButton(IconData iconName, KeywordState keywordState) {
  return Row(
    children: [
      buildIcon(iconName, size: 14, color: GlobalStore.themePrimaryIcon),
      Expanded(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          child: Text(
            '${keywordState.title}',
            style: keywordState.pressed
                ? GlobalStore.keywordStyle.copyWith(fontWeight: FontWeight.bold)
                : GlobalStore.keywordStyle,
          ),
        ),
      ),
    ],
  );
}

/// 创建不带分页功能的关键词列表
Expanded buildKeywordListView(ViewService viewService) {
  final adapter = viewService.buildAdapter();
  return Expanded(
      child: ListView.builder(
          itemBuilder: adapter.itemBuilder, itemCount: adapter.itemCount));
}
