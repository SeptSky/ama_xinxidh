import 'package:fish_redux/fish_redux.dart';
import 'package:json_annotation/json_annotation.dart';

part 'keyword.g.dart';

@JsonSerializable()
class Keyword implements Cloneable<Keyword> {
  Keyword(
      {this.index,
      this.keyId,
      this.title,
      this.refCount,
      this.favoriteCount,
      this.entityCount,
      this.operName,
      this.reportId,
      this.isProperty,
      this.enabled,
      this.deleted,
      this.imageUrl});

  int index;
  @JsonKey(name: "ElementId")
  int keyId;
  @JsonKey(name: "ElementName")
  String title;
  @JsonKey(name: "RefCount")
  int refCount;
  @JsonKey(name: "FavoriteCount")
  int favoriteCount;
  @JsonKey(name: "EntityCount")
  int entityCount;
  @JsonKey(name: "OperName")
  String operName;
  @JsonKey(name: "ReportId")
  int reportId;
  @JsonKey(name: "IsProperty")
  bool isProperty;
  @JsonKey(name: "Enabled")
  bool enabled;
  @JsonKey(name: "Deleted")
  bool deleted;
  @JsonKey(name: "ImageUrl")
  String imageUrl;
  bool pressed = false;

  @override
  Keyword clone() {
    return Keyword()
      ..index = index
      ..keyId = keyId
      ..title = title
      ..refCount = refCount
      ..favoriteCount = favoriteCount
      ..entityCount = entityCount
      ..operName = operName
      ..reportId = reportId
      ..isProperty = isProperty
      ..enabled = enabled
      ..deleted = deleted
      ..imageUrl = imageUrl
      ..pressed = pressed;
  }

  factory Keyword.fromJson(Map<String, dynamic> json) =>
      _$KeywordFromJson(json);

  Map<String, dynamic> toJson() => _$KeywordToJson(this);
}
