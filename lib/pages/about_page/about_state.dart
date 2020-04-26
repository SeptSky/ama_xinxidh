import 'package:fish_redux/fish_redux.dart';

import '../../common/consts/enum_types.dart';
import '../../global_store/global_state.dart';
import '../../models/configs/config.dart';
import '../../models/themes/theme_bean.dart';
import '../../models/users/user_info.dart';

class AboutState implements GlobalBaseState, Cloneable<AboutState> {
  List<String> descriptions = [];

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
  AboutState clone() {
    return AboutState()
      ..descriptions = descriptions
      ..currentTheme = currentTheme
      ..userInfo = userInfo
      ..appConfig = appConfig
      ..searchMode = searchMode
      ..sourceType = sourceType
      ..contentType = contentType;
  }
}

AboutState initState(Map<String, dynamic> args) {
  return AboutState();
}
