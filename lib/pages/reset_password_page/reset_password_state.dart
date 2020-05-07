import 'package:fish_redux/fish_redux.dart';

import '../../common/consts/enum_types.dart';
import '../../global_store/global_state.dart';
import '../../models/configs/config.dart';
import '../../models/themes/theme_bean.dart';
import '../../models/users/user_info.dart';

class ResetPasswordState implements GlobalBaseState, Cloneable<ResetPasswordState> {

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
  String filterKeywords;

  @override
  bool searchMode;

  @override
  SourceType sourceType;

  @override
  ContentType contentType;

  @override
  ResetPasswordState clone() {
    return ResetPasswordState()
      ..isLoadingWebData = isLoadingWebData
      ..currentTheme = currentTheme
      ..userInfo = userInfo
      ..appConfig = appConfig
      ..filterKeywords = filterKeywords
      ..searchMode = searchMode
      ..sourceType = sourceType
      ..contentType = contentType;
  }
}

ResetPasswordState initState(Map<String, dynamic> args) {
  return ResetPasswordState();
}
