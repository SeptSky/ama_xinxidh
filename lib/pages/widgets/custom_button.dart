import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final GestureTapCallback onTap;
  final Color color;
  final String title;
  CustomButton({@required this.onTap, this.color, this.title});
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
        ));
  }

  Widget _buildButtonContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(width: 8.0),
          Text(
            title,
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(width: 8.0),
        ],
      ),
    );
  }
}
