import 'package:flutter/material.dart';

class SubmitButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Color fromColor;
  final Color toColor;

  SubmitButton({Key key, this.title, this.onTap, this.fromColor, this.toColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.only(
            left: 60.0, right: 60.0, top: 10.0, bottom: 10.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
            gradient: LinearGradient(
              colors: [fromColor, toColor],
              stops: const [0.0, 1.0],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )),
        child: Text(
          title,
          style: TextStyle(fontSize: 20.0, color: Colors.white),
        ),
      ),
      onTap: onTap,
    );
  }
}
