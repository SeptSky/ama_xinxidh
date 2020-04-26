import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart';

import '../../common/utilities/dialogs.dart';
import '../home_page/home_action.dart';
import 'single_widgets.dart';

BottomAppBar buildBottomAppBar(Color themeColor, Dispatch dispatch) {
  return BottomAppBar(
    color: themeColor,
    child: Row(
      children: <Widget>[
        buildNavigationButton(Icons.home, Colors.white,
            () => HomeReducerCreator.toggleIconReducer(0)),
        buildNavigationButton(Icons.business, Colors.white,
            () => Dialogs.showInfoToast("1", Colors.black87)),
        SizedBox(), // 增加一些间隔
        buildNavigationButton(Icons.school, Colors.white,
            () => Dialogs.showInfoToast("3", Colors.black87)),
        buildNavigationButton(Icons.person, Colors.white,
            () => HomeReducerCreator.toggleIconReducer(1)),
      ],
      mainAxisAlignment: MainAxisAlignment.spaceAround,
    ),
    shape: CircularNotchedRectangle(),
  );
}
