import 'package:fish_redux/fish_redux.dart';

import '../../models/themes/theme_bean.dart';

enum MainReducerEnum {
  changeThemeReducer,
}

class MainReducerCreator {
  static Action changeThemeReducer(ThemeBean action) {
    return Action(MainReducerEnum.changeThemeReducer, payload: action);
  }
}
