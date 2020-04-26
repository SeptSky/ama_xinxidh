import 'package:fish_redux/fish_redux.dart';

enum IntroActionEnum {
  onStartupApp,
  onPressUserContractLink,
  onPressPrivateContractLink,
}

enum IntroReducerEnum {
  changeCheckValueReducer,
}

class IntroActionCreator {
  static Action onStartupApp(bool checkValue) {
    return Action(IntroActionEnum.onStartupApp, payload: checkValue);
  }

  static Action onPressUserContractLink() {
    return Action(IntroActionEnum.onPressUserContractLink);
  }

  static Action onPressPrivateContractLink() {
    return Action(IntroActionEnum.onPressPrivateContractLink);
  }
}

class IntroReducerCreator {
  static Action changeCheckValueReducer(bool checkValue) {
    return Action(IntroReducerEnum.changeCheckValueReducer, payload: checkValue);
  }
}
