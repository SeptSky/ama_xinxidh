import 'dart:convert';

import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart';

import '../common/consts/constants.dart';
import '../common/consts/enum_types.dart';
import '../common/consts/keys.dart';
import '../common/utilities/shared_util.dart';
import '../common/utilities/theme_util.dart';
import '../models/configs/config.dart';
import '../models/configs/topic_def.dart';
import '../models/themes/theme_bean.dart';
import '../models/users/user_info.dart';
import 'global_action.dart';
import 'global_reducer.dart';
import 'global_state.dart';

/// 建立一个AppStore
/// 目前它的功能只有切换主题
class GlobalStore {
  static Store<GlobalState> _globalStore;
  static List<TopicDef> _stackedTopics = List<TopicDef>();

  static Store<GlobalState> get store {
    if (_globalStore != null) {
      return _globalStore;
    }
    return _globalStore =
        createStore<GlobalState>(GlobalState(), buildReducer());
  }

  static ThemeBean get currentTheme {
    return store.getState().currentTheme;
  }

  static ThemeData get themeData {
    return ThemeUtil.getInstance().getTheme(currentTheme);
  }

  //当为夜间模式时候，白色替换为灰色
  static Color get themeWhite {
    final themeType = currentTheme.themeType;
    return themeType == InnerTheme.darkTheme ? Colors.grey : Colors.white;
  }

  //当为夜间模式时候，黑色替换为白色
  static Color get themeBlack {
    final themeType = currentTheme.themeType;
    return themeType == InnerTheme.darkTheme ? Colors.white : Colors.grey[700];
  }

  //当为夜间模式时候，白色背景替换为特定灰色
  static Color get themeWhiteBackground {
    final themeType = currentTheme.themeType;
    return themeType == InnerTheme.darkTheme ? Colors.grey : Colors.white;
  }

  //获取列表项的背景颜色
  static Color get themeItemBackground {
    return themeData.cardColor;
  }

  //当为夜间模式时候，图标主题色替换为白色
  static Color get themePrimaryIcon {
    final themeType = currentTheme.themeType;
    return themeType == InnerTheme.darkTheme
        ? Colors.white
        : themeData.primaryColor;
  }

  //当为夜间模式时候，主题色背景替换为特定灰色
  static Color get themePrimaryBackground {
    final themeType = currentTheme.themeType;
    return themeType == InnerTheme.darkTheme
        ? Colors.grey[800]
        : themeData.primaryColor;
  }

  static TextStyle get titleStyle {
    return themeData.textTheme.title;
  }

  static TextStyle get subtitleStyle {
    return themeData.textTheme.caption;
  }

  static TextStyle get keywordStyle {
    return TextStyle(fontSize: 15.0);
  }

  static String get filterKeywords {
    return store.getState().filterKeywords;
  }

  static bool get searchMode {
    return store.getState().searchMode ?? false;
  }

  static SourceType get sourceType {
    return store.getState().sourceType ?? SourceType.normal;
  }

  static ContentType get contentType {
    return store.getState().contentType ?? ContentType.infoEntity;
  }

  static bool get hasError {
    return store.getState().hasError ?? false;
  }

  static bool get isLoadingWebData {
    return store.getState().isLoadingWebData ?? false;
  }

  static UserInfo get userInfo {
    return store.getState().userInfo;
  }

  static AppConfig get appConfig {
    return store.getState().appConfig;
  }

  static TopicDef get currentTopicDef {
    return appConfig.topic;
  }

  static void pushTopic() {
    _stackedTopics.add(currentTopicDef);
  }

  static TopicDef popTopic() {
    if (_stackedTopics.length > 0) {
      return _stackedTopics.removeLast();
    }
    return null;
  }

  static void addFilterKeyword(String keywordName) {
    if (filterKeywords != null) {
      var keywordArray = filterKeywords.split(',');
      final index = keywordArray.indexOf(keywordName);
      if (index < 0) {
        keywordArray.add(keywordName);
        final newFilterKeywords = keywordArray.join(',');
        store.dispatch(
            GlobalReducerCreator.setFilterKeywordsReducer(newFilterKeywords));
      }
    } else {
      store
          .dispatch(GlobalReducerCreator.setFilterKeywordsReducer(keywordName));
    }
  }

  static void delFilterKeyword(String keywordName) {
    if (filterKeywords != null) {
      var keywordArray = filterKeywords.split(',');
      final index = keywordArray.indexOf(keywordName);
      if (index >= 0) {
        keywordArray.remove(keywordName);
        if (keywordArray.length > 0) {
          final newFilterKeywords = keywordArray.join(',');
          store.dispatch(
              GlobalReducerCreator.setFilterKeywordsReducer(newFilterKeywords));
        } else {
          store.dispatch(GlobalReducerCreator.setFilterKeywordsReducer(null));
        }
      }
    }
  }

  static Future clearLocalCache() async {
    final globalState = store.getState();
    final cache = SharedUtil.instance;
    final isFirstRun = await cache.getBoolean(Keys.isFirstRun);
    final latestMessage = await cache.getString(Keys.latestMessage);
    await cache.clearCacheData();
    final appConfig = globalState.appConfig;
    await cache.saveBoolean(Keys.isFirstRun, isFirstRun);
    await cache.saveString(Keys.latestMessage, latestMessage);
    await cache.saveString(Keys.appConfig, jsonEncode(appConfig.toJson()));
    if (appConfig.topic.topicId == Constants.indexTopicId) {
      await cache.saveString(
          Keys.topicDef, jsonEncode(appConfig.topic.toJson()));
    }
    final themeBean = globalState.currentTheme;
    cache.saveString(Keys.currentThemeBean, jsonEncode(themeBean.toMap()));
    final userInfo = GlobalStore.userInfo;
    if (userInfo.userName != Constants.anonymityUser) {
      await cache.saveString(Keys.userInfo, jsonEncode(userInfo.toJson()));
    }
  }
}
