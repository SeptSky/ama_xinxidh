import 'package:fish_redux/fish_redux.dart';

import '../../common/consts/constants.dart';
import '../../models/keywords/keyword.dart';
import '../../models/keywords/keyword_nav_env.dart';
import 'keyword_related_action.dart';
import 'keyword_related_state.dart';

Reducer<KeywordRelatedPageState> buildReducer() {
  /// 建立Reducer名称与Reducer实现之间的映射关系
  return asReducer(
    <Object, Reducer<KeywordRelatedPageState>>{
      KeywordRelatedPageReducerEnum.initKeywordsReducer: _initKeywordsReducer,
      KeywordRelatedPageReducerEnum.setNextPageKeywordsReducer:
          _setNextPageKeywordsReducer,
      KeywordRelatedPageReducerEnum.setFilterKeywordsReducer:
          _setFilterKeywordsReducer,
      KeywordRelatedPageReducerEnum.setIsLoadingFlagReducer:
          _setIsLoadingFlagReducer,
      KeywordRelatedPageReducerEnum.restoreStateReducer: _restoreStateReducer,
    },
  );
}

KeywordRelatedPageState _initKeywordsReducer(
    KeywordRelatedPageState state, Action action) {
  final List<Keyword> keywords = action.payload ?? <Keyword>[];
  final KeywordRelatedPageState newState = state.clone();
  newState.keywords = keywords;
  if (keywords.isNotEmpty) {
    newState.hasMoreKeywords = keywords.length % Constants.pageSize == 0;
    newState.nextPageNo = 1;
  } else {
    newState.hasMoreKeywords = false;
    newState.nextPageNo = 0;
  }
  return newState;
}

KeywordRelatedPageState _setNextPageKeywordsReducer(
    KeywordRelatedPageState state, Action action) {
  final List<Keyword> keywords = action.payload ?? <Keyword>[];
  // 需要考虑重复读取的情况
  if (keywords.isNotEmpty &&
      state.keywords
              .indexWhere((keyword) => keyword.title == keywords[0].title) >=
          0) {
    return state;
  }
  final KeywordRelatedPageState newState = state.clone();
  if (keywords.isNotEmpty) {
    newState.keywords.addAll(keywords);
    newState.hasMoreKeywords = keywords.length % Constants.pageSize == 0;
    newState.nextPageNo = newState.nextPageNo + 1;
  } else {
    newState.hasMoreKeywords = false;
    newState.nextPageNo = 0;
  }
  return newState;
}

KeywordRelatedPageState _setFilterKeywordsReducer(
    KeywordRelatedPageState state, Action action) {
  final String filterKeywords = action.payload;
  final KeywordRelatedPageState newState = state.clone()
    ..filterKeywords = filterKeywords;
  return newState;
}

KeywordRelatedPageState _setIsLoadingFlagReducer(
    KeywordRelatedPageState state, Action action) {
  final bool isLoading = action.payload ?? false;
  final KeywordRelatedPageState newState = state.clone()..isLoading = isLoading;
  return newState;
}

KeywordRelatedPageState _restoreStateReducer(
    KeywordRelatedPageState state, Action action) {
  final KeywordNavEnv keywordNavEnv = action.payload;
  final newState = state.clone()
    ..hasMoreKeywords = keywordNavEnv.hasMore
    ..nextPageNo = keywordNavEnv.nextPageNo
    ..filterKeywords = keywordNavEnv.filteredKeywords
    ..keywords = keywordNavEnv.keywords;
  return newState;
}
