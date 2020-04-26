import 'package:fish_redux/fish_redux.dart';

import '../../common/consts/enum_types.dart';
import '../../global_store/global_state.dart';
import '../../models/configs/config.dart';
import '../../models/themes/theme_bean.dart';
import '../../models/users/user_info.dart';

class PrivateContractState
    implements GlobalBaseState, Cloneable<PrivateContractState> {
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
  PrivateContractState clone() {
    return PrivateContractState()
      ..currentTheme = currentTheme
      ..userInfo = userInfo
      ..appConfig = appConfig
      ..searchMode = searchMode
      ..sourceType = sourceType
      ..contentType = contentType;
  }
}

PrivateContractState initState(Map<String, dynamic> args) {
  return PrivateContractState();
}
