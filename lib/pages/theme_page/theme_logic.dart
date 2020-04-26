import 'dart:convert';

import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/material_picker.dart';

import '../../common/consts/constants.dart';
import '../../common/consts/keys.dart';
import '../../common/utilities/dialogs.dart';
import '../../common/utilities/shared_util.dart';
import '../../common/utilities/theme_util.dart';
import '../../global_store/global_action.dart';
import '../../global_store/global_store.dart';
import '../../models/themes/color_bean.dart';
import '../../models/themes/theme_bean.dart';
import 'theme_action.dart';
import 'theme_state.dart';

class ThemeLogic {
  /// 加载主题列表：系统定义和用户自定义
  static Future loadThemeList(Dispatch dispatch, BuildContext context) async {
    final themes = await ThemeUtil.getInstance().getThemeListWithCache(context);
    dispatch(ThemeReducerCreator.initThemeReducer(themes));
  }

  /// 加载当前的主题数据
  static Future loadCurrentTheme(ThemeState state, Dispatch dispatch) async {
    final theme = await SharedUtil.instance.getString(Keys.currentThemeBean);
    if (theme == null) return;
    ThemeBean themeBean = ThemeBean.fromMap(jsonDecode(theme));
    if (themeBean.themeType == state.currentTheme?.themeType) return;
    GlobalStore.store
        .dispatch(GlobalReducerCreator.changeCurrentThemeReducer(themeBean));
    dispatch(ThemeReducerCreator.setCurrentThemeReducer(themeBean));
  }

  static void showColorPicker(
      ThemeState state, Dispatch dispatch, BuildContext context) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            elevation: 0.0,
            title: Text('选择颜色'),
            content: SingleChildScrollView(
              child: MaterialPicker(
                pickerColor: Theme.of(context).primaryColor,
                onColorChanged: (color) {
                  state.customColor = color;
                },
                enableLabel: true,
              ),
            ),
            actions: <Widget>[
              _buildCancelButton(context),
              _buildOkButton(state, dispatch, context),
            ],
          );
        });
  }

  static FlatButton _buildCancelButton(BuildContext context) {
    return FlatButton(
      child: Text(
        '取消',
        style: TextStyle(color: Colors.redAccent),
      ),
      onPressed: () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
    );
  }

  static FlatButton _buildOkButton(
      ThemeState state, Dispatch dispatch, BuildContext context) {
    return FlatButton(
      child: Text('确定'),
      onPressed: () async {
        final beans = await SharedUtil.instance.readList(Keys.themeBeans) ?? [];
        if (beans.length >= Constants.maxThemeCount) {
          Dialogs.showMessageDialog(context, '最多自定义10个主题');
          return;
        }
        ThemeBean themeBean = ThemeBean(
          themeName: '自定义主题' + " ${beans.length + 1}",
          themeType: '自定义主题' + " ${beans.length + 1}",
          colorBean: ColorBean.fromColor(state.customColor),
        );
        final data = jsonEncode(themeBean.toMap());
        beans.add(data);
        SharedUtil.instance.saveStringList(Keys.themeBeans, beans);
        loadThemeList(dispatch, context);
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
    );
  }
}
