import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart';

import '../../common/consts/enum_types.dart';
import '../../global_store/global_state.dart';
import '../../models/configs/config.dart';
import '../../models/themes/theme_bean.dart';
import '../../models/users/user_info.dart';

class ThemeState implements GlobalBaseState, Cloneable<ThemeState> {
  bool isDeleting;
  Color customColor;
  List<ThemeBean> themes;

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
  ThemeState clone() {
    return ThemeState()
      ..isDeleting = isDeleting
      ..customColor = customColor
      ..themes = themes
      ..currentTheme = currentTheme
      ..userInfo = userInfo
      ..appConfig = appConfig
      ..searchMode = searchMode
      ..sourceType = sourceType
      ..contentType = contentType;
  }

  ThemeState() {
    isDeleting = false;
  }
}

ThemeState initState(Map<String, dynamic> args) {
  return ThemeState();
}
