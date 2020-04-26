import 'package:json_annotation/json_annotation.dart';

import 'keyword.dart';

part 'keyword_nav_env.g.dart';

@JsonSerializable()
class KeywordNavEnv {
  KeywordNavEnv(this.keywordMode, this.hasMore, this.nextPageNo, this.keywords,
      this.filteredKeywords);

  bool keywordMode;
  bool hasMore;
  int nextPageNo;
  String filteredKeywords;
  List<Keyword> keywords;

  factory KeywordNavEnv.fromJson(Map<String, dynamic> json) =>
      _$KeywordNavEnvFromJson(json);

  Map<String, dynamic> toJson() => _$KeywordNavEnvToJson(this);
}
