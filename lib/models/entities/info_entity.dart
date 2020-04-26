import 'package:fish_redux/fish_redux.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../pages/info_nav_page/entity_item_component/entity_state.dart';

part 'info_entity.g.dart';

@JsonSerializable()
class InfoEntity implements Cloneable<InfoEntity> {
  InfoEntity(
      {this.id,
      this.keyId,
      this.title,
      this.overview,
      this.subtitle,
      this.infoType,
      this.infoDisplayer,
      this.iconFontName,
      this.iconName,
      this.iconSize,
      this.iconColor,
      this.entityTags,
      this.viewCount,
      this.favoriteCount,
      this.rankValue,
      this.operName,
      this.operTime,
      this.reportId,
      this.enabled,
      this.deleted,
      this.imageUrl,
      this.openByBrowser});

  int id;
  @JsonKey(name: "EntityId")
  int keyId;
  @JsonKey(name: "EntityName")
  String title;
  @JsonKey(name: "Overview")
  String overview;
  @JsonKey(name: "EntityContent")
  String subtitle;
  @JsonKey(name: "TypeId")
  int infoType;
  @JsonKey(name: "InfoDisplayer")
  String infoDisplayer;
  @JsonKey(name: "IconFontName")
  String iconFontName;
  @JsonKey(name: "IconName")
  String iconName;
  @JsonKey(name: "IconSize")
  int iconSize;
  @JsonKey(name: "IconColor")
  String iconColor;
  @JsonKey(name: "EntityTags")
  String entityTags;
  @JsonKey(name: "ViewCount")
  int viewCount;
  @JsonKey(name: "FavoriteCount")
  int favoriteCount;
  @JsonKey(name: "RankValue")
  int rankValue;
  @JsonKey(name: "OperName")
  String operName;
  @JsonKey(name: "OperTime")
  String operTime;
  @JsonKey(name: "ReportId")
  int reportId;
  @JsonKey(name: "Enabled")
  bool enabled;
  @JsonKey(name: "Deleted")
  bool deleted;
  @JsonKey(name: "ImageUrl")
  String imageUrl;
  @JsonKey(name: "OpenByBrowser")
  bool openByBrowser;
  bool pressed = false;
  String tag;
  DisplayMode displayMode = DisplayMode.normal;

  @override
  InfoEntity clone() {
    return InfoEntity()
      ..id = id
      ..keyId = keyId
      ..title = title
      ..subtitle = subtitle
      ..infoType = infoType
      ..infoDisplayer = infoDisplayer
      ..iconFontName = iconFontName
      ..iconName = iconName
      ..iconSize = iconSize
      ..iconColor = iconColor
      ..entityTags = entityTags
      ..viewCount = viewCount
      ..favoriteCount = favoriteCount
      ..rankValue = rankValue
      ..operName = operName
      ..operTime = operTime
      ..reportId = reportId
      ..enabled = enabled
      ..deleted = deleted
      ..imageUrl = imageUrl
      ..openByBrowser = openByBrowser
      ..pressed = pressed;
  }

  @override
  String toString() {
    return 'InfoEntity{keyId: $keyId, title: $title, subtitle: $subtitle}';
  }

  factory InfoEntity.fromJson(Map<String, dynamic> json) =>
      _$InfoEntityFromJson(json);

  Map<String, dynamic> toJson() => _$InfoEntityToJson(this);
}
