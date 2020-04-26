import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart';

import '../../common/consts/enum_types.dart';
import '../../global_store/global_state.dart';
import '../../models/configs/config.dart';
import '../../models/themes/theme_bean.dart';
import '../../models/users/user_info.dart';

class LoginState implements GlobalBaseState, Cloneable<LoginState> {
  int currentPage = 0;
  var controller = PageController();
  var userController = TextEditingController();
  var phoneController = TextEditingController();
  var phoneFocusNode = FocusNode();
  var passwordController = TextEditingController();
  var passwordFocusNode = FocusNode();
  var passwordAgainController = TextEditingController();
  var passwordAgainFocusNode = FocusNode();

  @override
  bool hasError;

  @override
  bool isLoadingWebData;

  @override
  ThemeBean currentTheme;

  @override
  UserInfo userInfo;

  @override
  AppConfig appConfig;

  @override
  bool searchMode;

  @override
  SourceType sourceType;

  @override
  ContentType contentType;

  @override
  LoginState clone() {
    return LoginState()
      ..currentPage = currentPage
      ..controller = controller
      ..userController = userController
      ..phoneController = phoneController
      ..phoneFocusNode = phoneFocusNode
      ..passwordController = passwordController
      ..passwordFocusNode = passwordFocusNode
      ..passwordAgainController = passwordAgainController
      ..passwordAgainFocusNode = passwordAgainFocusNode
      ..isLoadingWebData = isLoadingWebData
      ..currentTheme = currentTheme
      ..userInfo = userInfo
      ..appConfig = appConfig
      ..searchMode = searchMode
      ..sourceType = sourceType
      ..contentType = contentType;
  }
}

LoginState initState(Map<String, dynamic> args) {
  return LoginState();
}
