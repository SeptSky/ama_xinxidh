import 'package:json_annotation/json_annotation.dart';

import '../../common/consts/constants.dart';

part 'user_info.g.dart';

@JsonSerializable()
class UserInfo {
  static UserInfo _instance;

  UserInfo(
      {this.userId,
      this.userName,
      this.roleId,
      this.score,
      this.roleName,
      this.mobileNum,
      this.realName,
      this.identityNo,
      this.accessToken,
      this.refreshToken,
      this.expiredTime,
      this.expiresIn});

  String userId;
  String userName;
  String roleId;
  String score;
  String roleName;
  String mobileNum;
  String realName;
  String identityNo;
  @JsonKey(name: "access_token")
  String accessToken;
  @JsonKey(name: "refresh_token")
  String refreshToken;
  String expiredTime;
  @JsonKey(name: "expires_in")
  int expiresIn;

  static UserInfo getInstance() {
    if (_instance == null) {
      _instance = UserInfo(
        userName: Constants.anonymityUser,
        roleId: Constants.anonymityRoleId,
        roleName: Constants.anonymityRoleName,
        score: Constants.anonymityScore,
      );
    }

    return _instance;
  }

  factory UserInfo.fromJson(Map<String, dynamic> json) =>
      _$UserInfoFromJson(json);

  Map<String, dynamic> toJson() => _$UserInfoToJson(this);
}
