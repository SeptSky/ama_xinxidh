import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart' hide Action;
import 'package:flutter/services.dart';
import 'package:fluwx_no_pay/fluwx_no_pay.dart';

import 'common/consts/constants.dart';
import 'common/consts/globals.dart';
import 'common/consts/keys.dart';
import 'common/consts/page_names.dart';
import 'common/data_access/app_def.dart';
import 'common/data_access/webApi/info_nav_services.dart';
import 'common/utilities/dialogs.dart';
import 'common/utilities/environment.dart';
import 'common/utilities/shared_util.dart';
import 'global_store/global_state.dart';
import 'global_store/global_store.dart';
import 'models/configs/config.dart';
import 'models/configs/topic_def.dart';
import 'models/themes/theme_bean.dart';
import 'models/users/user_info.dart';
import 'pages/route.dart';

Future<Null> main() async {
  FlutterError.onError = (FlutterErrorDetails details) async {
    Zone.current.handleUncaughtError(details.exception, details.stack);
  };

  runZoned<Future<void>>(() async {
    final succeeded = await _initializeApp();
    Future.delayed(Duration(seconds: 2), () async {
      /// 使用routes启动主页面才能使得主题更改同步
      if (succeeded) {
        runApp(routes.buildPage(PageNames.mainPage, null));
      } else {
        Dialogs.showErrorToast('初始化失败，退出重试！');
        await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      }
    });
  }, onError: (error, stackTrace) async {
    await _reportError(error, stackTrace);
  });
}

/// 在界面创建之前，直接给全局状态赋值，没有必要触发界面刷新机制
/// 不要求执行顺序的异步方法使用Future.wait
Future<bool> _initializeApp() async {
  try {
    // 确保toast在没有context情况下能正常显示
    WidgetsFlutterBinding.ensureInitialized();
    registerWxApi(appId: "wx372e8223bee212f7");
    await _processUserConnection();
    final globalState = GlobalStore.store.getState();
    await _userLogin(globalState);
    await _loadLocalTheme(globalState);
    await _loadRemoteAppConfig(globalState);
    await GlobalStore.clearLocalCache();
  } catch (err) {
    return false;
  }
  return true;
}

Future _processUserConnection() async {
  var isFirstRun = await SharedUtil.instance.getBoolean(Keys.isFirstRun);
  isFirstRun = isFirstRun == null ? true : false;
  Globals.isFirstRun = isFirstRun;
  if (isFirstRun) {
    await SharedUtil.instance.saveBoolean(Keys.isFirstRun, false);
  }
  await InfoNavServices.saveUserConnectionInfo(isFirstRun);
}

/// 本地读取主题配置信息
Future _loadLocalTheme(GlobalState globalState) async {
  final theme = await SharedUtil.instance.getString(Keys.currentThemeBean);
  if (theme != null) {
    final currentTheme = ThemeBean.fromMap(jsonDecode(theme));
    globalState.currentTheme = currentTheme;
  } else {
    globalState.currentTheme = ThemeBean.defaultTheme();
  }
}

/// 远程加载用户描述信息
Future _userLogin(GlobalState globalState) async {
  final jsonString = await SharedUtil.instance.getString(Keys.userInfo);
  if (jsonString == null) {
    globalState.userInfo = UserInfo.getInstance();
  } else {
    globalState.userInfo = UserInfo.fromJson(jsonDecode(jsonString));
  }
}

/// 远程加载APP配置信息
Future _loadRemoteAppConfig(GlobalState globalState) async {
  final appConfig = await AppConfig.getInstance();
  if (appConfig == null) {
    throw Exception('读取配置信息失败！');
  }
  globalState.appConfig = appConfig;
  await _loadRemoteIndexTopics(globalState);
}

/// 远程加载主题索引定义信息
Future _loadRemoteIndexTopics(GlobalState globalState) async {
  TopicDef topic;
  final cache = SharedUtil.instance;
  final jsonString = await cache.getString(Keys.topicDef);
  if (jsonString != null) {
    topic = TopicDef.fromJson(jsonDecode(jsonString));
    if (topic.topicId != Constants.indexTopicId) {
      topic = null;
    }
  }
  if (topic == null) {
    topic =
        await InfoNavServices.getAppTopicFromWebApi(Xinxidh_App_Guid, -1, true);
    if (topic != null) {
      await cache.saveString(Keys.topicDef, jsonEncode(topic.toJson()));
    }
  }
  if (topic == null) {
    throw Exception('读取专题信息失败！');
  }
  globalState.appConfig.topic = topic;
}

Future _reportError(dynamic error, dynamic stackTrace) async {
  var errMsg = error.toString().trim();
  if (errMsg.isEmpty) return;
  errMsg = !Environment.isInDebugMode ? '系统繁忙，请稍候再试！' : errMsg;
  Dialogs.showErrorToast(errMsg);
}
