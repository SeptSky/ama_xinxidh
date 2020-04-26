import 'package:fish_redux/fish_redux.dart';

import 'about_action.dart';
import 'about_state.dart';

Reducer<AboutState> buildReducer() {
  return asReducer(
    <Object, Reducer<AboutState>>{
      AboutReducerEnum.initAboutReducer: _initAboutReducer,
    },
  );
}

AboutState _initAboutReducer(AboutState state, Action action) {
  final AboutState newState = state.clone()..descriptions = action.payload;
  return newState;
}
