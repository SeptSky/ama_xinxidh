import 'package:fish_redux/fish_redux.dart';

import 'home_action.dart';
import 'home_state.dart';

Reducer<HomeState> buildReducer() {
  return asReducer(
    <Object, Reducer<HomeState>>{
      HomeReducerEnum.startupAppReducer: _startupAppReducer,
      HomeReducerEnum.toggleIconReducer: _toggleIconReducer,
      HomeReducerEnum.setLastPopTimeReducer: _setLastPopTimeReducer,
      HomeReducerEnum.setHasFiltersReducer: _setHasFiltersReducer,
    },
  );
}

HomeState _startupAppReducer(HomeState state, Action action) {
  final newState = state.clone()..isFirstRun = false;
  return newState;
}

HomeState _toggleIconReducer(HomeState state, Action action) {
  final newState = state.clone()..iconQuarterTurns = action.payload;
  return newState;
}

HomeState _setLastPopTimeReducer(HomeState state, Action action) {
  final newState = state.clone();
  newState.prevPopTime = newState.lastPopTime;
  newState.lastPopTime = action.payload;
  return newState;
}

HomeState _setHasFiltersReducer(HomeState state, Action action) {
  final newState = state.clone()..hasFilters = action.payload;
  return newState;
}
