// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pub_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PubMessage _$PubMessageFromJson(Map<String, dynamic> json) {
  return PubMessage(
    msgId: json['MsgId'] as int,
    msgTitle: json['MsgTitle'] as String,
    msgContent: json['MsgContent'] as String,
    openUrl: json['OpenUrl'] as String,
    imageUrl: json['ImageUrl'] as String,
    pubTime: json['PubTime'] == null
        ? null
        : DateTime.parse(json['PubTime'] as String),
    startTime: json['StartTime'] == null
        ? null
        : DateTime.parse(json['StartTime'] as String),
    endTime: json['EndTime'] == null
        ? null
        : DateTime.parse(json['EndTime'] as String),
    enabled: json['Enabled'] as bool,
  );
}

Map<String, dynamic> _$PubMessageToJson(PubMessage instance) =>
    <String, dynamic>{
      'MsgId': instance.msgId,
      'MsgTitle': instance.msgTitle,
      'MsgContent': instance.msgContent,
      'OpenUrl': instance.openUrl,
      'ImageUrl': instance.imageUrl,
      'PubTime': instance.pubTime?.toIso8601String(),
      'StartTime': instance.startTime?.toIso8601String(),
      'EndTime': instance.endTime?.toIso8601String(),
      'Enabled': instance.enabled,
    };
