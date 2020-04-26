import 'package:fish_redux/fish_redux.dart';

import 'menu_state.dart';

Reducer<MenuState> buildReducer() {
  return asReducer(
    <Object, Reducer<MenuState>>{},
  );
}
