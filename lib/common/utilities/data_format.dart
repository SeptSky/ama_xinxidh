class DataFormat {
  static String formatUnderline(String textStr) {
    if (textStr == null || textStr == '') {
      return '';
    }
    var newTextStr = textStr.replaceAll('_', '\$');
    return newTextStr;
  }

  static String formatArgument(String argStr) {
    if (argStr == null || argStr == '') {
      return '';
    }
    var newArgStr = argStr.replaceAll('=', '\$equ\$');
    newArgStr = newArgStr.replaceAll('&', '\$and\$');
    newArgStr = newArgStr.replaceAll('/', '\$sla\$');
    return newArgStr.replaceAll(';', '\$sem\$');
  }
}
