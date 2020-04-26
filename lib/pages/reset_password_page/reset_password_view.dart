import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action;

import '../login_page/login_widgets.dart';
import 'reset_password_state.dart';
import 'reset_password_widget.dart';

/// 状态数据变化刷新页面的本质：就是底层自动调用buildView方法，将变化的数据传入刷新界面
Widget buildView(
    ResetPasswordState state, Dispatch dispatch, ViewService viewService) {
  final context = viewService.context;
  final screenHeight = MediaQuery.of(context).size.height;
  final screenWidth = MediaQuery.of(context).size.width;
  return Scaffold(
    body: Stack(children: [
      buildLoginBackground(screenHeight, screenWidth),
      buildResetPasswordBody(screenHeight, screenWidth, state, dispatch)
    ]),
  );
}
