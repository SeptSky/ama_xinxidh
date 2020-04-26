// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ncov_trip.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NcovTrip _$NcovTripFromJson(Map<String, dynamic> json) {
  return NcovTrip(
    json['TripId'] as int,
    json['InfoSource'] as String,
    json['InfoSourceUrl'] as String,
    json['TripDate'] == null
        ? null
        : DateTime.parse(json['TripDate'] as String),
    json['TripPosition'] as String,
    json['Transportation'] as String,
    json['Departure'] as String,
    json['Arrival'] as String,
    json['Carriage'] as String,
    json['TripDesc'] as String,
    json['StartTime'] == null
        ? null
        : DateTime.parse(json['StartTime'] as String),
    json['EndTime'] == null ? null : DateTime.parse(json['EndTime'] as String),
    json['CommitTime'] == null
        ? null
        : DateTime.parse(json['CommitTime'] as String),
    json['Comment'] as String,
  );
}

Map<String, dynamic> _$NcovTripToJson(NcovTrip instance) => <String, dynamic>{
      'TripId': instance.tripId,
      'InfoSource': instance.infoSource,
      'InfoSourceUrl': instance.infoSourceUrl,
      'TripDate': instance.tripDate?.toIso8601String(),
      'TripPosition': instance.tripPosition,
      'Transportation': instance.transportation,
      'Departure': instance.departure,
      'Arrival': instance.arrival,
      'Carriage': instance.carriage,
      'TripDesc': instance.tipDesc,
      'StartTime': instance.startTime?.toIso8601String(),
      'EndTime': instance.endTime?.toIso8601String(),
      'CommitTime': instance.commitTime?.toIso8601String(),
      'Comment': instance.comment,
    };
