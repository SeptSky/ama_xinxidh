import 'package:amainfoindex/global_store/global_store.dart';
import 'package:flutter/material.dart';

class NavFloatingButton extends StatelessWidget {
  final GestureTapCallback onTap;
  final GestureTapCallback onDoubleTap;
  final GestureTapCallback onLongTap;
  final IconData iconName;
  final int iconQuarterTurns;
  final Color color;
  final bool isActive;
  final String title;
  NavFloatingButton(
      {@required this.onTap,
      this.onDoubleTap,
      this.onLongTap,
      this.title,
      this.iconName,
      this.iconQuarterTurns = 0,
      this.color,
      @required this.isActive});
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
        child: InkWell(
          child: _buildButtonContent(context),
          onTap: onTap,
          onDoubleTap: onDoubleTap,
          onLongPress: onLongTap,
        ));
  }

  Widget _buildButtonContent(BuildContext context) {
    final titleColor = isActive ? GlobalStore.themeWhite : Colors.black38;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RotatedBox(
              quarterTurns: iconQuarterTurns,
              child: Icon(iconName, color: titleColor)),
          title != null ? const SizedBox(width: 8.0) : SizedBox(),
          title != null
              ? Text(title, style: TextStyle(color: titleColor))
              : SizedBox(),
        ],
      ),
    );
  }
}
