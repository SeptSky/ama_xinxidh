import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action;

enum HomeActionEnum {
  onStartupApp,
  onProcessBackKey,
  onToggleKeywordSheet,
  onCloseKeywordSheet,
  onOpenDrawer,
  onAddEntity,
  onChangeUser,
}

enum HomeReducerEnum {
  startupAppReducer,
  toggleIconReducer,
  setLastPopTimeReducer,
}

class HomeActionCreator {
  static Action onStartupApp() {
    return Action(HomeActionEnum.onStartupApp);
  }

  static Action onProcessBackKey(dynamic params) {
    return Action(HomeActionEnum.onProcessBackKey, payload: params);
  }

  static Action onToggleKeywordSheet(dynamic params) {
    return Action(HomeActionEnum.onToggleKeywordSheet, payload: params);
  }

  static Action onCloseKeywordSheet() {
    return Action(HomeActionEnum.onCloseKeywordSheet);
  }

  static Action onOpenDrawer(BuildContext context) {
    return Action(HomeActionEnum.onOpenDrawer, payload: context);
  }

  static Action onAddEntity() {
    return const Action(HomeActionEnum.onAddEntity);
  }

  static Action onChangeUser() {
    return const Action(HomeActionEnum.onChangeUser);
  }
}

class HomeReducerCreator {
  static Action startupAppReducer() {
    return Action(HomeReducerEnum.startupAppReducer);
  }

  static Action toggleIconReducer(int iconQuarterTurns) {
    return Action(HomeReducerEnum.toggleIconReducer, payload: iconQuarterTurns);
  }

  static Action setLastPopTimeReducer(DateTime currentTime) {
    return Action(HomeReducerEnum.setLastPopTimeReducer, payload: currentTime);
  }
}
