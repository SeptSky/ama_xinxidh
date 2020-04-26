import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';

import '../../common/consts/enum_types.dart';
import '../../common/consts/page_names.dart';
import '../../common/consts/param_names.dart';
import '../../common/i10n/localization_intl.dart';
import '../../global_store/global_store.dart';
import '../info_nav_page/info_nav_action.dart';
import '../keyword_nav_page/keyword_nav_action.dart';
import '../route.dart';
import '../widgets/nav_floating_button.dart';
import '../widgets/smart_drawer.dart';
import 'home_action.dart';
import 'home_state.dart';

/// Fish-Redux要求界面定义与逻辑分离
/// 状态数据变化刷新页面的本质：就是底层自动调用buildView方法，将变化的数据传入刷新界面
Widget buildView(HomeState state, Dispatch dispatch, ViewService viewService) {
  var navPageName = state.isFirstRun
      ? PageNames.introPage
      : GlobalStore.currentTopicDef.navPageName;
  return WillPopScope(
    child: Scaffold(
      body: routes.buildPage(navPageName, null),
      drawer: state.isFirstRun
          ? null
          : SmartDrawer(child: routes.buildPage(PageNames.menuPage, null)),
      floatingActionButton: _buildFloatingButton(state, dispatch, viewService),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    ),
    onWillPop: () async {
      var params = <String, dynamic>{
        ParamNames.lastTimeParam: state.lastPopTime,
        ParamNames.keywordSwitchParam: state.iconQuarterTurns,
      };
      dispatch(HomeActionCreator.onProcessBackKey(params));
      return state.acceptBackPressing;
    },
  );
}

// 此处使用Builder函数是为了传入正确的Context of Scaffold，而不能使用viewService.context
Builder _buildFloatingButton(
    HomeState state, Dispatch dispatch, ViewService viewService) {
  if (state.isFirstRun || GlobalStore.searchMode) return null; // 不显示导航按钮
  return Builder(builder: (context) {
    YYDialog.init(context);
    return Row(
      children: [
        SizedBox(width: 10),
        _buildHistoryButton(state, dispatch, viewService, context),
        SizedBox(width: 10),
        Expanded(
            child: _buildKeywordButton(state, dispatch, viewService, context)),
        SizedBox(width: 10),
        _buildFavoriteButton(state, dispatch, viewService, context),
        SizedBox(width: 10),
      ],
    );
  });
}

Widget _buildHistoryButton(HomeState state, Dispatch dispatch,
    ViewService viewService, BuildContext context) {
  final color = GlobalStore.themePrimaryBackground;
  return NavFloatingButton(
    iconName: Icons.history,
    color: color,
    isActive: GlobalStore.sourceType == SourceType.history,
    onTap: () {
      viewService
          .broadcast(InfoNavPageActionCreator.onSetFilteredKeyword(null));
      if (GlobalStore.sourceType != SourceType.history) {
        viewService.broadcast(InfoNavPageActionCreator.onShowHistory());
      } else {
        _toggleKeywordSheet(context, state.iconQuarterTurns, dispatch);
      }
      if (state.iconQuarterTurns == 2) {
        viewService.broadcast(KeywordNavPageActionCreator.onRefreshPage());
      }
    },
  );
}

Widget _buildFavoriteButton(HomeState state, Dispatch dispatch,
    ViewService viewService, BuildContext context) {
  final color = GlobalStore.themePrimaryBackground;
  return NavFloatingButton(
    iconName: Icons.star,
    color: color,
    isActive: GlobalStore.sourceType == SourceType.favorite,
    onTap: () {
      viewService
          .broadcast(InfoNavPageActionCreator.onSetFilteredKeyword(null));
      if (GlobalStore.sourceType != SourceType.favorite) {
        viewService.broadcast(InfoNavPageActionCreator.onShowFavorite());
      } else {
        _toggleKeywordSheet(context, state.iconQuarterTurns, dispatch);
      }
      if (state.iconQuarterTurns == 2) {
        viewService.broadcast(KeywordNavPageActionCreator.onRefreshPage());
      }
    },
  );
}

Widget _buildKeywordButton(HomeState state, Dispatch dispatch,
    ViewService viewService, BuildContext context) {
  final color = GlobalStore.themePrimaryBackground;
  return NavFloatingButton(
    title: LinuxLocalizations.of(context).characterIndex,
    iconName: Icons.navigation,
    iconQuarterTurns: state.iconQuarterTurns,
    color: color,
    isActive: GlobalStore.sourceType == SourceType.normal,
    onTap: () {
      if (GlobalStore.sourceType != SourceType.normal) {
        viewService.broadcast(InfoNavPageActionCreator.onShowNormal());
      } else {
        _toggleKeywordSheet(context, state.iconQuarterTurns, dispatch);
      }
      if (state.iconQuarterTurns == 2) {
        viewService.broadcast(KeywordNavPageActionCreator.onRefreshPage());
      }
    },
    onLongTap: () {
      dispatch(HomeActionCreator.onOpenDrawer(context));
    },
  );
}

void _toggleKeywordSheet(
    BuildContext context, int iconQuarterTurns, Dispatch dispatch) {
  var params = <String, dynamic>{
    ParamNames.contextParam: context,
    ParamNames.keywordSwitchParam: iconQuarterTurns,
  };
  dispatch(HomeActionCreator.onToggleKeywordSheet(params));
}
