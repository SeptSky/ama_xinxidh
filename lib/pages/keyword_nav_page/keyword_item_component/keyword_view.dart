import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action;

import 'keyword_standard.dart';
import 'keyword_state.dart';

Widget buildView(
  KeywordState keyword,
  Dispatch dispatch,
  ViewService viewService,
) {
  return buildKeywordItem(keyword, dispatch, viewService);
}

Container buildKeywordItem(
    KeywordState keywordState, Dispatch dispatch, ViewService viewService) {
  return Container(
    padding: const EdgeInsets.fromLTRB(2.0, 0.0, 2.0, 0.0),
    child: buildKeywordBody(keywordState, dispatch, viewService),
  );
}
