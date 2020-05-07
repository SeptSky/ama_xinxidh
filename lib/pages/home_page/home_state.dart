import 'package:fish_redux/fish_redux.dart';

import '../../common/consts/enum_types.dart';
import '../../common/consts/globals.dart';
import '../../global_store/global_state.dart';
import '../../models/configs/config.dart';
import '../../models/themes/theme_bean.dart';
import '../../models/users/user_info.dart';

class HomeState with MapLike implements GlobalBaseState, Cloneable<HomeState> {
  int iconQuarterTurns;
  DateTime prevPopTime;
  DateTime lastPopTime;
  bool isFirstRun;

  bool get acceptBackPressing {
    return iconQuarterTurns != 0 ||
        lastPopTime.difference(prevPopTime) < Duration(seconds: 2);
  }

  @override
  HomeState clone() {
    return HomeState()
      ..iconQuarterTurns = iconQuarterTurns
      ..prevPopTime = prevPopTime
      ..lastPopTime = lastPopTime
      ..isFirstRun = isFirstRun
      ..currentTheme = currentTheme
      ..userInfo = userInfo
      ..appConfig = appConfig
      ..filterKeywords = filterKeywords
      ..searchMode = searchMode
      ..sourceType = sourceType
      ..contentType = contentType;
  }

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
}

HomeState initState(Map<String, dynamic> args) {
  return HomeState()
    ..iconQuarterTurns = 0
    ..prevPopTime = DateTime.now().add(Duration(minutes: -1))
    ..lastPopTime = DateTime.now()
    ..isFirstRun = Globals.isFirstRun;
}
