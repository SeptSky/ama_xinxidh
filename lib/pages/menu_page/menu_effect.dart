import 'package:fish_redux/fish_redux.dart';

import 'menu_state.dart';

Effect<MenuState> buildEffect() {
  return combineEffects(<Object, Effect<MenuState>>{});
}
