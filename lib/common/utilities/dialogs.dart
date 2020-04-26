import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../global_store/global_store.dart';

class Dialogs {
  static void showInfoToast(String infoMsg, Color bgColor) {
    Fluttertoast.showToast(
        msg: infoMsg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: bgColor,
        textColor: Colors.white);
  }

  static void showErrorToast(String errMsg) {
    Fluttertoast.showToast(
        msg: errMsg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white);
  }

  static void showMessageDialog(BuildContext context, String msgText) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
            content: Text(msgText),
          );
        });
  }

  static void showMessageDialogWithButton(
      BuildContext context, String title, String msgText) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
            content: Text(msgText),
            title: Center(
                child: Text(
              title,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold),
            )),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('关闭', style: _buildButtonStyle())),
            ],
          );
        });
  }

  static Future<String> showConfirmDialog(
      BuildContext context, String confirmText) async {
    final result = await showDialog(
      context: context,
      barrierDismissible: false, //// user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('提示'),
          content: Text(confirmText),
          actions: [
            FlatButton(
                child: Text('否', style: _buildButtonStyle()),
                onPressed: () => Navigator.pop(context, 'no')),
            FlatButton(
                child: Text('是', style: _buildButtonStyle()),
                onPressed: () => Navigator.pop(context, 'yes')),
          ],
        );
      },
    );
    return result;
  }

  static TextStyle _buildButtonStyle() {
    return TextStyle(fontSize: 16, color: GlobalStore.themePrimaryBackground);
  }
}
