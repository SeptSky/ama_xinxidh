// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppConfig _$AppConfigFromJson(Map<String, dynamic> json) {
  return AppConfig(
    json['AppName'] as String,
    json['ColumnCount'] as int,
    json['MaxSearchCount'] as int,
    json['InfoNavCatalogWidth'] as int,
    json['InfoNavCatalogHeight'] as int,
    json['EntitySectionHeight'] as int,
    json['OtherSectionHeight'] as int,
    json['MaxChannelPageCount'] as int,
    json['MaxHotRankPageCount'] as int,
    json['LatestVersion'] as String,
    json['UpdateDesc'] as String,
    json['DownloadUrl'] as String,
  )..topic = json['topic'] == null
      ? null
      : TopicDef.fromJson(json['topic'] as Map<String, dynamic>);
}

Map<String, dynamic> _$AppConfigToJson(AppConfig instance) => <String, dynamic>{
      'AppName': instance.appName,
      'ColumnCount': instance.colCount,
      'MaxSearchCount': instance.maxSearchCount,
      'InfoNavCatalogWidth': instance.infoNavCatalogWidth,
      'InfoNavCatalogHeight': instance.infoNavCatalogHeight,
      'EntitySectionHeight': instance.entitySectionHeight,
      'OtherSectionHeight': instance.otherSectionHeight,
      'MaxChannelPageCount': instance.maxChannelPageCount,
      'MaxHotRankPageCount': instance.maxHotRankPageCount,
      'LatestVersion': instance.latestVersion,
      'UpdateDesc': instance.updateDesc,
      'DownloadUrl': instance.downloadUrl,
      'topic': instance.topic,
    };
