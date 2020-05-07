import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action;

import '../../common/consts/constants.dart';
import '../../common/consts/page_names.dart';
import '../../common/consts/param_names.dart';
import '../../global_store/global_store.dart';
import '../route.dart';
import '../widgets/marquee.dart';
import '../widgets/single_widgets.dart';
import 'keyword_item_component/keyword_action.dart';
import 'keyword_nav_action.dart';
import 'keyword_nav_state.dart';

/// 状态数据变化刷新页面的本质：就是底层自动调用buildView方法，将变化的数据传入刷新界面
Widget buildView(
    KeywordNavPageState state, Dispatch dispatch, ViewService viewService) {
  final bool hasError = GlobalStore.hasError;
  return Scaffold(
    body: Container(
      alignment: Alignment.center,
      child: Column(
        children: <Widget>[
          _buildFilterHeaderBar(),
          hasError
              ? _buildFilterErrorBox(dispatch)
              : _buildFilterPaginationGridView(state, dispatch, viewService),
          _buildFilterBottomBar(state, dispatch, viewService),
        ],
      ),
    ),
  );
}

/// 创建带分页功能的特征词表格
Expanded _buildFilterPaginationGridView(
    KeywordNavPageState state, Dispatch dispatch, ViewService viewService) {
  final colCount = state.getGridColCount();
  return colCount == Constants.maxColCount
      ? _buildFullGridView(state, viewService, colCount)
      : _buildNavGridView(state, viewService, colCount);
}

Expanded _buildFullGridView(
    KeywordNavPageState state, ViewService viewService, int colCount) {
  return Expanded(child: _buildGridViewBody(state, viewService, colCount));
}

Widget _buildNavGridView(
    KeywordNavPageState state, ViewService viewService, int colCount) {
  final filterKeywords = state.getPressedPropertyFilterText();
  return Expanded(
      child: Row(children: [
    Container(
        width: 160, child: _buildGridViewBody(state, viewService, colCount)),
    Expanded(
        child: routes.buildPage(PageNames.keywordRelatedPage,
            {ParamNames.filterKeywordsParam: filterKeywords}))
  ]));
}

GridView _buildGridViewBody(
    KeywordNavPageState state, ViewService viewService, int colCount) {
  final adapter = viewService.buildAdapter();
  final itemCount = adapter.itemCount;
  return GridView.builder(
      gridDelegate: _buildGridStyle(state.keywordMode, colCount),
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
      itemCount: itemCount + 1);
}

Expanded _buildFilterErrorBox(Dispatch dispatch) {
  return Expanded(
      child: buildErrorBox(
          () => dispatch(KeywordNavPageActionCreator.onRefreshPage())));
}

Container _buildFilterHeaderBar() {
  return Container(
    padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
    color: GlobalStore.themePrimaryBackground,
  );
}

SliverGridDelegateWithFixedCrossAxisCount _buildGridStyle(
    bool keywordMode, int colCount) {
  final ratio = colCount == Constants.maxColCount ? 3.0 : 4.5;
  return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: keywordMode ? colCount : colCount * 2,
      mainAxisSpacing: 3,
      crossAxisSpacing: 0,
      childAspectRatio: keywordMode ? ratio : ratio / 2);
}

Container _buildFilterBottomBar(
    KeywordNavPageState state, Dispatch dispatch, ViewService viewService) {
  var pressedFilterCount = state.getPressedPropertyFilterCount();
  return Container(
    height: 40,
    color: GlobalStore.themePrimaryBackground,
    child: Row(
      children: [
        const SizedBox(width: 10),
        _buildResetButton(dispatch, viewService),
        const SizedBox(width: 10),
        _buildFilterButtonRow(pressedFilterCount, state, dispatch, viewService),
        _buildHintInfoMarquee(pressedFilterCount, state.keywordMode),
        const SizedBox(width: 10),
        _buildAlphabetKeywordButton(state, dispatch, viewService),
        const SizedBox(width: 10),
      ],
    ),
  );
}

Container _buildFilterActionBar(
    KeywordNavPageState state, Dispatch dispatch, ViewService viewService) {
  var pressedFilterCount = state.getPressedPropertyFilterCount();
  return Container(
    height: 40,
    color: GlobalStore.themePrimaryBackground,
    child: Row(
      children: [
        const SizedBox(width: 10),
        _buildResetButton(dispatch, viewService),
        const SizedBox(width: 10),
        _buildFilterButtonRow(pressedFilterCount, state, dispatch, viewService),
        _buildHintInfoMarquee(pressedFilterCount, state.keywordMode),
        const SizedBox(width: 10),
        _buildAlphabetKeywordButton(state, dispatch, viewService),
        const SizedBox(width: 10),
      ],
    ),
  );
}

