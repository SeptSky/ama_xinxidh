// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EntityModel _$EntityModelFromJson(Map<String, dynamic> json) {
  return EntityModel(
    json['DataValue'] as int,
    json['DataName'] as String,
    json['Description'] as String,
    json['SubMetaInfo'] as String,
  );
}

Map<String, dynamic> _$EntityModelToJson(EntityModel instance) =>
    <String, dynamic>{
      'DataValue': instance.id,
      'DataName': instance.title,
      'Description': instance.subtitle,
      'SubMetaInfo': instance.subMetaInfo,
    };
