import 'package:fish_redux/fish_redux.dart';

enum MineActionEnum {
  onSignOut,
}

class MineActionCreator {
  static Action onSignOut() {
    return Action(MineActionEnum.onSignOut);
  }
}
