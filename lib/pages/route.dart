import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:flutter/widgets.dart' hide Action;

import '../common/consts/page_names.dart';
import '../global_store/global_state.dart';
import '../global_store/global_store.dart';
import 'about_page/about_page.dart';
import 'entity_edit_page/entity_edit_page.dart';
import 'help_page/help_page.dart';
import 'home_page/home_page.dart';
import 'info_nav_page/info_nav_page.dart';
import 'intro_page/intro_page.dart';
import 'keyword_nav_page/keyword_nav_page.dart';
import 'keyword_related_page/keyword_related_page.dart';
import 'login_page/login_page.dart';
import 'main_page/main_page.dart';
import 'menu_page/menu_page.dart';
import 'mine_page/mine_page.dart';
import 'private_contract_page/private_contract_page.dart';
import 'reset_password_page/reset_password_page.dart';
import 'theme_page/theme_page.dart';
import 'user_contract_page/user_contract_page.dart';

/// 注册页面路由是为了push操作能够打开相应的页面
final AbstractRoutes routes = PageRoutes(
  pages: _buildPagesRoutes(),
  visitor: (String path, Page<Object, dynamic> page) {
    /// 只有特定的范围的 Page 才需要建立和 AppStore 的连接关系
    /// 满足 Page<T> ，T 是 GlobalBaseState 的子类
    if (page.isTypeof<GlobalBaseState>()) {
      /// 建立 AppStore 驱动 PageStore 的单向数据连接
      /// 1. 参数1 AppStore
      /// 2. 参数2 当 AppStore.state 变化时, PageStore.state 该如何变化
      page.connectExtraStore<GlobalState>(GlobalStore.store,
          (Object pageState, GlobalState appState) {
        final GlobalBaseState p = pageState;
        if (pageState is Cloneable && appState.shouldUpdate(p)) {
          final Object copy = pageState.clone();
          final GlobalBaseState newState = copy;
          newState.searchMode = appState.searchMode;
          newState.sourceType = appState.sourceType;
          newState.contentType = appState.contentType;
          newState.hasError = appState.hasError;
          newState.isLoadingWebData = appState.isLoadingWebData;
          newState.currentTheme = appState.currentTheme;
          newState.userInfo = appState.userInfo;
          newState.appConfig = appState.appConfig;
          return newState;
        }
        return pageState;
      });
    }

    /// AOP
    /// 页面可以有一些私有的 AOP 的增强， 但往往会有一些 AOP 是整个应用下，所有页面都会有的。
    /// 这些公共的通用 AOP ，通过遍历路由页面的形式统一加入。
    page.enhancer.append(
      /// View AOP
      viewMiddleware: <ViewMiddleware<dynamic>>[
        safetyView<dynamic>(),
      ],

      /// Adapter AOP
      adapterMiddleware: <AdapterMiddleware<dynamic>>[safetyAdapter<dynamic>()],

      /// Effect AOP
      effectMiddleware: <EffectMiddleware<dynamic>>[
        _pageAnalyticsMiddleware<dynamic>(),
      ],

      /// Store AOP
      middleware: <Middleware<dynamic>>[
        logMiddleware<dynamic>(tag: page.runtimeType.toString()),
      ],
    );
  },
);

/// 简单的Effect AOP
/// 只针对页面的生命周期进行打印
EffectMiddleware<T> _pageAnalyticsMiddleware<T>({String tag = 'redux'}) {
  return (AbstractLogic<dynamic> logic, Store<T> store) {
    return (Effect<dynamic> effect) {
      return (Action action, Context<dynamic> ctx) {
        if (logic is Page<dynamic, dynamic> && action.type is Lifecycle) {
          print('${logic.runtimeType} ${action.type.toString()} ');
        }
        return effect?.call(action, ctx);
      };
    };
  };
}

Future appPushRoute(String path, BuildContext context,
    {Map<String, dynamic> params}) async {
  return await Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) => routes.buildPage(path, params)));
}

Future appPushRemoveRoute(String path, BuildContext context,
    {Map<String, dynamic> params}) async {
  return await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
          builder: (BuildContext context) => routes.buildPage(path, params)),
      ModalRoute.withName(path));
}

Future appPushNameRoute(String path, BuildContext context) async {
  return await Navigator.of(context).pushNamed(path);
}

/// todo: 实现根据角色权限配置返回相应的页面路由集合
Map<String, Page<Object, dynamic>> _buildPagesRoutes() {
  return <String, Page<Object, dynamic>>{
    PageNames.mainPage: MainPage(),
    PageNames.homePage: HomePage(),
    PageNames.infoNavPage: InfoNavPage(),
    PageNames.keywordNavPage: KeywordNavPage(),
    PageNames.keywordRelatedPage: KeywordRelatedPage(),
    PageNames.entityEditPage: EntityEditPage(),
    PageNames.menuPage: MenuPage(),
    PageNames.themePage: ThemePage(),
    PageNames.helpPage: HelpPage(),
    PageNames.aboutPage: AboutPage(),
    PageNames.minePage: MinePage(),
    PageNames.loginPage: LoginPage(),
    PageNames.resetPasswordPage: ResetPasswordPage(),
    PageNames.introPage: IntroPage(),
    PageNames.userContractPage: UserContractPage(),
    PageNames.privateContractPage: PrivateContractPage(),
  };
}
