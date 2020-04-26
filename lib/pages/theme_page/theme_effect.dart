import 'dart:convert';

import 'package:fish_redux/fish_redux.dart';

import '../../common/consts/constants.dart';
import '../../common/consts/keys.dart';
import '../../common/utilities/shared_util.dart';
import '../../global_store/global_action.dart';
import '../../global_store/global_store.dart';
import '../../models/themes/theme_bean.dart';
import 'theme_action.dart';
import 'theme_logic.dart';
import 'theme_state.dart';

Effect<ThemeState> buildEffect() {
  return combineEffects(<Object, Effect<ThemeState>>{
    Lifecycle.initState: _init,
    ThemeActionEnum.onCreateTheme: _createThemeAction,
    ThemeActionEnum.onSelectTheme: _selectThemeAction,
    ThemeActionEnum.onRemoveTheme: _removeThemeAction,
  });
}

void _init(Action action, Context<ThemeState> ctx) {
  /// 不使用Future.Delayed方法将会抛出异常，通过Delayed可以跳过首次执行顺序
  /// 同步方法内调用异步方法的一种实现
  Future.delayed(Duration.zero, () async {
    await ThemeLogic.loadThemeList(ctx.dispatch, ctx.context);
    await ThemeLogic.loadCurrentTheme(ctx.state, ctx.dispatch);
  });
}

void _createThemeAction(Action action, Context<ThemeState> ctx) {
  ThemeLogic.showColorPicker(ctx.state, ctx.dispatch, ctx.context);
}

void _selectThemeAction(Action action, Context<ThemeState> ctx) {
  ThemeBean themeBean = action.payload;
  SharedUtil.instance
      .saveString(Keys.currentThemeBean, jsonEncode(themeBean.toMap()));
  GlobalStore.store
      .dispatch(GlobalReducerCreator.changeCurrentThemeReducer(themeBean));
}

void _removeThemeAction(Action action, Context<ThemeState> ctx) {
  int index = action.payload;
  SharedUtil.instance
      .readAndRemoveList(Keys.themeBeans, index - Constants.innerThemeCount);
  ThemeLogic.loadThemeList(ctx.dispatch, ctx.context);
}
