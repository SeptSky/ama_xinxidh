import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart';

import '../../common/consts/page_names.dart';
import '../../global_store/global_store.dart';
import '../widgets/button.dart';
import '../widgets/gradient_background.dart';
import '../widgets/submit_button.dart';
import 'login_action.dart';
import 'login_state.dart';

GradientBackground buildLoginBackground(
    double screenHeight, double screenWidth) {
  return GradientBackground(
    colors: [GlobalStore.themePrimaryIcon, Colors.white],
    height: screenHeight,
    width: screenWidth,
  );
}

Hero buildLoginLogo() {
  return Hero(
      tag: 'login_logo',
      child:
          Image.asset('assets/images/login_logo.png', width: 157, height: 120));
}

Widget buildLoginIndicator(LoginState state, Dispatch dispatch) {
  return Container(
    width: 300.0,
    height: 42.0,
    margin: const EdgeInsets.only(top: 20.0),
    padding: const EdgeInsets.only(left: 2.0, right: 2.0),
    decoration: BoxDecoration(
      color: GlobalStore.themePrimaryIcon,
      borderRadius: const BorderRadius.all(Radius.circular(21.0)),
    ),
    child: Row(
      children: [
        Expanded(child: buildSwitchButton('登录', 0, state, dispatch)),
        Expanded(child: buildSwitchButton('注册', 1, state, dispatch)),
      ],
    ),
  );
}

Button buildSwitchButton(
    String caption, int index, LoginState state, Dispatch dispatch) {
  return Button(
    onPressed: () {
      state.controller.animateToPage(index,
          duration: Duration(milliseconds: 300), curve: Curves.decelerate);
    },
    child: Text(caption, style: TextStyle(fontSize: 18)),
    buttonShape: ButtonShape.Fillet,
    borderRadius: 30.0,
    textColor: state.currentPage == index ? Colors.black54 : Colors.white,
    height: 35.0,
    color: state.currentPage == index ? Colors.white : Colors.transparent,
  );
}

Widget buildSignInBody(
    LoginState state, Dispatch dispatch, ViewService viewService) {
  return Container(
    padding: const EdgeInsets.only(top: 23),
    child: Column(
      children: [
        _buildSignInTextForm(state, dispatch, viewService),
        // _buildForgetPassword(viewService),
      ],
    ),
  );
}

Widget buildRegisterBody(
    LoginState state, Dispatch dispatch, ViewService viewService) {
  return Container(
    padding: const EdgeInsets.only(top: 23),
    child: Column(
      children: [
        _buildRegisterTextForm(state, dispatch, viewService),
      ],
    ),
  );
}

Widget _buildSignInTextForm(
    LoginState state, Dispatch dispatch, ViewService viewService) {
  return Container(
    decoration: const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
      color: Colors.white,
    ),
    width: 300.0,
    child: Form(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildUserNameInput(state, viewService),
          _buildSeparatorLine(),
          _buildPasswordInput(state, viewService),
          _buildBottomLine(Colors.grey[100]),
          _buildSignInButton(state, dispatch),
          _buildBottomLine(Colors.transparent),
        ],
      ),
    ),
  );
}

Widget _buildRegisterTextForm(
    LoginState state, Dispatch dispatch, ViewService viewService) {
  return Container(
    decoration: const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
      color: Colors.white,
    ),
    width: 300.0,
    child: Form(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildUserNameInput(state, viewService),
          _buildSeparatorLine(),
          _buildCellPhoneInput(state, viewService),
          _buildSeparatorLine(),
          _buildPasswordInput(state, viewService),
          _buildSeparatorLine(),
          _buildPasswordAgainInput(state),
          _buildBottomLine(Colors.grey[100]),
          _buildRegisterButton(state, dispatch),
          _buildBottomLine(Colors.transparent),
        ],
      ),
    ),
  );
}

