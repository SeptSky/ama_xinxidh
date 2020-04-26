import 'package:json_annotation/json_annotation.dart';

part 'relation_type.g.dart';

@JsonSerializable()
class RelationType {
  RelationType(
      this.id,
      this.title,
      this.count,
      this.typeSymbol);

  @JsonKey(name: "TypeId")
  int id;
  @JsonKey(name: "TypeName")
  String title;
  @JsonKey(name: "RelationCount")
  int count;
  @JsonKey(name: "TypeSymbol")
  String typeSymbol;

  factory RelationType.fromJson(Map<String, dynamic> json) =>
      _$RelationTypeFromJson(json);

  Map<String, dynamic> toJson() => _$RelationTypeToJson(this);
}
