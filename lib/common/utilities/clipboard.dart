import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

///设置要复制到粘贴板中的内容
@immutable
class ClipboardData {
  /// Creates data for the system clipboard.
  const ClipboardData({this.text});

  /// Plain text variant of this clipboard data.
  final String text;
}

/// Utility methods for interacting with the system's clipboard.
///对粘贴板进行操作的类
class Clipboard {
  Clipboard._();

  // Constants for common [getData] [format] types.

  /// Plain text data format string.
  ///
  /// Used with [getData].
  static const String kTextPlain = 'text/plain';

  /// Stores the given clipboard data on the clipboard.
  ///将ClipboardData中的内容复制的粘贴板
  static Future<void> setData(ClipboardData data) async {
    await SystemChannels.platform.invokeMethod<void>(
      'Clipboard.setData',
      <String, dynamic>{
        'text': data.text,
      },
    );
  }

  /// Retrieves data from the clipboard that matches the given format.
  ///
  /// The `format` argument specifies the media type, such as `text/plain`, of
  /// the data to obtain.
  ///
  /// Returns a future which completes to null if the data could not be
  /// obtained, and to a [ClipboardData] object if it could.
  /// 获得粘贴板中的内容，这是个异步的操作
  static Future<ClipboardData> getData(String format) async {
    final Map<String, dynamic> result =
        await SystemChannels.platform.invokeMethod(
      'Clipboard.getData',
      format,
    );
    if (result == null) return null;
    return ClipboardData(text: result['text']);
  }
}
