import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action;

import 'login_action.dart';
import 'login_state.dart';
import 'login_widgets.dart';

/// 状态数据变化刷新页面的本质：就是底层自动调用buildView方法，将变化的数据传入刷新界面
Widget buildView(LoginState state, Dispatch dispatch, ViewService viewService) {
  final context = viewService.context;
  final screenHeight = MediaQuery.of(context).size.height;
  final screenWidth = MediaQuery.of(context).size.width;
  return Scaffold(
    body: Stack(children: [
      buildLoginBackground(screenHeight, screenWidth),
      _buildLoginBody(screenHeight, screenWidth, state, dispatch, viewService)
    ]),
  );
}

Widget _buildLoginBody(double screenHeight, double screenWidth,
    LoginState state, Dispatch dispatch, ViewService viewService) {
  final pageView = PageView(
    controller: state.controller,
    children: [
      buildSignInBody(state, dispatch, viewService),
      buildRegisterBody(state, dispatch, viewService),
    ],
    onPageChanged: (index) {
      dispatch(LoginReducerCreator.switchPageIndexReducer(index));
    },
  );
  return SingleChildScrollView(
      child: Container(
          height: screenHeight,
          width: screenWidth,
          child: Padding(
              padding: const EdgeInsets.only(top: 55.0),
              child: Column(mainAxisSize: MainAxisSize.max, children: [
                buildLoginLogo(),
                buildLoginIndicator(state, dispatch),
                Expanded(child: pageView),
              ]))));
}
