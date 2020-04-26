import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../common/consts/page_names.dart';
import '../../common/i10n/localization_intl.dart';
import '../../common/utilities/theme_util.dart';
import '../../global_store/global_store.dart';
import '../route.dart';
import 'main_state.dart';

/// 状态数据变化刷新页面的本质：就是底层自动调用buildView方法，将变化的数据传入刷新界面
Widget buildView(MainState state, Dispatch dispatch, ViewService viewService) {
  var currentLocale = Locale('zh', 'CN');
  var currentTheme = state.currentTheme ?? GlobalStore.currentTheme;
  return MaterialApp(
    title: '信息导航',
    debugShowCheckedModeBanner: false,
    theme: ThemeUtil.getInstance().getTheme(currentTheme),
    home: routes.buildPage(PageNames.homePage, null),
    onGenerateRoute: (RouteSettings settings) {
      return MaterialPageRoute<Object>(builder: (BuildContext context) {
        return routes.buildPage(settings.name, settings.arguments);
      });
    },
    localizationsDelegates: [
      // ... app-specific localization delegate[s] here
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      LinuxLocalizationsDelegate()
    ],
    supportedLocales: [
      const Locale('en', 'US'), // 美国英语
      const Locale('zh', 'CN'), // 中文简体
    ],
    localeResolutionCallback:
        (Locale locale, Iterable<Locale> supportedLocales) {
      debugPrint(
          "locale:$locale   sups:$supportedLocales  currentLocale:$currentLocale");
      if (currentLocale == locale) return currentLocale;
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale == locale) {
          // model.currentLocale = locale;
          // model.currentLanguageCode = [locale.languageCode, locale.countryCode];
          // locale.countryCode == "CN"
          //     ? model.currentLanguage = "中文"
          //     : model.currentLanguage = "English";
          return currentLocale;
        }
      }
      // if (model.currentLocale == null) {
      //   model.currentLocale = Locale('zh', "CN");
      //   return model.currentLocale;
      // }
      return currentLocale;
    },
    localeListResolutionCallback:
        (List<Locale> locales, Iterable<Locale> supportedLocales) {
      debugPrint("locatassss:$locales  sups:$supportedLocales");
      return currentLocale;
    },
    locale: currentLocale,
  );
}
