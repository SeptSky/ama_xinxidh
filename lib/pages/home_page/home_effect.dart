import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:flutter/services.dart';

import '../../common/consts/constants.dart';
import '../../common/consts/enum_types.dart';
import '../../common/consts/keys.dart';
import '../../common/consts/page_names.dart';
import '../../common/consts/param_names.dart';
import '../../common/i10n/localization_intl.dart';
import '../../common/utilities/dialogs.dart';
import '../../common/utilities/shared_util.dart';
import '../../global_store/global_action.dart';
import '../../global_store/global_store.dart';
import '../info_nav_page/entity_list_adapter/entity_list_action.dart';
import '../info_nav_page/info_nav_action.dart';
import '../keyword_nav_page/keyword_nav_action.dart';
import '../route.dart';
import 'home_action.dart';
import 'home_state.dart';

Effect<HomeState> buildEffect() {
  return combineEffects(<Object, Effect<HomeState>>{
    HomeActionEnum.onStartupApp: _onStartupApp,
    HomeActionEnum.onProcessBackKey: _processBackKey,
    HomeActionEnum.onToggleKeywordSheet: _onToggleKeywordSheet,
    HomeActionEnum.onCloseKeywordSheet: _onCloseKeywordSheet,
    HomeActionEnum.onSetHasFilters: _onSetHasFilters,
    HomeActionEnum.onOpenDrawer: _openDrawer,
    HomeActionEnum.onAddEntity: _onAddEntity,
    HomeActionEnum.onChangeUser: _onChangeUser,
  });
}

void _onStartupApp(Action action, Context<HomeState> ctx) async {
  ctx.dispatch(HomeReducerCreator.startupAppReducer());
  await SharedUtil.instance.saveBoolean(Keys.isFirstRun, false);
}

void _processBackKey(Action action, Context<HomeState> ctx) {
  final int iconQuarterTurns = action.payload[ParamNames.keywordSwitchParam];
  if (iconQuarterTurns != 0) {
    ctx.dispatch(HomeReducerCreator.toggleIconReducer(0));
    _toggleKeywordNav(0, ctx);
    return;
  }
  if (ctx.state.hasFilters) {
    if (!GlobalStore.searchMode) {
      ctx.broadcast(InfoNavPageActionCreator.onSetFilteredKeyword(null));
    } else {
      // null代表重新搜索文本框内已存在的关键词；''代表清除搜索关键词
      ctx.broadcast(InfoNavPageActionCreator.onSearchMatching(null));
    }
    _toggleKeywordNav(0, ctx);
    return;
  }
  if (GlobalStore.searchMode) {
    ctx.broadcast(InfoNavPageActionCreator.onSetSearchMode(false));
    ctx.broadcast(InfoNavPageActionCreator.onClearSearchText());
    GlobalStore.store
        .dispatch(GlobalReducerCreator.setSourceTypeReducer(SourceType.normal));
    GlobalStore.store.dispatch(
        GlobalReducerCreator.setContentTypeReducer(ContentType.infoEntity));
    return;
  }
  if (GlobalStore.sourceType != SourceType.normal ||
      GlobalStore.contentType != ContentType.infoEntity) {
    ctx.broadcast(InfoNavPageActionCreator.onShowNormal());
    GlobalStore.store
        .dispatch(GlobalReducerCreator.setSourceTypeReducer(SourceType.normal));
    GlobalStore.store.dispatch(
        GlobalReducerCreator.setContentTypeReducer(ContentType.infoEntity));
    return;
  }
  final prevTopic = GlobalStore.popTopic();
  if (prevTopic != null) {
    ctx.broadcast(InfoNavPageActionCreator.onChangeTopicDef(prevTopic.topicId));
    _toggleKeywordNav(0, ctx);
    return;
  }
  if (GlobalStore.currentTopicDef.topicName != Constants.topIndexName) {
    ctx.broadcast(InfoNavPageActionCreator.onChangeTopicDef(-1));
    _toggleKeywordNav(0, ctx);
    return;
  }
  DateTime lastPopTime = action.payload[ParamNames.lastTimeParam];
  if (lastPopTime == null ||
      DateTime.now().difference(lastPopTime) > Duration(seconds: 2)) {
    ctx.dispatch(HomeReducerCreator.setLastPopTimeReducer(DateTime.now()));
    final bgColor = GlobalStore.themePrimaryIcon;
    Dialogs.showInfoToast(
        LinuxLocalizations.of(ctx.context).pressBackAgain, bgColor);
  } else {
    Future.delayed(Duration.zero, () async {
      await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    });
  }
}

void _openDrawer(Action action, Context<HomeState> ctx) {
  BuildContext context = action.payload;
  Scaffold.of(context).openDrawer();
}

void _onToggleKeywordSheet(Action action, Context<HomeState> ctx) {
  int iconQuarterTurns = action.payload[ParamNames.keywordSwitchParam];
  BuildContext context = action.payload[ParamNames.contextParam];
  if (context != null) {
    if (iconQuarterTurns == 0) {
      ctx.broadcast(InfoNavPageActionCreator.onToggleKeywordNav(true));
      _showKeywordSheet(context);
    } else if (iconQuarterTurns == 2) {
      ctx.broadcast(InfoNavPageActionCreator.onToggleKeywordNav(false));
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }
  var newIconQuarterTurns = iconQuarterTurns == 0 ? 2 : 0;
  ctx.dispatch(HomeReducerCreator.toggleIconReducer(newIconQuarterTurns));
  if (newIconQuarterTurns == 2) {
    ctx.broadcast(KeywordNavPageActionCreator.onRefreshPage());
  }
}

void _onCloseKeywordSheet(Action action, Context<HomeState> ctx) {
  final int iconQuarterTurns = ctx.state.iconQuarterTurns;
  if (iconQuarterTurns == 2) {
    if (Navigator.of(ctx.context).canPop()) {
      Navigator.of(ctx.context).pop();
    }
    ctx.dispatch(HomeReducerCreator.toggleIconReducer(0));
  }
}

void _onSetHasFilters(Action action, Context<HomeState> ctx) {
  final bool hasFilters = action.payload;
  if (hasFilters != ctx.state.hasFilters) {
    ctx.dispatch(HomeReducerCreator.setHasFiltersReducer(hasFilters));
  }
}

/// 打开信息编辑页面并在操作完成后传递最新数据对象
void _onAddEntity(Action action, Context<HomeState> ctx) {
  Navigator.of(ctx.context)
      .pushNamed(PageNames.entityEditPage, arguments: null)
      .then((dynamic entity) {
    if (entity != null &&
        (entity.title?.isNotEmpty == true ||
            entity.subtitle?.isNotEmpty == true)) {
      ctx.dispatch(InfoEntityReducerCreator.addEntity(entity));
    }
  });
}

void _onChangeUser(Action action, Context<HomeState> ctx) {
  ctx.broadcast(InfoNavPageActionCreator.onShowNormal());
  GlobalStore.store
      .dispatch(GlobalReducerCreator.setSourceTypeReducer(SourceType.normal));
}

void _toggleKeywordNav(int iconQuarterTurns, Context<HomeState> ctx) {
  final isKeywordNav = iconQuarterTurns != 0;
  ctx.broadcast(InfoNavPageActionCreator.onToggleKeywordNav(isKeywordNav));
}

void _showKeywordSheet(BuildContext context) {
  showBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
            height: Constants.keywordNavPageHeight,
            child: routes.buildPage(PageNames.keywordNavPage, null));
      });
}
