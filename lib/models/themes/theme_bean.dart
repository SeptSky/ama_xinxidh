import '../../common/utilities/theme_util.dart';
import 'color_bean.dart';

class ThemeBean {
  String themeName;
  ColorBean colorBean;
  String themeType;

  ThemeBean({this.themeName, this.colorBean, this.themeType});

  static ThemeBean defaultTheme() {
    return ThemeBean(
      themeName: InnerTheme.greenTheme,
      colorBean: ColorBean.fromColor(InnerThemeColor.greenColor),
      themeType: InnerTheme.greenTheme,
    );
  }

  static ThemeBean fromMap(Map<String, dynamic> map) {
    ThemeBean bean = new ThemeBean();
    bean.themeName = map['themeName'];
    bean.colorBean = ColorBean.fromMap(map['colorBean']);
    bean.themeType = map['themeType'];
    return bean;
  }

  Map<dynamic, dynamic> toMap() {
    return {
      'themeName': themeName,
      'colorBean': colorBean.toMap(),
      'themeType': themeType
    };
  }
}
