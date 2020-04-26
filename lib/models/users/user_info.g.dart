// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserInfo _$UserInfoFromJson(Map<String, dynamic> json) {
  return UserInfo(
    userId: json['userId'] as String,
    userName: json['userName'] as String,
    roleId: json['roleId'] as String,
    score: json['score'] as String,
    roleName: json['roleName'] as String,
    mobileNum: json['mobileNum'] as String,
    realName: json['realName'] as String,
    identityNo: json['identityNo'] as String,
    accessToken: json['access_token'] as String,
    refreshToken: json['refresh_token'] as String,
    expiredTime: json['expiredTime'] as String,
    expiresIn: json['expires_in'] as int,
  );
}

Map<String, dynamic> _$UserInfoToJson(UserInfo instance) => <String, dynamic>{
      'userId': instance.userId,
      'userName': instance.userName,
      'roleId': instance.roleId,
      'score': instance.score,
      'roleName': instance.roleName,
      'mobileNum': instance.mobileNum,
      'realName': instance.realName,
      'identityNo': instance.identityNo,
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'expiredTime': instance.expiredTime,
      'expires_in': instance.expiresIn,
    };
