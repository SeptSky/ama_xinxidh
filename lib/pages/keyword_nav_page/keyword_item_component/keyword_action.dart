import 'package:fish_redux/fish_redux.dart';

import '../../../models/keywords/keyword.dart';

enum KeywordAction {
  onEdit,
  edit,
  done,
  onRemove,
  remove,
  onScrollToKeyword,
}

class KeywordActionCreator {
  static Action onEditAction(int keyId) {
    return Action(KeywordAction.onEdit, payload: keyId);
  }

  static Action editAction(Keyword keyword) {
    return Action(KeywordAction.edit, payload: keyword);
  }

  static Action doneAction(int keyId) {
    return Action(KeywordAction.done, payload: keyId);
  }

  static Action onRemoveAction(int keyId) {
    return Action(KeywordAction.onRemove, payload: keyId);
  }

  static Action removeAction(int keyId) {
    return Action(KeywordAction.remove, payload: keyId);
  }

  static Action onScrollToKeyword(dynamic scrollParam) {
    return Action(KeywordAction.onScrollToKeyword, payload: scrollParam);
  }
}

enum KeywordReducerEnum {
  pressFilterReducer,
  unpressParentReducer,
  resetFilterReducer,
}

class KeywordReducerCreator {
  static Action pressFilterReducer(int index) {
    return Action(KeywordReducerEnum.pressFilterReducer, payload: index);
  }

  static Action unpressParentReducer(int index) {
    return Action(KeywordReducerEnum.unpressParentReducer, payload: index);
  }

  static Action resetFilterReducer() {
    return Action(KeywordReducerEnum.resetFilterReducer);
  }
}
