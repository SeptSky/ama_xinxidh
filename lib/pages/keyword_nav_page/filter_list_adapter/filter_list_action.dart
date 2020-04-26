import 'package:fish_redux/fish_redux.dart';

import '../../../models/keywords/keyword.dart';

enum FilterListReducerEnum {
  addFilter,
  addNextPageFilters,
  removeFilter,
}

class FilterListReducerCreator {
  static Action addKeyword(Keyword keyword) {
    return Action(FilterListReducerEnum.addFilter, payload: keyword);
  }

  static Action addNextPageKeywords(List<Keyword> keywords) {
    return Action(FilterListReducerEnum.addNextPageFilters, payload: keywords);
  }

  static Action removeKeyword(int keyId) {
    return Action(FilterListReducerEnum.removeFilter, payload: keyId);
  }
}
