import 'package:fish_redux/fish_redux.dart';

import '../../common/consts/enum_types.dart';
import '../../global_store/global_state.dart';
import '../../models/configs/config.dart';
import '../../models/themes/theme_bean.dart';
import '../../models/users/user_info.dart';

class UserContractState
    implements GlobalBaseState, Cloneable<UserContractState> {
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
  UserContractState clone() {
    return UserContractState()
      ..currentTheme = currentTheme
      ..userInfo = userInfo
      ..appConfig = appConfig
      ..filterKeywords = filterKeywords
      ..searchMode = searchMode
      ..sourceType = sourceType
      ..contentType = contentType;
  }
}

UserContractState initState(Map<String, dynamic> args) {
  return UserContractState();
}
