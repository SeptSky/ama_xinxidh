import 'package:fish_redux/fish_redux.dart';

import 'reset_password_action.dart';
import 'reset_password_state.dart';

Reducer<ResetPasswordState> buildReducer() {
  return asReducer(
    <Object, Reducer<ResetPasswordState>>{
      ResetPasswordReducerEnum.switchPageIndexReducer: _switchPageIndexReducer,
    },
  );
}

ResetPasswordState _switchPageIndexReducer(ResetPasswordState state, Action action) {
  final ResetPasswordState newState = state.clone();
  return newState;
}
