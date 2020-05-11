import 'tools.dart';

class DataFormat {
  static String formatUnderline(String textStr) {
    if (Tools.isEmptyStr(textStr)) {
      return '';
    }
    var newTextStr = textStr.replaceAll('_', '\$');
    return newTextStr;
  }

  static String formatArgument(String argStr) {
    if (Tools.isEmptyStr(argStr)) {
      return '';
    }
    var newArgStr = argStr.replaceAll('=', '\$equ\$');
    newArgStr = newArgStr.replaceAll('&', '\$and\$');
    newArgStr = newArgStr.replaceAll('/', '\$sla\$');
    return newArgStr.replaceAll(';', '\$sem\$');
  }
}
