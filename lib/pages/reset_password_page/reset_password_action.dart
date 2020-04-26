import 'package:fish_redux/fish_redux.dart';

enum ResetPasswordReducerEnum {
  switchPageIndexReducer,
}

class ResetPasswordReducerCreator {
  static Action switchPageIndexReducer(int pageIndex) {
    return Action(ResetPasswordReducerEnum.switchPageIndexReducer, payload: pageIndex);
  }
}
