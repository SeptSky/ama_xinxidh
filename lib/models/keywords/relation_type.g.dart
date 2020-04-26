// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relation_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RelationType _$RelationTypeFromJson(Map<String, dynamic> json) {
  return RelationType(
    json['TypeId'] as int,
    json['TypeName'] as String,
    json['RelationCount'] as int,
    json['TypeSymbol'] as String,
  );
}

Map<String, dynamic> _$RelationTypeToJson(RelationType instance) =>
    <String, dynamic>{
      'TypeId': instance.id,
      'TypeName': instance.title,
      'RelationCount': instance.count,
      'TypeSymbol': instance.typeSymbol,
    };
