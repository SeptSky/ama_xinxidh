import 'package:fish_redux/fish_redux.dart';

import '../../../common/consts/constants.dart';
import '../../../models/keywords/keyword.dart';
import '../keyword_related_state.dart';
import 'keyword_list_action.dart';

Reducer<KeywordRelatedPageState> buildReducer() {
  return asReducer(<Object, Reducer<KeywordRelatedPageState>>{
    KeywordListReducerEnum.addKeyword: _addKeyword,
    KeywordListReducerEnum.addNextPageKeywords: _addNextPageKeywords,
    KeywordListReducerEnum.removeKeyword: _removeKeyword
  });
}

KeywordRelatedPageState _addKeyword(
    KeywordRelatedPageState state, Action action) {
  final Keyword keyword = action.payload;
  return state.clone()..keywords = (state.keywords..add(keyword));
}

KeywordRelatedPageState _addNextPageKeywords(
    KeywordRelatedPageState state, Action action) {
  final List<Keyword> keywords = action.payload;
  if (keywords.isNotEmpty && state.keywords.length == Constants.pageSize) {
    final KeywordRelatedPageState newState = state.clone();
    newState.keywords.addAll(keywords);
    return newState;
  }
  return state;
}

KeywordRelatedPageState _removeKeyword(
    KeywordRelatedPageState state, Action action) {
  final int keyId = action.payload;
  return state.clone()
    ..keywords =
        (state.keywords..removeWhere((Keyword state) => state.keyId == keyId));
}
