import 'package:fish_redux/fish_redux.dart';

import '../../../models/keywords/keyword.dart';

enum KeywordListReducerEnum {
  addKeyword,
  addNextPageKeywords,
  removeKeyword,
}

class KeywordListReducerCreator {
  static Action addKeyword(Keyword keyword) {
    return Action(KeywordListReducerEnum.addKeyword, payload: keyword);
  }

  static Action addNextPageKeywords(List<Keyword> keywords) {
    return Action(KeywordListReducerEnum.addNextPageKeywords,
        payload: keywords);
  }

  static Action removeKeyword(int keyId) {
    return Action(KeywordListReducerEnum.removeKeyword, payload: keyId);
  }
}
