import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action;

import '../widgets/custom_button.dart';
import '../widgets/single_widgets.dart';
import 'intro_action.dart';
import 'intro_state.dart';

/// 状态数据变化刷新页面的本质：就是底层自动调用buildView方法，将变化的数据传入刷新界面
Widget buildView(IntroState state, Dispatch dispatch, ViewService viewService) {
  var screenSize = MediaQuery.of(viewService.context).size;
  return Scaffold(
    body: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/xinxidh_splash.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(children: [
        SizedBox(
          height: screenSize.height * 3 / 4,
        ),
        CustomButton(
            onTap: () {
              dispatch(IntroActionCreator.onStartupApp(state.checkValue));
            },
            color: Colors.blue,
            title: '马上体验'),
        Expanded(child: SizedBox()),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Checkbox(
              value: state.checkValue,
              activeColor: Colors.blue,
              onChanged: (bool val) {
                dispatch(IntroReducerCreator.changeCheckValueReducer(val));
              }),
          buildText('已同意 '),
          buildTextLink('服务协议',
              onTap: () =>
                  dispatch(IntroActionCreator.onPressUserContractLink())),
          buildText(' 和 '),
          buildTextLink('隐私政策',
              onTap: () =>
                  dispatch(IntroActionCreator.onPressPrivateContractLink())),
        ]),
        SizedBox(height: 5),
      ]),
    ),
  );
}
