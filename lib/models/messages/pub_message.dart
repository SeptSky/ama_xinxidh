import 'package:json_annotation/json_annotation.dart';

part 'pub_message.g.dart';

@JsonSerializable()
class PubMessage {
  PubMessage({this.msgId, this.msgTitle, this.msgContent, this.openUrl, this.imageUrl,  this.pubTime, 
  this.startTime, this.endTime, this.enabled});

  @JsonKey(name: "MsgId")
  int msgId;
  @JsonKey(name: "MsgTitle")
  String msgTitle;
  @JsonKey(name: "MsgContent")
  String msgContent;
  @JsonKey(name: "OpenUrl")
  String openUrl;
  @JsonKey(name: "ImageUrl")
  String imageUrl;
  @JsonKey(name: "PubTime")
  DateTime pubTime;
  @JsonKey(name: "StartTime")
  DateTime startTime;
  @JsonKey(name: "EndTime")
  DateTime endTime;
  @JsonKey(name: "Enabled")
  bool enabled;

  factory PubMessage.fromJson(Map<String, dynamic> json) => _$PubMessageFromJson(json);

  Map<String, dynamic> toJson() => _$PubMessageToJson(this);
}
