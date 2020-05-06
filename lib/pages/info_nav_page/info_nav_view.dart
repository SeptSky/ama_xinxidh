import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action;

import '../../common/consts/constants.dart';
import '../../common/consts/enum_types.dart';
import '../../common/utilities/keyboard_detector.dart';
import '../../common/utilities/tools.dart';
import '../../global_store/global_action.dart';
import '../../global_store/global_store.dart';
import '../home_page/home_action.dart';
import '../widgets/single_widgets.dart';
import 'entity_item_component/entity_state.dart';
import 'info_nav_action.dart';
import 'info_nav_state.dart';

/// 状态数据变化刷新页面的本质：就是底层自动调用buildView方法，将变化的数据传入刷新界面
Widget buildView(
    InfoNavPageState state, Dispatch dispatch, ViewService viewService) {
  var title = _getInfoNavTitle(state);
  if (state.filterKeywords != null && state.filterKeywords != '') {
    title = "组合条件：${state.filterKeywords}";
  }
  final searchMode = GlobalStore.searchMode;
  final showShortIcon =
      !searchMode && !state.hasParagraph() && !state.hasEntityKeyword();
  return Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: searchMode
          ? _buildInfoNavSearchBar(state, dispatch, viewService)
          : _buildInfoNavTitle(state, title),
      actions: [
        _buildAppBarSearchIcon(state, dispatch, viewService),
        showShortIcon
            ? _buildAppBarShortIcon(state, dispatch, viewService)
            : SizedBox(),
      ],
    ),
    body: Container(
        alignment: Alignment.center, // 用于错误提示显示的居中
        child: _buildInfoNavContent(state, dispatch, viewService)),
  );
}

Widget _buildInfoNavTitle(InfoNavPageState state, String title) {
  final bool isEmpty = Tools.hasNotElements(state.infoEntities);
  if (isEmpty) return Text(title);
  if (isEmpty ||
      // GlobalStore.contentType == ContentType.keyword ||
      state.infoEntities[0].infoDisplayer == EntityType.paragraphType ||
      state.infoEntities[0].infoDisplayer == EntityType.paragraphUrlType) {
    return Text(title);
  }
  var hasMoreEntities = state.infoEntities.length % Constants.pageSize == 0;
  if (!state.hasMoreEntities && state.nextPageNo == 0) {
    hasMoreEntities = false;
  }
  String subtitle = hasMoreEntities
      ? '已加载${state.infoEntities.length}条，上滑加载更多...'
      : '总共${state.infoEntities.length}条';
  return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [Text(title), Text(subtitle, style: TextStyle(fontSize: 16))]);
}

Widget _buildAppBarSearchIcon(
    InfoNavPageState state, Dispatch dispatch, ViewService viewService) {
  final searchMode = !GlobalStore.searchMode;
  final iconName = searchMode ? Icons.search : Icons.arrow_upward;
  return GestureDetector(
      child: Row(children: [Icon(iconName), SizedBox(width: 10)]),
      onTap: () {
        GlobalStore.store
            .dispatch(GlobalReducerCreator.setSearchModeReducer(searchMode));
      });
}

Widget _buildAppBarShortIcon(
    InfoNavPageState state, Dispatch dispatch, ViewService viewService) {
  final shortMode = GlobalStore.contentType == ContentType.pageLink;
  final iconName = shortMode ? Icons.menu : Icons.short_text;
  return GestureDetector(
      child: Row(children: [Icon(iconName), SizedBox(width: 10)]),
      onTap: () {
        final newContentType =
            shortMode ? ContentType.infoEntity : ContentType.pageLink;
        GlobalStore.store.dispatch(
            GlobalReducerCreator.setContentTypeReducer(newContentType));
      });
}

Widget _buildInfoNavSearchBar(
    InfoNavPageState state, Dispatch dispatch, ViewService viewService) {
  return KeyboardDetector(
      content: _buildSearchBarBody(state, dispatch, viewService),
      keyboardShowCallback: (isShown) {
        _onKeyboardTrigger(state, viewService);
      });
}

Widget _buildInfoNavContent(
    InfoNavPageState state, Dispatch dispatch, ViewService viewService) {
  final hasError = GlobalStore.hasError;
  var hasData = !GlobalStore.searchMode ||
      state.infoEntities != null && state.infoEntities.length > 0;
  if (hasData && state.topicEmpty) {
    hasData = false;
  }
  var contentWidget;
  if (hasError) {
    contentWidget = _buildEntityErrorBox(dispatch);
  } else {
    contentWidget = hasData
        ? _buildEntityPaginationListView(state, dispatch, viewService)
        : _buildEntityNotFoundBox(state, dispatch);
  }
  return Column(children: [contentWidget]);
}

