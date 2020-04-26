// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic_def.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TopicDef _$TopicDefFromJson(Map<String, dynamic> json) {
  return TopicDef(
    topicId: json['TopicId'] as int,
    topicName: json['TopicName'] as String,
    bgKeyword: json['BgKeyword'] as String,
    topicKeyword: json['TopicKeyword'] as String,
    indexKeyword: json['IndexKeyword'] as String,
    navPageName: json['NavPageName'] as String,
    sortId: json['SortId'] as int,
    topicFirst: json['TopicFirst'] as bool,
    hasRelated: json['HasRelated'] as bool,
    searchDepth: json['SearchDepth'] as int,
    extraPage: json['ExtraPage'] as int,
    propertyMode: json['PropertyMode'] as int,
    helpUrl: json['HelpUrl'] as String,
  );
}

Map<String, dynamic> _$TopicDefToJson(TopicDef instance) => <String, dynamic>{
      'TopicId': instance.topicId,
      'TopicName': instance.topicName,
      'BgKeyword': instance.bgKeyword,
      'TopicKeyword': instance.topicKeyword,
      'IndexKeyword': instance.indexKeyword,
      'NavPageName': instance.navPageName,
      'SortId': instance.sortId,
      'TopicFirst': instance.topicFirst,
      'HasRelated': instance.hasRelated,
      'SearchDepth': instance.searchDepth,
      'ExtraPage': instance.extraPage,
      'PropertyMode': instance.propertyMode,
      'HelpUrl': instance.helpUrl,
    };
