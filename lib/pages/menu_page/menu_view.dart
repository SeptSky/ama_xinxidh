import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart';

import '../../common/consts/constants.dart';
import '../../common/consts/page_names.dart';
import '../../common/i10n/localization_intl.dart';
import '../../common/utilities/dialogs.dart';
import '../../common/utilities/tools.dart';
import '../../global_store/global_store.dart';
import '../widgets/animation_banner.dart';
import '../widgets/single_widgets.dart';
import 'menu_state.dart';

/// 状态数据变化刷新页面的本质：就是底层自动调用buildView方法，将变化的数据传入刷新界面
Widget buildView(MenuState state, Dispatch dispatch, ViewService viewService) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('信息导航'),
    ),
    body: _buildMenuBody(state, dispatch, viewService),
  );
}

Widget _buildMenuBody(
    MenuState state, Dispatch dispatch, ViewService viewService) {
  var themeColor = GlobalStore.themePrimaryIcon;
  final isLogin = GlobalStore.userInfo.userName != Constants.anonymityUser;
  return ListView(
    children: <Widget>[
      AnimationBanner(),
      isLogin
          ? _buildUserInfoPageItem(themeColor, viewService)
          : _buildLoginPageItem(themeColor, viewService),
      _buildThemePageItem(themeColor, viewService),
      _buildHelpPageItem(themeColor, viewService),
      _buildUserContractPageItem(themeColor, viewService),
      _buildUserPrivatePageItem(themeColor, viewService),
      _buildAboutPageItem(themeColor, viewService),
      _buildAuthorPageItem(themeColor, viewService),
    ],
  );
}

ListTile _buildAuthorPageItem(Color themeColor, ViewService viewService) {
  return buildPageItem(
      Icons.people, '联系作者', Icons.keyboard_arrow_right, themeColor, () {
    Dialogs.showMessageDialogWithButton(
        viewService.context, '订制检索专题', '\n微信：xinxidh\n\n邮箱：2583038804@qq.com');
  });
}

ListTile _buildAboutPageItem(Color themeColor, ViewService viewService) {
  return buildPageItem(
      Icons.info,
      LinuxLocalizations.of(viewService.context).aboutApp,
      Icons.keyboard_arrow_right,
      themeColor, () {
    Navigator.of(viewService.context).pushNamed(PageNames.aboutPage);
  });
}

ListTile _buildUserPrivatePageItem(Color themeColor, ViewService viewService) {
  return buildPageItem(
      Icons.room_service, '隐私政策', Icons.keyboard_arrow_right, themeColor, () {
    Navigator.of(viewService.context).pushNamed(PageNames.privateContractPage);
  });
}

ListTile _buildUserContractPageItem(Color themeColor, ViewService viewService) {
  return buildPageItem(
      Icons.headset_mic, '用户协议', Icons.keyboard_arrow_right, themeColor, () {
    Navigator.of(viewService.context).pushNamed(PageNames.userContractPage);
  });
}

ListTile _buildHelpPageItem(Color themeColor, ViewService viewService) {
  return buildPageItem(
      Icons.help, '操作指南', Icons.keyboard_arrow_right, themeColor, () {
    // Navigator.pop(viewService.context);
    _openHelpUrl(viewService.context);
  });
}

ListTile _buildThemePageItem(Color themeColor, ViewService viewService) {
  return buildPageItem(
      Icons.palette,
      LinuxLocalizations.of(viewService.context).changeTheme,
      Icons.keyboard_arrow_right,
      themeColor, () {
    Navigator.pop(viewService.context);
    Navigator.of(viewService.context).pushNamed(PageNames.themePage);
  });
}

ListTile _buildLoginPageItem(Color themeColor, ViewService viewService) {
  return buildPageItem(
      Icons.person, '登录', Icons.keyboard_arrow_right, themeColor, () {
    Navigator.pop(viewService.context);
    Navigator.of(viewService.context).pushNamed(PageNames.loginPage);
  });
}

ListTile _buildUserInfoPageItem(Color themeColor, ViewService viewService) {
  final userInfo = GlobalStore.userInfo;
  final userTitle = '${userInfo.userName}  ${userInfo.roleName}';
  return buildPageItem(
      Icons.person, userTitle, Icons.keyboard_arrow_right, themeColor, () {
    Navigator.pop(viewService.context);
    Navigator.of(viewService.context).pushNamed(PageNames.minePage);
  });
}

void _openHelpUrl(BuildContext context) {
  var helpUrl = GlobalStore.currentTopicDef.helpUrl;
  if (helpUrl.indexOf('.md') > 0 || helpUrl.indexOf('.gif') > 0) {
    Navigator.of(context).pushNamed(PageNames.helpPage);
  } else {
    Tools.openUrl(helpUrl);
  }
}