Widget _buildFilterButtonRow(int pressedFilterCount, KeywordNavPageState state,
    Dispatch dispatch, ViewService viewService) {
  if (pressedFilterCount >= 2) {
    return _buildScrollableFilterButtonRow(state, dispatch, viewService);
  } else if (pressedFilterCount >= 1) {
    return _buildStaticFilterButtonRow(state, dispatch, viewService);
  }
  return SizedBox();
}

Expanded _buildScrollableFilterButtonRow(
    KeywordNavPageState state, Dispatch dispatch, ViewService viewService) {
  var pressedFilters = state.getPressedPropertyFilterList();
  return Expanded(
      child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          child: Row(
            children: pressedFilters.map((filter) {
              return Row(
                children: <Widget>[
                  _buildFilterButton(
                      filter.title, filter.index, dispatch, viewService),
                  const SizedBox(width: 10),
                ],
              );
            }).toList(),
          )));
}

Row _buildStaticFilterButtonRow(
    KeywordNavPageState state, Dispatch dispatch, ViewService viewService) {
  var pressedFilters = state.getPressedPropertyFilterList();
  return Row(
    children: pressedFilters.map((filter) {
      return Row(
        children: <Widget>[
          _buildFilterButton(filter.title, filter.index, dispatch, viewService),
          const SizedBox(width: 10),
        ],
      );
    }).toList(),
  );
}

Widget _buildHintInfoMarquee(int filterCount, bool keywordMode) {
  var hintInfo = '';
  switch (filterCount) {
    case 0:
      hintInfo = keywordMode ? '点击右侧按钮切换字母检索模式！   ' : '点击右侧按钮切换特征检索模式！   ';
      break;
    case 1:
      hintInfo = '点击其它特征词实现组合筛选!    ';
      break;
    default:
      return SizedBox();
  }
  return Expanded(
      child: Marquee(
    style: TextStyle(fontSize: 14, color: GlobalStore.themeBlack),
    pauseAfterRound: Duration(seconds: 2),
    text: hintInfo,
  ));
}

InkWell _buildFilterButton(
    String title, int index, Dispatch dispatch, ViewService viewService) {
  var color = GlobalStore.themeBlack;
  return InkWell(
    child: Container(
        padding: const EdgeInsets.all(4),
        decoration: buildCommonBox(null, color, 6.0),
        child: Row(
          children: <Widget>[
            Text(title, style: TextStyle(fontSize: 12, color: color)),
            const SizedBox(width: 4),
            buildIcon(Icons.cancel, margin: 0, size: 16, color: color)
          ],
        )),
    onTap: () {
      dispatch(KeywordReducerCreator.cancelFilterReducer(index));
      // 跨页面调用InfoNavPage的Effect行为
      dispatch(KeywordNavPageActionCreator.onCancelFilterAction(index));
    },
  );
}

InkWell _buildResetButton(Dispatch dispatch, ViewService viewService) {
  var color = GlobalStore.themeBlack;
  return InkWell(
    child: Container(
      padding: const EdgeInsets.all(4),
      decoration: buildCommonBox(null, color, 6.0),
      child: Text('重置', style: TextStyle(fontSize: 12, color: color)),
    ),
    onTap: () {
      dispatch(KeywordNavPageActionCreator.onResetFilterAction());
    },
  );
}

Widget _buildAlphabetKeywordButton(
    KeywordNavPageState state, Dispatch dispatch, ViewService viewService) {
  if (GlobalStore.appConfig.topic == null) return SizedBox();
  final color = GlobalStore.themeBlack;
  final keywordMode = state.keywordMode;
  final iconName = keywordMode ? Icons.sort_by_alpha : Icons.category;
  return InkWell(
    child: Container(
        padding: const EdgeInsets.all(4),
        decoration: buildCommonBox(null, color, 6.0),
        child: buildIcon(iconName, margin: 0, size: 16, color: color)),
    onTap: () {
      dispatch(
          KeywordNavPageReducerCreator.setKeywordModeReducer(!keywordMode));
      if (keywordMode) {
        dispatch(KeywordNavPageActionCreator.onShowPyCodes());
      } else {
        dispatch(KeywordNavPageActionCreator.onShowFilters());
      }
    },
  );
}
