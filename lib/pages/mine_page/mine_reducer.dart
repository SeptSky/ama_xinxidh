import 'package:fish_redux/fish_redux.dart';

import 'mine_state.dart';

Reducer<MineState> buildReducer() {
  return asReducer(
    <Object, Reducer<MineState>>{},
  );
}
