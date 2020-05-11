import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dialogs.dart';

class Tools {
  /// md5 加密
  static String generateMd5(String data) {
    var content = new Utf8Encoder().convert(data);
    var digest = md5.convert(content);

    return "$digest";
  }

  static Future openUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Dialogs.showErrorToast('打开网页失败！');
    }
  }

  static bool isEmptyStr(String str) {
    return str == null || str == '';
  }

  static bool isNotEmptyStr(String str) {
    return str != null && str != '';
  }

  static bool hasElements<T>(List<T> elements) {
    return elements != null && elements.length > 0;
  }

  static bool hasNotElements<T>(List<T> elements) {
    return elements == null || elements.length == 0;
  }

  static String getPathFromUrl(String url) {
    assert(url != null && url.length > 0);
    final pos = url.lastIndexOf('/');
    return url.substring(0, pos + 1);
  }

  static String getFileNameFromUrl(String url) {
    assert(url != null && url.length > 0);
    final pos = url.lastIndexOf('/');
    return url.substring(pos + 1);
  }
}
