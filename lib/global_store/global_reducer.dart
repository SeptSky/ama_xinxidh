import 'package:fish_redux/fish_redux.dart';

import 'global_action.dart';
import 'global_state.dart';

Reducer<GlobalState> buildReducer() {
  return asReducer(
    <Object, Reducer<GlobalState>>{
      GlobalReducerEnum.setSearchModeReducer: _setSearchModeReducer,
      GlobalReducerEnum.setSourceTypeReducer: _setSourceTypeReducer,
      GlobalReducerEnum.setContentTypeReducer: _setContentTypeReducer,
      GlobalReducerEnum.setErrorStatusReducer: _setErrorStatusReducer,
      GlobalReducerEnum.setWebLoadingStatusReducer: _setWebLoadingStatusReducer,
      GlobalReducerEnum.changeCurrentThemeReducer: _changeCurrentThemeReducer,
      GlobalReducerEnum.changeTopicDefReducer: _changeTopicDefReducer,
      GlobalReducerEnum.setUserInfoReducer: _setUserInfoReducer,
    },
  );
}

GlobalState _setSearchModeReducer(GlobalState state, Action action) {
  final searchMode = action.payload;
  if (searchMode == state.searchMode) return state;
  return state.clone()..searchMode = searchMode;
}

GlobalState _setSourceTypeReducer(GlobalState state, Action action) {
  final sourceType = action.payload;
  if (sourceType == state.sourceType) return state;
  return state.clone()..sourceType = sourceType;
}

GlobalState _setContentTypeReducer(GlobalState state, Action action) {
  final contentType = action.payload;
  if (contentType == state.contentType) return state;
  return state.clone()..contentType = contentType;
}

GlobalState _setErrorStatusReducer(GlobalState state, Action action) {
  final hasError = action.payload;
  return state.clone()..hasError = hasError;
}

GlobalState _setWebLoadingStatusReducer(GlobalState state, Action action) {
  final isLoadingWebData = action.payload;
  return state.clone()..isLoadingWebData = isLoadingWebData;
}

GlobalState _changeCurrentThemeReducer(GlobalState state, Action action) {
  final currentTheme = action.payload;
  return state.clone()..currentTheme = currentTheme;
}

GlobalState _changeTopicDefReducer(GlobalState state, Action action) {
  final topicDef = action.payload;
  return state.clone()..appConfig.topic = topicDef;
}

GlobalState _setUserInfoReducer(GlobalState state, Action action) {
  final userInfo = action.payload;
  return state.clone()..userInfo = userInfo;
}