Widget _buildUserNameInput(LoginState state, ViewService viewService) {
  final color = GlobalStore.themePrimaryIcon;
  final focusNode =
      state.currentPage == 0 ? state.passwordFocusNode : state.phoneFocusNode;
  return Padding(
    padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 20.0),
    child: TextFormField(
      controller: state.userController,
      maxLines: 1,
      keyboardType: TextInputType.text,
      autocorrect: false,
      autofocus: false,
      enabled: true,
      onEditingComplete: () =>
          FocusScope.of(viewService.context).requestFocus(focusNode),
      decoration: InputDecoration(
        icon: Icon(Icons.person, color: color),
        hintText: "用户名",
        border: InputBorder.none,
      ),
      style: TextStyle(fontSize: 16),
    ),
  );
}

Widget _buildCellPhoneInput(LoginState state, ViewService viewService) {
  final color = GlobalStore.themePrimaryIcon;
  return Padding(
    padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 20.0),
    child: TextFormField(
      controller: state.phoneController,
      maxLines: 1,
      keyboardType: TextInputType.text,
      focusNode: state.phoneFocusNode,
      autocorrect: false,
      autofocus: false,
      enabled: true,
      onEditingComplete: () => FocusScope.of(viewService.context)
          .requestFocus(state.passwordFocusNode),
      decoration: InputDecoration(
        icon: Icon(Icons.phone_iphone, color: color),
        hintText: "手机号码",
        border: InputBorder.none,
      ),
      style: TextStyle(fontSize: 16),
    ),
  );
}

Widget _buildPasswordInput(LoginState state, ViewService viewService) {
  final color = GlobalStore.themePrimaryIcon;
  return Padding(
    padding: const EdgeInsets.only(left: 25, right: 25, top: 20),
    child: TextFormField(
      controller: state.passwordController,
      keyboardType: TextInputType.text,
      focusNode: state.passwordFocusNode,
      onEditingComplete: () => FocusScope.of(viewService.context)
          .requestFocus(state.passwordAgainFocusNode),
      decoration: InputDecoration(
        icon: Icon(Icons.lock, color: color),
        hintText: "密码",
        border: InputBorder.none,
      ),
      textInputAction: TextInputAction.done,
      maxLines: 1,
      obscureText: true,
      style: TextStyle(fontSize: 16.0),
    ),
  );
}

Widget _buildPasswordAgainInput(LoginState state) {
  final color = GlobalStore.themePrimaryIcon;
  return Padding(
    padding: const EdgeInsets.only(left: 25, right: 25, top: 20),
    child: TextFormField(
      controller: state.passwordAgainController,
      keyboardType: TextInputType.text,
      focusNode: state.passwordAgainFocusNode,
      decoration: InputDecoration(
        icon: Icon(Icons.lock, color: color),
        hintText: "再输入密码",
        border: InputBorder.none,
      ),
      textInputAction: TextInputAction.done,
      maxLines: 1,
      obscureText: true,
      style: TextStyle(fontSize: 16.0),
    ),
  );
}

Widget _buildForgetPassword(ViewService viewService) {
  return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: FlatButton(
          shape: const StadiumBorder(),
          onPressed: () {
            Navigator.of(viewService.context)
                .pushNamed(PageNames.resetPasswordPage);
          },
          child: Text("忘记密码",
              style: TextStyle(
                  fontSize: 16.0, decoration: TextDecoration.underline))));
}

Widget _buildSeparatorLine() {
  return Container(
    width: 250.0,
    height: 1.0,
    color: Colors.grey[100],
    padding: const EdgeInsets.only(top: 10.0),
  );
}

Widget _buildBottomLine(Color color) {
  return Container(
    width: 250.0,
    height: 1.0,
    color: color,
    margin: const EdgeInsets.only(bottom: 20.0),
  );
}

Widget _buildSignInButton(LoginState state, Dispatch dispatch) {
  final fromColor = GlobalStore.themePrimaryIcon;
  final toColor = fromColor; //Colors.grey[200];
  return SubmitButton(
      title: "登录",
      fromColor: fromColor,
      toColor: toColor,
      onTap: () {
        dispatch(LoginActionCreator.onSignIn());
      });
}

Widget _buildRegisterButton(LoginState state, Dispatch dispatch) {
  final fromColor = GlobalStore.themePrimaryIcon;
  final toColor = fromColor; //Colors.grey[200];
  return SubmitButton(
      title: "注册",
      fromColor: fromColor,
      toColor: toColor,
      onTap: () {
        dispatch(LoginActionCreator.onRegister());
      });
}
