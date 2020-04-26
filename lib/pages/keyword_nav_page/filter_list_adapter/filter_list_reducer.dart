import 'package:fish_redux/fish_redux.dart';

import '../../../common/consts/constants.dart';
import '../../../models/keywords/keyword.dart';
import '../keyword_nav_state.dart';
import 'filter_list_action.dart';

Reducer<KeywordNavPageState> buildReducer() {
  return asReducer(<Object, Reducer<KeywordNavPageState>>{
    FilterListReducerEnum.addFilter: _addFilter,
    FilterListReducerEnum.addNextPageFilters: _addNextPageFilters,
    FilterListReducerEnum.removeFilter: _removeFilter
  });
}

KeywordNavPageState _addFilter(KeywordNavPageState state, Action action) {
  final Keyword filter = action.payload;
  return state.clone()..filters = (state.filters..add(filter));
}

KeywordNavPageState _addNextPageFilters(
    KeywordNavPageState state, Action action) {
  final List<Keyword> filters = action.payload;
  if (filters.isNotEmpty && state.filters.length == Constants.pageSize) {
    final KeywordNavPageState newState = state.clone();
    newState.filters.addAll(filters);
    return newState;
  }
  return state;
}

KeywordNavPageState _removeFilter(KeywordNavPageState state, Action action) {
  final int keyId = action.payload;
  return state.clone()
    ..filters =
        (state.filters..removeWhere((Keyword state) => state.keyId == keyId));
}
