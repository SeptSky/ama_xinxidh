import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart';

import '../login_page/login_widgets.dart';
import 'reset_password_state.dart';

SingleChildScrollView buildResetPasswordBody(double screenHeight,
    double screenWidth, ResetPasswordState state, Dispatch dispatch) {
  return SingleChildScrollView(
      child: Container(
          height: screenHeight,
          width: screenWidth,
          child: Padding(
              padding: const EdgeInsets.only(top: 55.0),
              child: Column(mainAxisSize: MainAxisSize.max, children: [
                buildLoginLogo(),
              ]))));
}
