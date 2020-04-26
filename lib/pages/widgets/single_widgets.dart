import 'package:flutter/material.dart';

import '../../global_store/global_store.dart';

UnderlineTabIndicator buildUnderlineBox(Color bgColor, Color borderColor) {
  return UnderlineTabIndicator(
      borderSide: BorderSide(width: 1.0, color: borderColor),
      insets: EdgeInsets.fromLTRB(2, 0, 0, 0));
}

BoxDecoration buildCommonBox(Color bgColor, Color borderColor, double radius) {
  return BoxDecoration(
      //背景
      color: bgColor,
      //设置四周圆角 角度
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      //设置四周边框
      border: Border.all(width: 1, color: borderColor));
}

Container buildBoxContainer(
    Color bgColor, Color borderColor, double radius, Widget child) {
  return Container(
      padding: const EdgeInsets.all(4),
      decoration: buildCommonBox(bgColor, borderColor, radius),
      child: child);
}

GestureDetector buildBoxContainerWithTap(
    Color bgColor, Color borderColor, double radius, Widget child,
    {Function onTap, Function onLongPress}) {
  return GestureDetector(
      child: buildBoxContainer(bgColor, borderColor, radius, child),
      onTap: onTap,
      onLongPress: onLongPress);
}

GestureDetector buildActionItem(Widget child, {Function onTap}) {
  return buildBoxContainerWithTap(null, Colors.transparent, 5.0, child,
      onTap: onTap);
}

BoxDecoration buildShadowBox(Color bgColor, Color borderColor, double radius) {
  return BoxDecoration(
      //背景
      color: bgColor,
      //设置四周圆角 角度
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      //设置四周边框
      border: Border.all(width: 1, color: borderColor),
      boxShadow: [
        const BoxShadow(
            color: Color(0x99909090),
            offset: Offset(5.0, 5.0),
            blurRadius: 10.0,
            spreadRadius: 2.0),
        // BoxShadow(color: Color(0x9900FF00), offset: Offset(1.0, 1.0)),
        // BoxShadow(color: Color(0xFF0000FF))
      ]);
}

Container buildTextBox(String textStr) {
  return Container(
      child: Text(
    textStr ?? '',
    style: GlobalStore.subtitleStyle,
  ));
}

Widget buildText(String title,
    {double fontSize = 15, Color fontColor = Colors.black}) {
  return Text(title, style: TextStyle(fontSize: fontSize, color: fontColor));
}

Widget buildTextLink(String title,
    {double fontSize = 15,
    Color fontColor = Colors.black,
    @required Function onTap}) {
  return InkWell(
      child: Text(title,
          style: TextStyle(
              fontSize: fontSize,
              decoration: TextDecoration.underline,
              color: fontColor)),
      onTap: onTap);
}

Container buildIcon(IconData iconName,
    {double size, double margin = 8.0, Color color}) {
  return Container(
      margin: EdgeInsets.all(margin),
      child: Icon(iconName, size: size, color: color));
}

/// 创建带事件响应的图标
Widget buildIconWithTap(IconData iconName, Function onTap,
    {double size = 16.0, double margin = 8.0, Color color}) {
  if (iconName == null) {
    return SizedBox();
  }
  return GestureDetector(
      child: Container(
          margin: EdgeInsets.all(margin),
          child: Icon(iconName, size: size, color: color)),
      onTap: onTap);
}

/// 创建带事件响应的CheckBox图标
GestureDetector buildCheckBoxIconWithTap(bool checked, Function onCheckTap) {
  return GestureDetector(
      child: Container(
          margin: const EdgeInsets.only(right: 8.0),
          child: checked
              ? const Icon(Icons.check_box, color: Colors.grey)
              : const Icon(Icons.check_box_outline_blank, color: Colors.grey)),
      onTap: onCheckTap);
}

ListTile buildSettingSwitch(
    IconData iconName, String title, bool switchValue, Function onChanged) {
  return ListTile(
      leading: Icon(iconName, color: Colors.grey),
      title: Text(title, style: GlobalStore.titleStyle),
      trailing: Switch(
          value: switchValue,
          inactiveTrackColor: Colors.grey,
          onChanged: onChanged));
}

ListTile buildPageItem(IconData leadingIcon, String title,
    IconData trailingIcon, Color iconColor, Function onTap) {
  return ListTile(
      title: Text(title),
      leading: Icon(leadingIcon, color: iconColor),
      trailing: Icon(trailingIcon, color: iconColor),
      onTap: onTap);
}

Container buildImageBox(String imageUrl, {double size = 60.0}) {
  return imageUrl != null && imageUrl.isNotEmpty
      ? Container(
          margin: const EdgeInsets.only(right: 5.0),
          child: Image.network(imageUrl, width: size, height: size))
      : Container(
          child: Icon(Icons.http,
              size: size / 2, color: GlobalStore.themePrimaryIcon),
          width: size,
          height: size);
}

Widget buildProgressIndicator(bool isLoading, Color color) {
  return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
          child: Opacity(
        opacity: isLoading ? 1.0 : 0.0,
        child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color)),
      )));
}

Widget buildCustomButton(String caption, Color color, Function onPressed) {
  return GestureDetector(
      child: Text(caption, style: TextStyle(fontSize: 16, color: color)),
      onTap: onPressed);
}

Widget buildDualButtonRow(Widget button1, Widget button2) {
  return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
    button1,
    SizedBox(width: 10),
    button2,
    SizedBox(width: 30),
  ]);
}

IconButton buildNavigationButton(
    IconData icon, Color iconColor, Function onButtonPressed) {
  return IconButton(
      icon: Icon(
        icon,
        color: iconColor,
      ),
      onPressed: onButtonPressed);
}

FloatingActionButton buildFloatingActionButton(
    Color backgroundColor, IconData icon, Function onButtonPressed) {
  return FloatingActionButton(
      onPressed: onButtonPressed,
      tooltip: '关键词导航',
      child: Icon(icon),
      backgroundColor: backgroundColor);
}

Widget buildErrorBox(Function onTap) {
  return Column(children: [
    const SizedBox(height: 40),
    buildIconWithTap(Icons.error, onTap,
        size: 48, color: GlobalStore.themePrimaryIcon),
    const SizedBox(height: 4),
    buildText('系统繁忙，请点击图标重试！')
  ]);
}

Widget buildNotFoundBox(String title, Function onTap) {
  return Column(children: [
    const SizedBox(height: 40),
    buildIconWithTap(Icons.sentiment_dissatisfied, onTap,
        size: 48, color: GlobalStore.themePrimaryIcon),
    const SizedBox(height: 4),
    buildText(title)
  ]);
}
