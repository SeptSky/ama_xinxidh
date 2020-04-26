import 'package:json_annotation/json_annotation.dart';

part 'ncov_trip.g.dart';

@JsonSerializable()
class NcovTrip {
  NcovTrip(
      this.tripId,
      this.infoSource,
      this.infoSourceUrl,
      this.tripDate,
      this.tripPosition,
      this.transportation,
      this.departure,
      this.arrival,
      this.carriage,
      this.tipDesc,
      this.startTime,
      this.endTime,
      this.commitTime,
      this.comment);

  @JsonKey(name: "TripId")
  int tripId;
  @JsonKey(name: "InfoSource")
  String infoSource;
  @JsonKey(name: "InfoSourceUrl")
  String infoSourceUrl;
  @JsonKey(name: "TripDate")
  DateTime tripDate;
  @JsonKey(name: "TripPosition")
  String tripPosition;
  @JsonKey(name: "Transportation")
  String transportation;
  @JsonKey(name: "Departure")
  String departure;
  @JsonKey(name: "Arrival")
  String arrival;
  @JsonKey(name: "Carriage")
  String carriage;
  @JsonKey(name: "TripDesc")
  String tipDesc;
  @JsonKey(name: "StartTime")
  DateTime startTime;
  @JsonKey(name: "EndTime")
  DateTime endTime;
  @JsonKey(name: "CommitTime")
  DateTime commitTime;
  @JsonKey(name: "Comment")
  String comment;

  factory NcovTrip.fromJson(Map<String, dynamic> json) =>
      _$NcovTripFromJson(json);

  Map<String, dynamic> toJson() => _$NcovTripToJson(this);
}
