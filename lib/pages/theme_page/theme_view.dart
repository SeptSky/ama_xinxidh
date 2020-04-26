import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action;

import '../../common/consts/constants.dart';
import '../../common/i10n/localization_intl.dart';
import '../../common/utilities/theme_util.dart';
import '../../global_store/global_store.dart';
import '../../models/themes/color_bean.dart';
import '../../models/themes/theme_bean.dart';
import '../widgets/custom_animated_switcher.dart';
import 'theme_action.dart';
import 'theme_state.dart';

/// 状态数据变化刷新页面的本质：就是底层自动调用buildView方法，将变化的数据传入刷新界面
Widget buildView(ThemeState state, Dispatch dispatch, ViewService viewService) {
  return Scaffold(
    appBar: AppBar(
      title: _buildThemeTitle(state, dispatch, viewService),
      actions: _buildThemeActions(state, dispatch, viewService),
    ),
    body: _buildThemeBody(state, dispatch, viewService),
  );
}

Text _buildThemeTitle(
    ThemeState state, Dispatch dispatch, ViewService viewService) {
  return Text(LinuxLocalizations.of(viewService.context).changeTheme);
}

List<Widget> _buildThemeActions(
    ThemeState state, Dispatch dispatch, ViewService viewService) {
  return <Widget>[
    state.themes != null && state.themes.length > Constants.innerThemeCount
        ? CustomAnimatedSwitcher(
            firstChild: IconButton(
              icon: Icon(
                Icons.border_color,
                size: 18,
                color: GlobalStore.themeWhite,
              ),
              onPressed: null,
            ),
            secondChild: IconButton(
              icon: Icon(
                Icons.check,
                color: GlobalStore.themeWhite,
              ),
              onPressed: null,
            ),
            hasChanged: state.isDeleting,
            onTap: () {
              dispatch(
                  ThemeReducerCreator.setDeleteFlagReducer(!state.isDeleting));
            },
          )
        : const SizedBox(),
  ];
}

Container _buildThemeBody(
    ThemeState state, Dispatch dispatch, ViewService viewService) {
  final size = MediaQuery.of(viewService.context).size;
  return Container(
    alignment: Alignment.topCenter,
    child: SingleChildScrollView(
      child: Wrap(
        children: _buildThemeBlockList(state, dispatch, viewService, size),
      ),
    ),
  );
}

List<Widget> _buildThemeBlockList(
    ThemeState state, Dispatch dispatch, ViewService viewService, Size size) {
  return state.themes == null
      ? []
      : List.generate(state.themes.length + 1, (index) {
          if (index == state.themes.length) {
            return _buildCustomThemeBlock(state, dispatch, viewService, size);
          }
          final themeBean = state.themes[index];
          return Stack(
            children: <Widget>[
              _buildInnerThemeBlock(
                  state, dispatch, viewService, themeBean, size),
              _buildRemoveThemeBlock(state, dispatch, viewService, index),
            ],
          );
        });
}

/// 构建内置主体块
Widget _buildInnerThemeBlock(ThemeState state, Dispatch dispatch,
    ViewService viewService, ThemeBean themeBean, Size size) {
  return AbsorbPointer(
    absorbing: state.isDeleting,
    child: InkWell(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      onTap: () => dispatch(ThemeActionCreator.onSelectTheme(themeBean)),
      child: Container(
        height: (size.width - 140) / 3,
        width: (size.width - 140) / 3,
        margin: const EdgeInsets.all(20),
        alignment: Alignment.center,
        child: Text(
          themeBean.themeName,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        decoration: BoxDecoration(
          color: themeBean.themeType == InnerTheme.darkTheme
              ? Colors.black
              : ColorBean.fromBean(themeBean.colorBean),
          shape: BoxShape.rectangle,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
      ),
    ),
  );
}

/// 构建自定义主体块
Widget _buildCustomThemeBlock(
    ThemeState state, Dispatch dispatch, ViewService viewService, Size size) {
  return AbsorbPointer(
    absorbing: state.isDeleting,
    child: Opacity(
      opacity: state.isDeleting ? 0 : 1,
      child: InkWell(
        onTap: () => dispatch(ThemeActionCreator.onCreateTheme()),
        child: Container(
          height: (size.width - 140) / 3,
          width: (size.width - 140) / 3,
          margin: const EdgeInsets.all(20),
          alignment: Alignment.center,
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 40,
          ),
          decoration: const BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              gradient: LinearGradient(colors: [
                Colors.redAccent,
                Colors.greenAccent,
                Colors.blueAccent,
              ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        ),
      ),
    ),
  );
}

/// 构建删除主体块
Widget _buildRemoveThemeBlock(
    ThemeState state, Dispatch dispatch, ViewService viewService, int index) {
  return Positioned(
    top: 0,
    right: 0,
    child: AbsorbPointer(
      // false可触发事件，true不可触发事件
      absorbing: !state.isDeleting,
      child: Opacity(
        opacity: state.isDeleting ? 1.0 : 0.0,
        child: index >= Constants.innerThemeCount
            ? IconButton(
                icon: const Icon(
                  Icons.cancel,
                  color: Colors.redAccent,
                ),
                onPressed: () =>
                    dispatch(ThemeActionCreator.onRemoveTheme(index)))
            : null,
      ),
    ),
  );
}
