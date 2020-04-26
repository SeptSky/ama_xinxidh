import 'package:json_annotation/json_annotation.dart';

part 'entity_type.g.dart';

@JsonSerializable()
class EntityType {
  EntityType(
      this.id,
      this.title,
      this.count);

  @JsonKey(name: "TypeId")
  int id;
  @JsonKey(name: "TypeName")
  String title;
  @JsonKey(name: "EntityCount")
  int count;

  factory EntityType.fromJson(Map<String, dynamic> json) =>
      _$EntityTypeFromJson(json);

  Map<String, dynamic> toJson() => _$EntityTypeToJson(this);
}
