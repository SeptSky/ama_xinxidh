import 'package:fish_redux/fish_redux.dart';

import '../../common/consts/constants.dart';
import '../../common/utilities/tools.dart';
import '../../models/keywords/keyword.dart';
import '../../models/keywords/keyword_nav_env.dart';
import 'keyword_nav_action.dart';
import 'keyword_nav_state.dart';

Reducer<KeywordNavPageState> buildReducer() {
  /// 建立Reducer名称与Reducer实现之间的映射关系
  return asReducer(
    <Object, Reducer<KeywordNavPageState>>{
      KeywordNavPageReducerEnum.initKeywordsReducer: _initKeywordsReducer,
      KeywordNavPageReducerEnum.setNextPageFiltersReducer:
          _setNextPageKeywordsReducer,
      KeywordNavPageReducerEnum.setIsLoadingFlagReducer:
          _setIsLoadingFlagReducer,
      KeywordNavPageReducerEnum.setKeywordModeReducer: _setKeywordModeReducer,
      KeywordNavPageReducerEnum.resotreStateReducer: _resotreStateReducer,
    },
  );
}

KeywordNavPageState _initKeywordsReducer(
    KeywordNavPageState state, Action action) {
  final List<Keyword> keywords = action.payload ?? <Keyword>[];
  if (keywords.length == 0) return state;
  final newState = state.clone();
  newState.filters = keywords;
  var pressedParents = newState.getPressedParentFilterList();
  var paginationEnabled = Tools.hasNotElements(pressedParents);
  if (paginationEnabled && keywords.isNotEmpty) {
    newState.hasMoreFilters = keywords.length % Constants.filterPageSize == 0;
    newState.nextPageNo = 1;
  } else {
    newState.hasMoreFilters = false;
    newState.nextPageNo = 0;
  }
  return newState;
}

KeywordNavPageState _setNextPageKeywordsReducer(
    KeywordNavPageState state, Action action) {
  final List<Keyword> keywords = action.payload ?? <Keyword>[];
  // 需要考虑重复读取的情况
  if (keywords.isNotEmpty &&
      state.filters
              .indexWhere((keyword) => keyword.title == keywords[0].title) >=
          0) {
    return state;
  }
  final newState = state.clone();
  if (keywords.isNotEmpty) {
    newState.filters.addAll(keywords);
    newState.hasMoreFilters = keywords.length % Constants.pageSize == 0;
    newState.nextPageNo = newState.nextPageNo + 1;
  } else {
    newState.hasMoreFilters = false;
    newState.nextPageNo = 0;
  }
  return newState;
}

KeywordNavPageState _setIsLoadingFlagReducer(
    KeywordNavPageState state, Action action) {
  final bool isLoading = action.payload ?? false;
  final newState = state.clone()..isLoading = isLoading;
  return newState;
}

KeywordNavPageState _setKeywordModeReducer(
    KeywordNavPageState state, Action action) {
  final newState = state.clone()..keywordMode = action.payload;
  return newState;
}

KeywordNavPageState _resotreStateReducer(
    KeywordNavPageState state, Action action) {
  final KeywordNavEnv keywordNavEnv = action.payload;
  final newState = state.clone()
    ..keywordMode = keywordNavEnv.keywordMode
    ..hasMoreFilters = keywordNavEnv.hasMore
    ..nextPageNo = keywordNavEnv.nextPageNo
    ..filters = keywordNavEnv.keywords;
  return newState;
}
