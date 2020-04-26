import 'dart:convert';

import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action;

import '../../common/consts/constants.dart';
import '../../common/consts/keys.dart';
import '../../common/consts/page_names.dart';
import '../../common/data_access/webApi/info_nav_services.dart';
import '../../common/utilities/dialogs.dart';
import '../../common/utilities/shared_util.dart';
import '../../global_store/global_action.dart';
import '../../global_store/global_store.dart';
import '../home_page/home_action.dart';
import '../info_nav_page/info_nav_action.dart';
import 'login_action.dart';
import 'login_state.dart';

Effect<LoginState> buildEffect() {
  return combineEffects(<Object, Effect<LoginState>>{
    Lifecycle.initState: _init,
    LoginActionEnum.onSignIn: _onSignIn,
    LoginActionEnum.onRegister: _onRegister,
  });
}

void _init(Action action, Context<LoginState> ctx) {}

void _onSignIn(Action action, Context<LoginState> ctx) async {
  final state = ctx.state;
  final userName = state.userController.text;
  final bgColor = GlobalStore.themePrimaryIcon;
  if (userName.isEmpty) {
    Dialogs.showInfoToast('用户名不能为空！', bgColor);
    return;
  }
  final password = state.passwordController.text;
  if (password.isEmpty) {
    Dialogs.showInfoToast('密码不能为空！', bgColor);
    return;
  }
  try {
    final userInfo = await InfoNavServices.login(userName, password);
    if (userInfo == null) {
      Dialogs.showInfoToast('用户名或密码错误！', bgColor);
      return;
    }
    GlobalStore.store
        .dispatch(GlobalReducerCreator.setUserInfoReducer(userInfo));
    Navigator.of(ctx.context).pop();
    Navigator.of(ctx.context).pushNamed(PageNames.minePage);
    await GlobalStore.clearLocalCache();
    await SharedUtil.instance
        .saveString(Keys.userInfo, jsonEncode(userInfo.toJson()));
    ctx.broadcast(InfoNavPageActionCreator.onSetFilteredKeyword(null));
    ctx.broadcast(HomeActionCreator.onChangeUser());
  } catch (err) {
    GlobalStore.store
        .dispatch(GlobalReducerCreator.setErrorStatusReducer(true));
  }
}

void _onRegister(Action action, Context<LoginState> ctx) async {
  final state = ctx.state;
  final userName = state.userController.text;
  final bgColor = GlobalStore.themePrimaryIcon;
  if (userName.isEmpty) {
    Dialogs.showInfoToast('用户名不能为空！', bgColor);
    return;
  }
  if (userName.length < Constants.userNameMinLen) {
    Dialogs.showInfoToast('用户名长度不能小于${Constants.userNameMinLen}！', bgColor);
    return;
  }
  final phoneNum = state.phoneController.text;
  if (phoneNum.isEmpty) {
    Dialogs.showInfoToast('手机号码不能为空！', bgColor);
    return;
  }
  final exp = RegExp(
      r'^((13[0-9])|(14[0-9])|(15[0-9])|(16[0-9])|(17[0-9])|(18[0-9])|(19[0-9]))\d{8}$');
  if (!exp.hasMatch(phoneNum)) {
    Dialogs.showInfoToast('手机号码格式不正确！', bgColor);
    return;
  }
  final password = state.passwordController.text;
  if (password.isEmpty) {
    Dialogs.showInfoToast('密码不能为空！', bgColor);
    return;
  }
  if (state.passwordAgainController.text.isEmpty) {
    Dialogs.showInfoToast('验证密码不能为空！', bgColor);
    return;
  }
  if (password != state.passwordAgainController.text) {
    Dialogs.showInfoToast('验证密码不一致！', bgColor);
    return;
  }
  if (password.length < Constants.passwordMinLen) {
    Dialogs.showInfoToast('密码长度不能小于${Constants.passwordMinLen}！', bgColor);
    return;
  }
  try {
    final result =
        await InfoNavServices.createAccount(userName, password, phoneNum);
    if (result == 'ok') {
      Navigator.of(ctx.context).pop();
      Dialogs.showInfoToast('注册成功，请登录！', bgColor);
    } else {
      Dialogs.showInfoToast(result, bgColor);
    }
  } catch (err) {
    GlobalStore.store
        .dispatch(GlobalReducerCreator.setErrorStatusReducer(true));
  }
}
