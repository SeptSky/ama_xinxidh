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

  static bool hasNotElements<T>(List<T> elements) {
    if (elements == null) return true;
    if (elements.length == 0) return true;
    return false;
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
