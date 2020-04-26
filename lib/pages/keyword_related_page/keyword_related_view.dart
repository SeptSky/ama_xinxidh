import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action;

import '../../global_store/global_store.dart';
import '../widgets/single_widgets.dart';
import 'keyword_related_state.dart';

/// 状态数据变化刷新页面的本质：就是底层自动调用buildView方法，将变化的数据传入刷新界面
Widget buildView(
    KeywordRelatedPageState state, Dispatch dispatch, ViewService viewService) {
  return Scaffold(
    body: Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          _buildFilterPaginationGridView(state, dispatch, viewService)
        ],
      ),
    ),
  );
}

/// 创建带分页功能的特征词表格
Expanded _buildFilterPaginationGridView(
    KeywordRelatedPageState state, Dispatch dispatch, ViewService viewService) {
  final adapter = viewService.buildAdapter();
  final itemCount = adapter.itemCount;
  // if (itemCount == 0) {
  //   return Expanded(child: buildNotFoundBox(() {}));
  // }
  return Expanded(
      child: GridView.builder(
          gridDelegate: _buildGridStyle(),
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

/// 创建带分页功能的特征词列表
Expanded _buildFilterPaginationListView(
    KeywordRelatedPageState state, Dispatch dispatch, ViewService viewService) {
  final ListAdapter adapter = viewService.buildAdapter();
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

SliverGridDelegateWithFixedCrossAxisCount _buildGridStyle() {
  return const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 1,
      mainAxisSpacing: 3,
      crossAxisSpacing: 0,
      childAspectRatio: 5.65);
}
