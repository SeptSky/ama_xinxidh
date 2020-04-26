// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keyword_nav_env.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KeywordNavEnv _$KeywordNavEnvFromJson(Map<String, dynamic> json) {
  return KeywordNavEnv(
    json['keywordMode'] as bool,
    json['hasMore'] as bool,
    json['nextPageNo'] as int,
    (json['keywords'] as List)
        ?.map((e) =>
            e == null ? null : Keyword.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['filteredKeywords'] as String,
  );
}

Map<String, dynamic> _$KeywordNavEnvToJson(KeywordNavEnv instance) =>
    <String, dynamic>{
      'keywordMode': instance.keywordMode,
      'hasMore': instance.hasMore,
      'nextPageNo': instance.nextPageNo,
      'filteredKeywords': instance.filteredKeywords,
      'keywords': instance.keywords,
    };
