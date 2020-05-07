import 'package:fish_redux/fish_redux.dart';

import '../common/consts/enum_types.dart';
import '../models/configs/config.dart';
import '../models/themes/theme_bean.dart';
import '../models/users/user_info.dart';

abstract class GlobalBaseState {
  bool get hasError;
  set hasError(bool hasError);

  String get filterKeywords;
  set filterKeywords(String filterKeywords);

  bool get searchMode;
  set searchMode(bool searchMode);

  SourceType get sourceType;
  set sourceType(SourceType sourceType);

  ContentType get contentType;
  set contentType(ContentType contentType);

  bool get isLoadingWebData;
  set isLoadingWebData(bool isLoadingWebData);

  ThemeBean get currentTheme;
  set currentTheme(ThemeBean currentThemeBean);

  UserInfo get userInfo;
  set userInfo(UserInfo userInfo);

  AppConfig get appConfig;
  set appConfig(AppConfig appConfig);
}

class GlobalState implements GlobalBaseState, Cloneable<GlobalState> {
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
  bool searchMode = false;

  @override
  SourceType sourceType = SourceType.normal;

  @override
  ContentType contentType = ContentType.infoEntity;

  @override
  GlobalState clone() {
    return GlobalState()
      ..filterKeywords = filterKeywords
      ..searchMode = searchMode
      ..sourceType = sourceType
      ..contentType = contentType
      ..hasError = hasError
      ..isLoadingWebData = isLoadingWebData
      ..currentTheme = currentTheme
      ..userInfo = userInfo
      ..appConfig = appConfig
      ..appConfig.topic = appConfig.topic;
  }

  bool shouldUpdate(GlobalBaseState state) {
    assert(state != null);
    return !(searchMode != null &&
        searchMode == state.searchMode &&
        filterKeywords != null &&
        filterKeywords == state.filterKeywords &&
        sourceType != null &&
        sourceType == state.sourceType &&
        contentType != null &&
        contentType == state.contentType &&
        hasError != null &&
        hasError == state.hasError &&
        isLoadingWebData != null &&
        isLoadingWebData == state.isLoadingWebData &&
        currentTheme != null &&
        currentTheme == state.currentTheme &&
        userInfo != null &&
        userInfo == state.userInfo &&
        appConfig != null &&
        appConfig == state.appConfig);
  }
}
