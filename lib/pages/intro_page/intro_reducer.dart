import 'package:fish_redux/fish_redux.dart';

import 'intro_action.dart';
import 'intro_state.dart';

Reducer<IntroState> buildReducer() {
  return asReducer(
    <Object, Reducer<IntroState>>{
      IntroReducerEnum.changeCheckValueReducer: _changeCheckValueReducer,
    },
  );
}

IntroState _changeCheckValueReducer(IntroState state, Action action) {
  final IntroState newState = state.clone()..checkValue = action.payload;
  return newState;
}
