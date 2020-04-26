import 'package:fish_redux/fish_redux.dart';

import 'login_action.dart';
import 'login_state.dart';

Reducer<LoginState> buildReducer() {
  return asReducer(
    <Object, Reducer<LoginState>>{
      LoginReducerEnum.switchPageIndexReducer: _switchPageIndexReducer,
    },
  );
}

LoginState _switchPageIndexReducer(LoginState state, Action action) {
  final LoginState newState = state.clone()..currentPage = action.payload;
  return newState;
}
