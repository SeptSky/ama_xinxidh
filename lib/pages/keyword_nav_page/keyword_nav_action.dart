import 'package:amainfoindex/pages/keyword_nav_page/keyword_item_component/keyword_state.dart';
import 'package:fish_redux/fish_redux.dart';

import '../../models/keywords/keyword.dart';
import '../../models/keywords/keyword_nav_env.dart';

enum KeywordNavPageActionEnum {
  onRefreshPage,
  onGetNextPageFilters,
  onPressFilterAction,
  onPressAlphabetAction,
  onUnpressParentAction,
  onCancelFilterAction,
  onCombineFilterAction,
  onResetFilterAction,
  onChangeTopicDef,
  onScrollToKeyword,
  onShowFilters,
  onShowPyCodes,
}

class KeywordNavPageActionCreator {
  static Action onRefreshPage() {
    return Action(KeywordNavPageActionEnum.onRefreshPage);
  }

  static Action onPressFilterAction(String filteredKeyword) {
    return Action(KeywordNavPageActionEnum.onPressFilterAction,
        payload: filteredKeyword);
  }

  static Action onPressAlphabetAction(KeywordState keywordState) {
    return Action(KeywordNavPageActionEnum.onPressAlphabetAction,
        payload: keywordState);
  }

  static Action onUnpressParentAction() {
    return Action(KeywordNavPageActionEnum.onUnpressParentAction);
  }

  static Action onCancelFilterAction(int index) {
    return Action(KeywordNavPageActionEnum.onCancelFilterAction,
        payload: index);
  }

  static Action onCombineFilterAction() {
    return Action(KeywordNavPageActionEnum.onCombineFilterAction);
  }

  static Action onResetFilterAction() {
    return Action(KeywordNavPageActionEnum.onResetFilterAction);
  }

  static Action onChangeTopicDef(int topicId) {
    return Action(KeywordNavPageActionEnum.onChangeTopicDef, payload: topicId);
  }

  static Action onScrollToKeyword(dynamic scrollParam) {
    return Action(KeywordNavPageActionEnum.onScrollToKeyword,
        payload: scrollParam);
  }

  static Action onShowFilters() {
    return Action(KeywordNavPageActionEnum.onShowFilters);
  }

  static Action onShowPyCodes() {
    return Action(KeywordNavPageActionEnum.onShowPyCodes);
  }
}

enum KeywordNavPageReducerEnum {
  initKeywordsReducer,
  setNextPageFiltersReducer,
  setIsLoadingFlagReducer,
  setKeywordModeReducer,
  resotreStateReducer,
}

class KeywordNavPageReducerCreator {
  static Action initKeywordsReducer(List<Keyword> keywords) {
    return Action(KeywordNavPageReducerEnum.initKeywordsReducer,
        payload: keywords);
  }

  static Action setNextPageFiltersReducer(List<Keyword> filters) {
    return Action(KeywordNavPageReducerEnum.setNextPageFiltersReducer,
        payload: filters);
  }

  static Action setIsLoadingFlagReducer(bool isLoading) {
    return Action(KeywordNavPageReducerEnum.setIsLoadingFlagReducer,
        payload: isLoading);
  }

  static Action setKeywordModeReducer(bool keywordMode) {
    return Action(KeywordNavPageReducerEnum.setKeywordModeReducer,
        payload: keywordMode);
  }

  static Action resotreStateReducer(KeywordNavEnv keywordNavEnv) {
    return Action(KeywordNavPageReducerEnum.resotreStateReducer,
        payload: keywordNavEnv);
  }
}
