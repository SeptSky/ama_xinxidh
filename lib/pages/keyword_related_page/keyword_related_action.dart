import 'package:fish_redux/fish_redux.dart';

import '../../models/keywords/keyword.dart';
import '../../models/keywords/keyword_nav_env.dart';
import '../keyword_nav_page/keyword_item_component/keyword_state.dart';

enum KeywordRelatedPageActionEnum {
  onRefreshPage,
  onGetNextPageKeywords,
  onPressFilterAction,
  onPressKeywordAction,
}

class KeywordRelatedPageActionCreator {
  static Action onRefreshPage() {
    return Action(KeywordRelatedPageActionEnum.onRefreshPage);
  }

  static Action onPressFilterAction(String filteredKeywords) {
    return Action(KeywordRelatedPageActionEnum.onPressFilterAction,
        payload: filteredKeywords);
  }

  static Action onPressKeywordAction(KeywordState relatedKeyword) {
    return Action(KeywordRelatedPageActionEnum.onPressKeywordAction,
        payload: relatedKeyword);
  }
}

enum KeywordRelatedPageReducerEnum {
  initKeywordsReducer,
  setNextPageKeywordsReducer,
  setIsLoadingFlagReducer,
  restoreStateReducer,
}

class KeywordRelatedPageReducerCreator {
  static Action initKeywordsReducer(List<Keyword> keywords) {
    return Action(KeywordRelatedPageReducerEnum.initKeywordsReducer,
        payload: keywords);
  }

  static Action setNextPageKeywordsReducer(List<Keyword> keywords) {
    return Action(KeywordRelatedPageReducerEnum.setNextPageKeywordsReducer,
        payload: keywords);
  }

  static Action setIsLoadingFlagReducer(bool isLoading) {
    return Action(KeywordRelatedPageReducerEnum.setIsLoadingFlagReducer,
        payload: isLoading);
  }

  static Action restoreStateReducer(KeywordNavEnv keywordNavEnv) {
    return Action(KeywordRelatedPageReducerEnum.restoreStateReducer,
        payload: keywordNavEnv);
  }
}