Widget _buildEntityNotFoundBox(InfoNavPageState state, Dispatch dispatch) {
  var hintText = state.autoSearch ? '在专题内未找到特征标签，按搜索键查找明细！' : '在专题内未找到匹配信息！';
  if (state.topicEmpty) {
    hintText = '专题内容添加中……';
  }
  return buildNotFoundBox(hintText, () {
    state.textController.clear();
    dispatch(InfoNavPageActionCreator.onSetFilteredKeyword(null));
  });
}

Widget _buildEntityErrorBox(Dispatch dispatch) {
  return buildErrorBox(
      () => dispatch(InfoNavPageActionCreator.onRefreshPage()));
}

/// 创建带分页功能的信息实体列表
Expanded _buildEntityPaginationListView(
    InfoNavPageState state, Dispatch dispatch, ViewService viewService) {
  final adapter = viewService.buildAdapter();
  int itemCount = adapter.itemCount;
  return Expanded(
      child: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            if (index == itemCount) {
              return buildProgressIndicator(
                  state.isLoading, GlobalStore.themePrimaryIcon);
            } else {
              return adapter.itemBuilder(viewService.context, index);
            }
          },
          controller: state.scrollController,
          // +1 for progressbar
          itemCount: itemCount + 1));
}

Widget _buildSearchBarBody(
    InfoNavPageState state, Dispatch dispatch, ViewService viewService) {
  final controller = state.textController;
  return Card(
      child: Container(
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
    const SizedBox(width: 5.0),
    const Icon(Icons.search, color: Colors.grey),
    Expanded(
        child: Container(
            child: TextField(
      controller: controller,
      autofocus: true,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.only(top: 0.0),
          hintText: _getSearchHintText(state),
          border: InputBorder.none),
      onChanged: (text) => _onChanged(text, dispatch),
      onSubmitted: (text) => _onSubmitted(text, dispatch),
    ))),
    IconButton(
        icon: Icon(Icons.cancel),
        color: Colors.grey,
        iconSize: 18.0,
        onPressed: () => dispatch(InfoNavPageActionCreator.onClearSearchText()))
  ])));
}

void _onChanged(String searchText, Dispatch dispatch) {
  if (searchText.trim().isEmpty) {
    dispatch(InfoNavPageActionCreator.onClearSearchText());
    return;
  }
  final searchStr = _preprocessSearchStr(searchText);
  dispatch(InfoNavPageActionCreator.onSearchMatching(searchStr));
  dispatch(InfoNavPageReducerCreator.setAutoSearchReducer(true));
}

void _onSubmitted(String searchText, Dispatch dispatch) {
  if (searchText.trim().isEmpty) {
    dispatch(InfoNavPageActionCreator.onClearSearchText());
    return;
  }
  final searchStr = _preprocessSearchStr(searchText);
  dispatch(InfoNavPageActionCreator.onSetFilteredKeyword(searchStr));
  dispatch(InfoNavPageReducerCreator.setAutoSearchReducer(false));
}

void _onKeyboardTrigger(InfoNavPageState state, ViewService viewService,
    {bool showButton}) {
  try {
    if (state.isKeywordNav) {
      viewService.broadcast(HomeReducerCreator.toggleIconReducer(0));
      viewService.broadcast(InfoNavPageActionCreator.onToggleKeywordNav(false));
      if (Navigator.of(viewService.context).canPop()) {
        Navigator.of(viewService.context).pop();
      }
    }
  } catch (err) {}
}

String _preprocessSearchStr(String searchText) {
  final keywordList = searchText.trim().split(' ');
  final searchStr = keywordList.join(',');
  return searchStr;
}

String _getSearchHintText(InfoNavPageState state) {
  switch (GlobalStore.sourceType) {
    case SourceType.history:
      return '在历史浏览中搜索';
    case SourceType.favorite:
      return '在我的收藏中搜索';
    default:
      return '在当前专题中搜索';
  }
}

String _getInfoNavTitle(InfoNavPageState state) {
  switch (GlobalStore.sourceType) {
    case SourceType.history:
      return '历史浏览信息';
    case SourceType.favorite:
      return '我的收藏信息';
    default:
      return GlobalStore.currentTopicDef.topicName;
  }
}
