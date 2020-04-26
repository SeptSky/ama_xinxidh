import 'package:fish_redux/fish_redux.dart';

import 'main_action.dart';
import 'main_state.dart';

Reducer<MainState> buildReducer() {
  return asReducer(
    <Object, Reducer<MainState>>{
      MainReducerEnum.changeThemeReducer: _changeThemeReducer,
    },
  );
}

MainState _changeThemeReducer(MainState state, Action action) {
  final MainState newState = state.clone()..currentTheme = action.payload;
  return newState;
}
