import 'package:fish_redux/fish_redux.dart';

import '../../common/consts/constants.dart';
import 'theme_action.dart';
import 'theme_state.dart';

Reducer<ThemeState> buildReducer() {
  return asReducer(
    <Object, Reducer<ThemeState>>{
      ThemeReducerEnum.initThemeReducer: _initThemeReducer,
      ThemeReducerEnum.setCurrentThemeReducer: _setCurrentThemeReducer,
      ThemeReducerEnum.setDeleteFlagReducer: _setDeleteFlagReducer,
    },
  );
}

ThemeState _initThemeReducer(ThemeState state, Action action) {
  final ThemeState newState = state.clone()..themes = action.payload;
  if (newState.themes.length == Constants.innerThemeCount) {
    newState.isDeleting = false;
  }
  return newState;
}

ThemeState _setCurrentThemeReducer(ThemeState state, Action action) {
  final ThemeState newState = state.clone()..currentTheme = action.payload;
  return newState;
}

ThemeState _setDeleteFlagReducer(ThemeState state, Action action) {
  final ThemeState newState = state.clone()..isDeleting = action.payload;
  return newState;
}
