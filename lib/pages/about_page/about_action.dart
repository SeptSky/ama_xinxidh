import 'package:fish_redux/fish_redux.dart';

enum AboutReducerEnum {
  initAboutReducer,
}

class AboutReducerCreator {
  static Action initAboutReducer(List<String> action) {
    return Action(AboutReducerEnum.initAboutReducer, payload: action);
  }
}
