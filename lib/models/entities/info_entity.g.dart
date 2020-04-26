// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'info_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InfoEntity _$InfoEntityFromJson(Map<String, dynamic> json) {
  return InfoEntity(
    id: json['id'] as int,
    keyId: json['EntityId'] as int,
    title: json['EntityName'] as String,
    overview: json['Overview'] as String,
    subtitle: json['EntityContent'] as String,
    infoType: json['TypeId'] as int,
    infoDisplayer: json['InfoDisplayer'] as String,
    iconFontName: json['IconFontName'] as String,
    iconName: json['IconName'] as String,
    iconSize: json['IconSize'] as int,
    iconColor: json['IconColor'] as String,
    entityTags: json['EntityTags'] as String,
    viewCount: json['ViewCount'] as int,
    favoriteCount: json['FavoriteCount'] as int,
    rankValue: json['RankValue'] as int,
    operName: json['OperName'] as String,
    operTime: json['OperTime'] as String,
    reportId: json['ReportId'] as int,
    enabled: json['Enabled'] as bool,
    deleted: json['Deleted'] as bool,
    imageUrl: json['ImageUrl'] as String,
    openByBrowser: json['OpenByBrowser'] as bool,
  )
    ..pressed = json['pressed'] as bool
    ..tag = json['tag'] as String
    ..displayMode =
        _$enumDecodeNullable(_$DisplayModeEnumMap, json['displayMode']);
}

Map<String, dynamic> _$InfoEntityToJson(InfoEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'EntityId': instance.keyId,
      'EntityName': instance.title,
      'Overview': instance.overview,
      'EntityContent': instance.subtitle,
      'TypeId': instance.infoType,
      'InfoDisplayer': instance.infoDisplayer,
      'IconFontName': instance.iconFontName,
      'IconName': instance.iconName,
      'IconSize': instance.iconSize,
      'IconColor': instance.iconColor,
      'EntityTags': instance.entityTags,
      'ViewCount': instance.viewCount,
      'FavoriteCount': instance.favoriteCount,
      'RankValue': instance.rankValue,
      'OperName': instance.operName,
      'OperTime': instance.operTime,
      'ReportId': instance.reportId,
      'Enabled': instance.enabled,
      'Deleted': instance.deleted,
      'ImageUrl': instance.imageUrl,
      'OpenByBrowser': instance.openByBrowser,
      'pressed': instance.pressed,
      'tag': instance.tag,
      'displayMode': _$DisplayModeEnumMap[instance.displayMode],
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$DisplayModeEnumMap = {
  DisplayMode.normal: 'normal',
  DisplayMode.entityEdit: 'entityEdit',
  DisplayMode.entityAction: 'entityAction',
  DisplayMode.tagEdit: 'tagEdit',
  DisplayMode.tagAction: 'tagAction',
};
