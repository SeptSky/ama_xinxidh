// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EntityType _$EntityTypeFromJson(Map<String, dynamic> json) {
  return EntityType(
    json['TypeId'] as int,
    json['TypeName'] as String,
    json['EntityCount'] as int,
  );
}

Map<String, dynamic> _$EntityTypeToJson(EntityType instance) =>
    <String, dynamic>{
      'TypeId': instance.id,
      'TypeName': instance.title,
      'EntityCount': instance.count,
    };
