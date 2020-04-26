import 'package:fish_redux/fish_redux.dart';

enum EntityEditActionEnum {
  onDone,
  onChangeTheme,
}

class EntityEditActionCreator {
  static Action onDone() {
    return const Action(EntityEditActionEnum.onDone);
  }

  static Action onChangeTheme() {
    return const Action(EntityEditActionEnum.onChangeTheme);
  }
}
