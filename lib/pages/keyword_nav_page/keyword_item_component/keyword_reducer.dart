import 'package:fish_redux/fish_redux.dart';

import '../../../common/data_access/webApi/info_nav_services.dart';
import '../../../global_store/global_store.dart';
import 'keyword_action.dart';
import 'keyword_state.dart';

Reducer<KeywordState> buildReducer() {
  return asReducer(<Object, Reducer<KeywordState>>{
    KeywordAction.edit: _edit,
    KeywordAction.done: _markDone,
    KeywordReducerEnum.pressFilterReducer: _pressFilterReducer,
    KeywordReducerEnum.unpressParentReducer: _unpressParentReducer,
    KeywordReducerEnum.resetFilterReducer: _resetFilterReducer,
  });
}

KeywordState _edit(KeywordState keywordState, Action action) {
  final KeywordState newState = action.payload;
  if (keywordState.keyId == newState.keyId) {
    return keywordState.clone()..title = newState.title;
  }
  return keywordState;
}

KeywordState _markDone(KeywordState keywordState, Action action) {
  final int keyId = action.payload;
  if (keywordState.keyId == keyId) {
    // return keyword.clone()..enabled = !keyword.enabled;
  }
  return keywordState;
}

KeywordState _pressFilterReducer(KeywordState keywordState, Action action) {
  final int index = action.payload;
  // 无状态变化的Item不需要Clone操作
  if (!keywordState.pressed && keywordState.index != index) {
    return keywordState;
  }
  if (index == keywordState.index) {
    _incFilterRankValue(
        GlobalStore.currentTopicDef.indexKeyword, keywordState.title);
  }
  final KeywordState newKeywordState = keywordState.clone()
    ..pressed = index == keywordState.index;
  return newKeywordState;
}

KeywordState _unpressParentReducer(KeywordState keywordState, Action action) {
  final int index = action.payload;
  // 无状态变化的Item不需要Clone操作
  if (!keywordState.pressed && keywordState.index != index) {
    return keywordState;
  }
  final KeywordState newKeywordState = keywordState.clone()..pressed = false;
  return newKeywordState;
}

KeywordState _resetFilterReducer(KeywordState keywordState, Action action) {
  if (!keywordState.pressed) {
    return keywordState;
  }
  final KeywordState newKeywordState = keywordState.clone()..pressed = false;
  return newKeywordState;
}

void _incFilterRankValue(String topicKeyword, String filterName) {
  try {
    InfoNavServices.incFilterRankValue(topicKeyword, filterName, 1);
  } catch (err) {}
}
