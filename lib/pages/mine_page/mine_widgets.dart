import 'package:amainfoindex/pages/info_nav_page/info_nav_action.dart';
import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart';

import '../../global_store/global_store.dart';
import '../login_page/login_widgets.dart';
import '../widgets/submit_button.dart';
import 'mine_action.dart';
import 'mine_state.dart';

SingleChildScrollView buildMineBody(double screenHeight, double screenWidth,
    MineState state, Dispatch dispatch, ViewService viewService) {
  final barColor = GlobalStore.themePrimaryIcon;
  return SingleChildScrollView(
      child: Container(
          height: screenHeight,
          width: screenWidth,
          child: Padding(
              padding: const EdgeInsets.only(top: 55.0),
              child: Column(mainAxisSize: MainAxisSize.max, children: [
                buildLoginLogo(),
                _buildSeparatorBar(barColor),
                _buildUserInfo(),
                _buildSeparatorBar(barColor),
                _buildRefreshBar(viewService),
                _buildContentBody(),
                _buildSignInButton(state, dispatch),
                _buildSeparatorBar(Colors.transparent),
              ]))));
}

Widget _buildUserInfo() {
  final userInfo = GlobalStore.userInfo;
  return Container(
      color: Colors.white,
      child: Row(children: [
        SizedBox(width: 10),
        Icon(Icons.person, color: GlobalStore.themePrimaryIcon),
        Expanded(child: Text(userInfo.userName)),
        Text(userInfo.roleName),
        SizedBox(width: 10),
        Text('导航金：${userInfo.score}'),
        SizedBox(width: 10),
      ]));
}

Widget _buildRefreshBar(ViewService viewService) {
  return GestureDetector(
    child: Container(
        color: Colors.white,
        child: Row(children: [
          SizedBox(width: 10),
          Icon(Icons.refresh, color: GlobalStore.themePrimaryIcon),
          Expanded(child: Text('清除缓存')),
          SizedBox(width: 10),
        ])),
    onTap: () {
      viewService.broadcast(InfoNavPageActionCreator.onClearCache());
    },
  );
}

Widget _buildSeparatorBar(Color color) {
  return Container(
    height: 10.0,
    color: color,
    padding: const EdgeInsets.only(top: 10.0),
  );
}

Widget _buildContentBody() {
  return Expanded(child: Container());
}

Widget _buildSignInButton(MineState state, Dispatch dispatch) {
  final fromColor = GlobalStore.themePrimaryIcon;
  final toColor = fromColor; //Colors.grey[200];
  return SubmitButton(
      title: "退出",
      fromColor: fromColor,
      toColor: toColor,
      onTap: () {
        dispatch(MineActionCreator.onSignOut());
      });
}
