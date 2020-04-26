import 'package:fish_redux/fish_redux.dart';

import '../../../common/consts/enum_types.dart';
import '../../../global_store/global_state.dart';
import '../../../models/configs/config.dart';
import '../../../models/themes/theme_bean.dart';
import '../../../models/users/user_info.dart';

class KeywordState implements GlobalBaseState, Cloneable<KeywordState> {
  int keyId;
  int index;
  String title;
  bool isProperty;
  bool pressed;

  KeywordState({this.keyId, this.index, this.title, this.pressed});

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
  KeywordState clone() {
    return KeywordState()
      ..keyId = keyId
      ..index = index
      ..title = title
      ..isProperty = isProperty
      ..pressed = pressed
      ..currentTheme = currentTheme
      ..userInfo = userInfo
      ..appConfig = appConfig
      ..searchMode = searchMode
      ..sourceType = sourceType
      ..contentType = contentType;
  }
}

KeywordState initState(Map<String, dynamic> args) {
  var keywordState = KeywordState();
  return keywordState;
}
