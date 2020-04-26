import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action;

import '../../common/consts/page_names.dart';
import '../../common/utilities/dialogs.dart';
import '../home_page/home_action.dart';
import 'intro_action.dart';
import 'intro_state.dart';

Effect<IntroState> buildEffect() {
  return combineEffects(<Object, Effect<IntroState>>{
    IntroActionEnum.onStartupApp: _onStartupApp,
    IntroActionEnum.onPressUserContractLink: _onPressUserContractLink,
    IntroActionEnum.onPressPrivateContractLink: _onPressPrivateContractLink,
  });
}

void _onStartupApp(Action action, Context<IntroState> ctx) {
  final bool checkValue = action.payload;
  if (!checkValue) {
    Dialogs.showErrorToast('未同意“用户协议”和“隐私政策”！');
    return;
  }
  ctx.broadcast(HomeActionCreator.onStartupApp());
}

void _onPressPrivateContractLink(Action action, Context<IntroState> ctx) {
  Navigator.of(ctx.context)
      .pushNamed(PageNames.privateContractPage, arguments: null);
}

void _onPressUserContractLink(Action action, Context<IntroState> ctx) {
  Navigator.of(ctx.context)
      .pushNamed(PageNames.userContractPage, arguments: null);
}
