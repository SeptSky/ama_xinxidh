import 'package:fish_redux/fish_redux.dart';

import 'main_state.dart';

Effect<MainState> buildEffect() {
  return combineEffects(<Object, Effect<MainState>>{});
}
