import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import '../../common/consts/keys.dart';
import '../../common/data_access/app_def.dart';
import '../../common/data_access/webApi/info_nav_services.dart';
import '../../common/utilities/shared_util.dart';
import 'topic_def.dart';

part 'config.g.dart';

@JsonSerializable()
class AppConfig {
  static AppConfig _instance;

  AppConfig(
      this.appName,
      this.colCount,
      this.maxSearchCount,
      this.infoNavCatalogWidth,
      this.infoNavCatalogHeight,
      this.entitySectionHeight,
      this.otherSectionHeight,
      this.maxChannelPageCount,
      this.maxHotRankPageCount,
      this.latestVersion,
      this.updateDesc,
      this.downloadUrl);

  static Future<AppConfig> getInstance() async {
    if (_instance == null) {
      var jsonString = await SharedUtil.instance.getString(Keys.appConfig);
      if (jsonString != null) {
        _instance = AppConfig.fromJson(jsonDecode(jsonString));
      } else {
        _instance = await InfoNavServices.getInfoIndexConfigFromWebApi(
            Xinxidh_App_Guid);
        if (_instance != null) {
          await SharedUtil.instance
              .saveString(Keys.appConfig, jsonEncode(_instance.toJson()));
        }
      }
    }

    return _instance;
  }

  static AppConfig get instance => _instance;

  @JsonKey(name: "AppName")
  String appName;
  @JsonKey(name: "ColumnCount")
  int colCount;
  @JsonKey(name: "MaxSearchCount")
  int maxSearchCount;
  @JsonKey(name: "InfoNavCatalogWidth")
  int infoNavCatalogWidth;
  @JsonKey(name: "InfoNavCatalogHeight")
  int infoNavCatalogHeight;
  @JsonKey(name: "EntitySectionHeight")
  int entitySectionHeight;
  @JsonKey(name: "OtherSectionHeight")
  int otherSectionHeight;
  @JsonKey(name: "MaxChannelPageCount")
  int maxChannelPageCount;
  @JsonKey(name: "MaxHotRankPageCount")
  int maxHotRankPageCount;
  @JsonKey(name: "LatestVersion")
  String latestVersion;
  @JsonKey(name: "UpdateDesc")
  String updateDesc;
  @JsonKey(name: "DownloadUrl")
  String downloadUrl;

  TopicDef topic;

  factory AppConfig.fromJson(Map<String, dynamic> json) =>
      _$AppConfigFromJson(json);

  Map<String, dynamic> toJson() => _$AppConfigToJson(this);
}
