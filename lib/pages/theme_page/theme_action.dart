import 'package:fish_redux/fish_redux.dart';

import '../../models/themes/theme_bean.dart';

enum ThemeActionEnum {
  onCreateTheme,
  onSelectTheme,
  onRemoveTheme,
}

class ThemeActionCreator {
  static Action onCreateTheme() {
    return const Action(ThemeActionEnum.onCreateTheme);
  }

  static Action onSelectTheme(ThemeBean action) {
    return Action(ThemeActionEnum.onSelectTheme, payload: action);
  }

  static Action onRemoveTheme(int action) {
    return Action(ThemeActionEnum.onRemoveTheme, payload: action);
  }
}

enum ThemeReducerEnum {
  initThemeReducer,
  setCurrentThemeReducer,
  setDeleteFlagReducer,
}

class ThemeReducerCreator {
  static Action initThemeReducer(List<ThemeBean> action) {
    return Action(ThemeReducerEnum.initThemeReducer, payload: action);
  }

  static Action setCurrentThemeReducer(ThemeBean action) {
    return Action(ThemeReducerEnum.setCurrentThemeReducer, payload: action);
  }

  static Action setDeleteFlagReducer(bool action) {
    return Action(ThemeReducerEnum.setDeleteFlagReducer, payload: action);
  }
}
