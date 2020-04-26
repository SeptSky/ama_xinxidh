import '../../../common/data_io/web_api.dart';

class WebPage {
  /// 打开指定网址的页面，并获取页面的body内容
  static dynamic getPageBodyFromUrl(String url) async {
    var webApi = WebApi();
    var body = await webApi.getBodyFromUrl(url);
    print(body.toString());
  }
}
