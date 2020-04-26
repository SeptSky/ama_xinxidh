import 'package:dio/dio.dart';

import '../utilities/file_util.dart';

class WebApi {
  final String baseUrl;
  final int connectTimeout = 30000;
  final int receiveTimeout = 30000;

  static Dio _dio;
  static WebApi _instance;
  // static WebApi get instance => _getInstance();

  // 工厂模式的构造函数可以返回对象实例
  // 可选参数在无输入时为null值
  factory WebApi({String baseUrl}) {
    return _getInstance(baseUrl);
  }

  dynamic getDataFromWebApi(String url, {Options options}) async {
    var response = await _dio.get(url, options: options);
    if (response.statusMessage == "OK") {
      return response.data;
    }
  }

  dynamic getDataFromWebApiWithToken(String url, String token) async {
    var options = Options(
        headers: {"Authorization": "Bearer $token"},
        contentType: 'application/x-www-form-urlencoded');
    var response = await _dio.get(url, options: options);
    if (response.statusMessage == "OK") {
      return response.data;
    }
  }

  // url使用相对路径
  dynamic postDataFromWebApi(String url, dynamic data) async {
    var options = Options(contentType: 'application/x-www-form-urlencoded');
    var response = await _dio.post(url, data: data, options: options);
    if (response.statusMessage == "OK") {
      return response.data;
    }
  }

  // url使用绝对路径
  dynamic postBodyFromWebApi(String url, String body) async {
    var options = Options(contentType: 'application/x-www-form-urlencoded');
    var response = await _dio.post(url, data: body, options: options);
    if (response.statusMessage == "OK") {
      return response.data;
    }
  }

  dynamic postDataFromWebApiWithToken(
      String url, String body, String token) async {
    var options = Options(
        headers: {"Authorization": "Bearer $token"},
        contentType: 'application/x-www-form-urlencoded');
    var response = await _dio.post(url, data: body, options: options);
    if (response.statusMessage == "OK") {
      return response.data;
    }
  }

  dynamic getBodyFromUrl(String url, {Options options}) async {
    var response = await _dio.get(url, options: options);
    if (response.statusMessage == "OK") {
      return response.data;
    }
  }

  void downloadFile(
      {String url,
      String filePath,
      String fileName,
      Function onComplete}) async {
    final path = await FileUtil.getInstance().getSavePath(filePath);
    String name = fileName ?? url.split("/").last;
    _dio.download(
      url,
      path + name,
      onReceiveProgress: (int count, int total) {
        final downloadProgress = ((count / total) * 100).toInt();
        if (downloadProgress == 100) {
          if (onComplete != null) onComplete(path + name);
        }
      },
      options: Options(sendTimeout: 15 * 1000, receiveTimeout: 360 * 1000),
    );
  }

  WebApi._internal(this.baseUrl) {
    _dio = Dio();
    if (this.baseUrl != null && this.baseUrl.trim() != '') {
      _dio.options.baseUrl = this.baseUrl;
    }
    _dio.options.connectTimeout = this.connectTimeout;
    _dio.options.receiveTimeout = this.receiveTimeout;
  }

  static WebApi _getInstance(String baseUrl) {
    if (_instance == null) {
      _instance = new WebApi._internal(baseUrl);
    }
    return _instance;
  }
}
