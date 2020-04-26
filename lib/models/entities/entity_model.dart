import 'package:json_annotation/json_annotation.dart';

part 'entity_model.g.dart';

@JsonSerializable()
class EntityModel {
  EntityModel(
      this.id,
      this.title,
      this.subtitle,
      this.subMetaInfo);

  @JsonKey(name: "DataValue")
  int id;
  @JsonKey(name: "DataName")
  String title;
  @JsonKey(name: "Description")
  String subtitle;
  @JsonKey(name: "SubMetaInfo")
  String subMetaInfo;

  factory EntityModel.fromJson(Map<String, dynamic> json) =>
      _$EntityModelFromJson(json);

  Map<String, dynamic> toJson() => _$EntityModelToJson(this);
}
