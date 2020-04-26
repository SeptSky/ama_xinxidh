import 'package:fish_redux/fish_redux.dart';

enum LoginActionEnum {
  onSignIn,
  onRegister,
}

class LoginActionCreator {
  static Action onSignIn() {
    return Action(LoginActionEnum.onSignIn);
  }

  static Action onRegister() {
    return Action(LoginActionEnum.onRegister);
  }
}

enum LoginReducerEnum {
  switchPageIndexReducer,
}

class LoginReducerCreator {
  static Action switchPageIndexReducer(int pageIndex) {
    return Action(LoginReducerEnum.switchPageIndexReducer, payload: pageIndex);
  }
}
