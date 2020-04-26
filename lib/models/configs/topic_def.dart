import 'package:json_annotation/json_annotation.dart';

part 'topic_def.g.dart';

@JsonSerializable()
class TopicDef {
  TopicDef(
      {this.topicId,
      this.topicName,
      this.bgKeyword,
      this.topicKeyword,
      this.indexKeyword,
      this.navPageName,
      this.sortId,
      this.topicFirst,
      this.hasRelated,
      this.searchDepth,
      this.extraPage,
      this.propertyMode,
      this.helpUrl});

  @JsonKey(name: "TopicId")
  int topicId;
  @JsonKey(name: "TopicName")
  String topicName;
  @JsonKey(name: "BgKeyword")
  String bgKeyword;
  @JsonKey(name: "TopicKeyword")
  String topicKeyword;
  @JsonKey(name: "IndexKeyword")
  String indexKeyword;
  @JsonKey(name: "NavPageName")
  String navPageName;
  @JsonKey(name: "SortId")
  int sortId;
  @JsonKey(name: "TopicFirst")
  bool topicFirst;
  @JsonKey(name: "HasRelated")
  bool hasRelated;
  @JsonKey(name: "SearchDepth")
  int searchDepth;
  @JsonKey(name: "ExtraPage")
  int extraPage;
  @JsonKey(name: "PropertyMode")
  int propertyMode;
  @JsonKey(name: "HelpUrl")
  String helpUrl;

  factory TopicDef.fromJson(Map<String, dynamic> json) =>
      _$TopicDefFromJson(json);

  Map<String, dynamic> toJson() => _$TopicDefToJson(this);
}
