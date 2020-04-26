// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keyword.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Keyword _$KeywordFromJson(Map<String, dynamic> json) {
  return Keyword(
    index: json['index'] as int,
    keyId: json['ElementId'] as int,
    title: json['ElementName'] as String,
    refCount: json['RefCount'] as int,
    favoriteCount: json['FavoriteCount'] as int,
    entityCount: json['EntityCount'] as int,
    operName: json['OperName'] as String,
    reportId: json['ReportId'] as int,
    isProperty: json['IsProperty'] as bool,
    enabled: json['Enabled'] as bool,
    deleted: json['Deleted'] as bool,
    imageUrl: json['ImageUrl'] as String,
  )..pressed = json['pressed'] as bool;
}

Map<String, dynamic> _$KeywordToJson(Keyword instance) => <String, dynamic>{
      'index': instance.index,
      'ElementId': instance.keyId,
      'ElementName': instance.title,
      'RefCount': instance.refCount,
      'FavoriteCount': instance.favoriteCount,
      'EntityCount': instance.entityCount,
      'OperName': instance.operName,
      'ReportId': instance.reportId,
      'IsProperty': instance.isProperty,
      'Enabled': instance.enabled,
      'Deleted': instance.deleted,
      'ImageUrl': instance.imageUrl,
      'pressed': instance.pressed,
    };
