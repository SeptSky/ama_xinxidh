import 'dart:convert' as convert;
import 'dart:convert';

import 'package:sprintf/sprintf.dart';

import '../../../common/data_io/web_api.dart';
import '../../../common/utilities/data_format.dart';
import '../../../common/utilities/tools.dart';
import '../../../global_store/global_store.dart';
import '../../../models/configs/config.dart';
import '../../../models/configs/topic_def.dart';
import '../../../models/entities/entity_model.dart';
import '../../../models/entities/entity_type.dart';
import '../../../models/entities/info_entity.dart';
import '../../../models/keywords/keyword.dart';
import '../../../models/keywords/relation_type.dart';
import '../../../models/messages/pub_message.dart';
import '../../../models/users/user_info.dart';
import '../app_def.dart';

class InfoNavServices {
  /// 通过WebApi执行用户登录验证
  static Future<UserInfo> login(String userName, String password) async {
    final webApi = WebApi(baseUrl: "$InfoIndex_BaseUrl");
    final md5Str = Tools.generateMd5(password);
    final loginData = {
      "grant_type": "password",
      "username": "$userName",
      "password": "$md5Str",
    };
    try {
      final resData = await webApi.postDataFromWebApi("/token", loginData);
      final userInfo = UserInfo.fromJson(resData);
      return userInfo;
    } catch (err) {
      return null;
    }
  }

  /// 通过WebApi创建用户账号
  static Future<String> createAccount(
      String userName, String password, String mobileNum) async {
    final md5Str = Tools.generateMd5(password);
    final argObj = {
      "ArgJsonText": "string=$userName;string=$md5Str;string=$mobileNum;",
      "ServiceGuid": "$UserLogin_Guid",
      "MethodName": "$CreateAccount_Method",
    };
    final result = await _invokeInfoIndexApi(argObj, true);
    return result;
  }

  /// 通过WebApi获取信息导航APP配置参数
  static Future<AppConfig> getInfoIndexConfigFromWebApi(String appGuid) async {
    final webApi = WebApi(baseUrl: "$InfoIndex_BaseUrl");
    final configApiUrl = sprintf(GetAppConfig_ApiPath, [appGuid]);
    final resData = await webApi.getDataFromWebApi(configApiUrl);
    final config = AppConfig.fromJson(resData);
    return config;
  }

  /// 通过WebApi获取信息导航APP专题检索定义
  static Future<TopicDef> getAppTopicFromWebApi(
      String appGuid, int topicId, bool cacheFlag) async {
    final argObj = {
      "ArgJsonText": "string=$appGuid;int=$topicId;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetAppTopicDef_Method",
    };
    final jsonData = await _invokeInfoIndexApi(argObj, true);
    final topicDef = TopicDef.fromJson(jsonData);
    return topicDef;
  }

  /// 通过WebApi获取信息导航APP专题检索定义
  static Future<TopicDef> getAppTopicFromWebApiByName(
      String appGuid, String topicName, bool cacheFlag) async {
    final argObj = {
      "ArgJsonText": "string=$appGuid;string=$topicName;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetAppTopicByAppGuidAndName_Method",
    };
    final jsonData = await _invokeInfoIndexApi(argObj, true);
    final topicDef = TopicDef.fromJson(jsonData);
    return topicDef;
  }

  /// 读取导航关键词列表
  static Future<List<Keyword>> getInfoNavKeywords(
      String parentName,
      String relationType,
      String jumpToKeyword,
      bool returnSearchStr,
      int pageNo,
      int pageSize,
      bool cacheFlag) async {
    final newParentName = DataFormat.formatArgument(parentName);
    final newRelationType = relationType + "关系";
    final searchStr = '';
    final argObj = {
      "ArgJsonText":
          "string=$newParentName;string=$newRelationType;string=$searchStr;string=$jumpToKeyword;bool=$returnSearchStr;int=$pageNo;int=$pageSize;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetRelatedElementList_Method",
    };
    final jsonItems = await _invokeInfoIndexApi(argObj, cacheFlag);
    final keywords =
        jsonItems.map<Keyword>((item) => Keyword.fromJson(item)).toList();
    return _initializeKeywords(keywords, pageNo, pageSize);
  }

  static Future<List<Keyword>> getRelatedKeywords(
      String parentName,
      String relationType,
      String searchStr,
      int pageNo,
      int pageSize,
      bool cacheFlag,
      int colCountPerRow) async {
    final newParentName = DataFormat.formatArgument(parentName);
    final newRelationType = relationType + "关系";
    final jumpToKeyword = '';
    final returnSearchStr = false;
    final argObj = {
      "ArgJsonText":
          "string=$newParentName;string=$newRelationType;string=$searchStr;string=$jumpToKeyword;bool=$returnSearchStr;int=$pageNo;int=$pageSize;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetRelatedElementList_Method",
    };
    final jsonItems = await _invokeInfoIndexApi(argObj, cacheFlag);
    final keywords =
        jsonItems.map<Keyword>((item) => Keyword.fromJson(item)).toList();
    return _initializeKeywords(keywords, pageNo, pageSize);
  }

  static Future<List<Keyword>> getRelatedKeywordsByUserName(
      String userName,
      String parentName,
      String relationType,
      int pageNo,
      int pageSize,
      bool cacheFlag,
      int colCountPerRow) async {
    final newParentName = DataFormat.formatArgument(parentName);
    final newRelationType = relationType + "关系";
    final argObj = {
      "ArgJsonText":
          "string=$userName;string=$newParentName;string=$newRelationType;int=$pageNo;int=$pageSize;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetRelatedElementListByUserName_Method",
    };
    final jsonItems = await _invokeInfoIndexApi(argObj, cacheFlag);
    final keywords =
        jsonItems.map<Keyword>((item) => Keyword.fromJson(item)).toList();
    return _initializeKeywords(keywords, pageNo, pageSize);
  }

  static Future<List<Keyword>> getFilteredKeywords(
      String parentName,
      String relationType,
      String filterName,
      bool isProperty,
      int pageNo,
      int pageSize,
      bool cacheFlag,
      int colCountPerRow,
      bool topicFirst) async {
    final newParentName = DataFormat.formatArgument(parentName);
    final newRelationType = relationType + "关系";
    final methodName = topicFirst
        ? GetFilteredElementListTopic_Method
        : GetFilteredElementList_Method;
    final argObj = {
      "ArgJsonText":
          "string=$newParentName;string=$newRelationType;string=$filterName;bool=$isProperty;int=$pageNo;int=$pageSize;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$methodName",
    };
    final jsonItems = await _invokeInfoIndexApi(argObj, cacheFlag);
    final keywords =
        jsonItems.map<Keyword>((item) => Keyword.fromJson(item)).toList();
    return _initializeKeywords(keywords, pageNo, pageSize);
  }

  static Future<List<RelationType>> getRelationTypes(String keywordName,
      String searchStr, bool allFlag, bool cacheFlag) async {
    final newKeywordName = DataFormat.formatArgument(keywordName);
    final argObj = {
      "ArgJsonText": "string=$newKeywordName;string=$searchStr;bool=$allFlag;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetRelationTypeList_Method",
    };
    final jsonItems = await _invokeInfoIndexApi(argObj, cacheFlag);
    return jsonItems
        .map<RelationType>((item) => RelationType.fromJson(item))
        .toList();
  }

  static Future<List<RelationType>> getFilteredRelationTypes(
      String keywordName,
      String relationType,
      String filterName,
      bool isProperty,
      bool cacheFlag) async {
    final newKeywordName = DataFormat.formatArgument(keywordName);
    final newRelationType = relationType + "关系";
    final argObj = {
      "ArgJsonText":
          "string=$newKeywordName;string=$newRelationType;string=$filterName;bool=$isProperty;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetFilteredRelationTypeList_Method",
    };
    final jsonItems = await _invokeInfoIndexApi(argObj, cacheFlag);
    return jsonItems
        .map<RelationType>((item) => RelationType.fromJson(item))
        .toList();
  }

  static Future<List<Keyword>> getKeywordProperties(
      String keywordName,
      String relationType,
      int pageNo,
      int pageSize,
      bool cacheFlag,
      bool topicFirst,
      {int propertyMode}) async {
    final newKeywordName = DataFormat.formatArgument(keywordName);
    final newRelationType = relationType + "关系";
    final methodName = topicFirst
        ? GetKeywordPropertyListTopic_Method
        : GetKeywordPropertyList_Method;
    final argObj = {
      "ArgJsonText":
          "string=$newKeywordName;string=$newRelationType;int=$pageNo;int=$pageSize;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$methodName",
    };
    final jsonItems = await _invokeInfoIndexApi(argObj, cacheFlag);
    final keywords =
        jsonItems.map<Keyword>((item) => Keyword.fromJson(item)).toList();
    return _initializeKeywords(keywords, pageNo, pageSize,
        propertyMode: propertyMode);
  }

  static Future<List<Keyword>> getKeywordPropertiesFavorite(String userName,
      String filterKeywords, int pageNo, int pageSize, bool cacheFlag) async {
    final argObj = {
      "ArgJsonText":
          "string=$userName;string=$filterKeywords;int=$pageNo;int=$pageSize;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetKeywordPropertyListFavorite_Method",
    };
    final jsonItems = await _invokeInfoIndexApi(argObj, cacheFlag);
    final keywords =
        jsonItems.map<Keyword>((item) => Keyword.fromJson(item)).toList();
    return _initializeKeywords(keywords, pageNo, pageSize);
  }

  static Future<List<Keyword>> getKeywordPropertiesHistory(String userName,
      String filterKeywords, int pageNo, int pageSize, bool cacheFlag) async {
    final argObj = {
      "ArgJsonText":
          "string=$userName;string=$filterKeywords;int=$pageNo;int=$pageSize;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetKeywordPropertyListHistory_Method",
    };
    final jsonItems = await _invokeInfoIndexApi(argObj, cacheFlag);
    final keywords =
        jsonItems.map<Keyword>((item) => Keyword.fromJson(item)).toList();
    return _initializeKeywords(keywords, pageNo, pageSize);
  }

  static Future<List<Keyword>> getDeletedKeywords(
      int pageNo, int pageSize, bool cacheFlag) async {
    final argObj = {
      "ArgJsonText": "int=$pageNo;int=$pageSize;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetDeletedElementList_Method",
    };
    final jsonItems = await _invokeInfoIndexApi(argObj, cacheFlag);
    final keywords =
        jsonItems.map<Keyword>((item) => Keyword.fromJson(item)).toList();
    return _initializeKeywords(keywords, pageNo, pageSize);
  }

  static Future<List<Keyword>> getDeletedKeywordsByUserName(
      String userName, int pageNo, int pageSize, bool cacheFlag) async {
    final argObj = {
      "ArgJsonText": "string=$userName;int=$pageNo;int=$pageSize;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetDeletedElementListByUserName_Method",
    };
    final jsonItems = await _invokeInfoIndexApi(argObj, cacheFlag);
    final keywords =
        jsonItems.map<Keyword>((item) => Keyword.fromJson(item)).toList();
    return _initializeKeywords(keywords, pageNo, pageSize);
  }

  static Future<List<Keyword>> getUnreviewedKeywords(
      int pageNo, int pageSize, bool cacheFlag) async {
    final argObj = {
      "ArgJsonText": "int=$pageNo;int=$pageSize;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetUnreviewedElementList_Method",
    };
    final jsonItems = await _invokeInfoIndexApi(argObj, cacheFlag);
    return jsonItems.map<Keyword>((item) => Keyword.fromJson(item)).toList();
  }

  static Future<List<Keyword>> getUnreviewedKeywordsByUserName(
      String userName, int pageNo, int pageSize, bool cacheFlag) async {
    final argObj = {
      "ArgJsonText": "string=$userName;int=$pageNo;int=$pageSize;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetUnreviewedElementListByUserName_Method",
    };
    final jsonItems = await _invokeInfoIndexApi(argObj, cacheFlag);
    final keywords =
        jsonItems.map<Keyword>((item) => Keyword.fromJson(item)).toList();
    return _initializeKeywords(keywords, pageNo, pageSize);
  }

  static Future<List<Keyword>> getUnreviewedReportKeywords(
      int pageNo, int pageSize, bool cacheFlag) async {
    final argObj = {
      "ArgJsonText": "int=$pageNo;int=$pageSize;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetUnreviewedReportKeywordList_Method",
    };
    final jsonItems = await _invokeInfoIndexApi(argObj, cacheFlag);
    final keywords =
        jsonItems.map<Keyword>((item) => Keyword.fromJson(item)).toList();
    return _initializeKeywords(keywords, pageNo, pageSize);
  }

  static Future<List<Keyword>> getReportKeywordsByUserName(
      String userName, int pageNo, int pageSize, bool cacheFlag) async {
    final argObj = {
      "ArgJsonText": "string=$userName;int=$pageNo;int=$pageSize;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetReportKeywordListByUserName_Method",
    };
    final jsonItems = await _invokeInfoIndexApi(argObj, cacheFlag);
    final keywords =
        jsonItems.map<Keyword>((item) => Keyword.fromJson(item)).toList();
    return _initializeKeywords(keywords, pageNo, pageSize);
  }

  static Future<List<Keyword>> getRegisterKeywordsByUserName(
      String userName, int pageNo, int pageSize, bool cacheFlag) async {
    final argObj = {
      "ArgJsonText": "string=$userName;int=$pageNo;int=$pageSize;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetRegisterElementsByUserName_Method",
    };
    final jsonItems = await _invokeInfoIndexApi(argObj, cacheFlag);
    final keywords =
        jsonItems.map<Keyword>((item) => Keyword.fromJson(item)).toList();
    return _initializeKeywords(keywords, pageNo, pageSize);
  }

  static Future<List<Keyword>> getFavoriteKeywordsByUserName(String userName,
      int pageNo, int pageSize, bool cacheFlag, int colCountPerRow) async {
    final argObj = {
      "ArgJsonText": "string=$userName;int=$pageNo;int=$pageSize;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetFavoriteElementsByUserName_Method",
    };
    final jsonItems = await _invokeInfoIndexApi(argObj, cacheFlag);
    final keywords =
        jsonItems.map<Keyword>((item) => Keyword.fromJson(item)).toList();
    return _initializeKeywords(keywords, pageNo, pageSize);
  }

  static Future<List<Keyword>> getInvestKeywordsByUserName(
      String userName, int pageNo, int pageSize, bool cacheFlag) async {
    final argObj = {
      "ArgJsonText": "string=$userName;int=$pageNo;int=$pageSize;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetInvestKeywordsByUserName_Method",
    };
    final jsonItems = await _invokeInfoIndexApi(argObj, cacheFlag);
    final keywords =
        jsonItems.map<Keyword>((item) => Keyword.fromJson(item)).toList();
    return _initializeKeywords(keywords, pageNo, pageSize);
  }

  static Future<List<Keyword>> getHotRankKeywords(String userName, int pageNo,
      int pageSize, int hotRankMode, bool cacheFlag, int colCountPerRow) async {
    final argObj = {
      "ArgJsonText":
          "string=$userName;int=$pageNo;int=$pageSize;int=$hotRankMode;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetHotRankKeywords_Method",
    };
    final jsonItems = await _invokeInfoIndexApi(argObj, cacheFlag);
    final keywords =
        jsonItems.map<Keyword>((item) => Keyword.fromJson(item)).toList();
    return _initializeKeywords(keywords, pageNo, pageSize);
  }

  static Future<List<Keyword>> getSeminarKeywords(
      int pageNo, int pageSize, bool cacheFlag) async {
    final argObj = {
      "ArgJsonText": "int=$pageNo;int=$pageSize;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetSeminarKeywords_Method",
    };
    final jsonItems = await _invokeInfoIndexApi(argObj, cacheFlag);
    final keywords =
        jsonItems.map<Keyword>((item) => Keyword.fromJson(item)).toList();
    return _initializeKeywords(keywords, pageNo, pageSize);
  }

  /// 读取指定筛选关键词包含的所有子关键词列表
  static Future<List<Keyword>> getFilterSubKeywords(
      String keywordName, bool cacheFlag) async {
    final argObj = {
      "ArgJsonText": "string=$keywordName;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetFilterSubKeywords_Method",
    };
    final jsonItems = await _invokeInfoIndexApi(argObj, cacheFlag);
    final keywords =
        jsonItems.map<Keyword>((item) => Keyword.fromJson(item)).toList();
    return _initializeKeywords(keywords, 0, keywords.length);
  }

  /// 读取指定筛选关键词关联的信息列表
  static Future<List<InfoEntity>> getInfoEntities(
      String bgKeyword,
      String keywordName,
      String searchStr,
      String relationType,
      String entityType,
      int pageNo,
      int pageSize,
      bool cacheFlag,
      bool topicFirst) async {
    final newKeywordName = DataFormat.formatArgument(keywordName);
    final newRelationType = relationType + "关系";
    final methodName =
        topicFirst ? GetInfoEntityListTopic_Method : GetInfoEntityList_Method;
    final argObj = {
      "ArgJsonText":
          "string=$bgKeyword;string=$newKeywordName;string=$searchStr;string=$newRelationType;string=$entityType;int=$pageNo;int=$pageSize;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$methodName",
    };
    final jsonItems = await _invokeInfoIndexApi(argObj, cacheFlag);
    final infoEntities =
        jsonItems.map<InfoEntity>((item) => InfoEntity.fromJson(item)).toList();
    return _initializeInfoEntities(infoEntities, pageNo, pageSize);
  }

  static Future<List<InfoEntity>> getFilteredInfoEntities(
      String bgKeyword,
      String keywordName,
      String relationType,
      String filteredKeywords,
      String entityType,
      bool isParentFilter,
      int pageNo,
      int pageSize,
      bool cacheFlag,
      bool topicFirst) async {
    final newKeywordName = DataFormat.formatArgument(keywordName);
    final newRelationType = relationType + "关系";
    final methodName = topicFirst
        ? GetFilteredInfoEntityListTopic_Method
        : GetFilteredInfoEntityList_Method;
    final argObj = {
      "ArgJsonText":
          "string=$bgKeyword;string=$newKeywordName;string=$newRelationType;string=$filteredKeywords;string=$entityType;bool=$isParentFilter;int=$pageNo;int=$pageSize;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$methodName",
    };
    final jsonItems = await _invokeInfoIndexApi(argObj, cacheFlag);
    final infoEntities =
        jsonItems.map<InfoEntity>((item) => InfoEntity.fromJson(item)).toList();
    return _initializeInfoEntities(infoEntities, pageNo, pageSize);
  }

  static Future<List<InfoEntity>> getInfoEntitiesByUserName(
      String userName,
      String keywordName,
      String relationType,
      String entityType,
      int pageNo,
      int pageSize,
      bool cacheFlag) async {
    final newKeywordName = DataFormat.formatArgument(keywordName);
    final newRelationType = relationType + "关系";
    final argObj = {
      "ArgJsonText":
          "string=$userName;string=$newKeywordName;string=$newRelationType;string=$entityType;int=$pageNo;int=$pageSize;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetInfoEntityListByUserName_Method",
    };
    final jsonItems = await _invokeInfoIndexApi(argObj, cacheFlag);
    final infoEntities =
        jsonItems.map<InfoEntity>((item) => InfoEntity.fromJson(item)).toList();
    return _initializeInfoEntities(infoEntities, pageNo, pageSize);
  }

  static Future<List<InfoEntity>> getInfoEntityViewHistoryList(
      String userName, int pageNo, int pageSize, bool cacheFlag) async {
    final argObj = {
      "ArgJsonText": "string=$userName;int=$pageNo;int=$pageSize;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetInfoEntityViewHistoryList_Method",
    };
    final jsonItems = await _invokeInfoIndexApi(argObj, cacheFlag);
    final infoEntities =
        jsonItems.map<InfoEntity>((item) => InfoEntity.fromJson(item)).toList();
    return _initializeInfoEntities(infoEntities, pageNo, pageSize);
  }

  static Future<List<InfoEntity>> getFilteredInfoEntityViewHistoryList(
      String userName,
      String filterKeywords,
      int pageNo,
      int pageSize,
      bool cacheFlag) async {
    final argObj = {
      "ArgJsonText":
          "string=$userName;string=$filterKeywords;int=$pageNo;int=$pageSize;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetFilteredInfoEntityViewHistoryList_Method",
    };
    final jsonItems = await _invokeInfoIndexApi(argObj, cacheFlag);
    final infoEntities =
        jsonItems.map<InfoEntity>((item) => InfoEntity.fromJson(item)).toList();
    return _initializeInfoEntities(infoEntities, pageNo, pageSize);
  }

  static Future<List<InfoEntity>> getDeletedInfoEntities(
      int pageNo, int pageSize, bool cacheFlag) async {
    final argObj = {
      "ArgJsonText": "int=$pageNo;int=$pageSize;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetDeletedInfoEntityList_Method",
    };
    final jsonItems = await _invokeInfoIndexApi(argObj, cacheFlag);
    final infoEntities =
        jsonItems.map<InfoEntity>((item) => InfoEntity.fromJson(item)).toList();
    return _initializeInfoEntities(infoEntities, pageNo, pageSize);
  }

  static Future<List<InfoEntity>> getDeletedInfoEntitiesByUserName(
      String userName, int pageNo, int pageSize, bool cacheFlag) async {
    final argObj = {
      "ArgJsonText": "string=$userName;int=$pageNo;int=$pageSize;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetDeletedInfoEntityListByUserName_Method",
    };
    final jsonItems = await _invokeInfoIndexApi(argObj, cacheFlag);
    final infoEntities =
        jsonItems.map<InfoEntity>((item) => InfoEntity.fromJson(item)).toList();
    return _initializeInfoEntities(infoEntities, pageNo, pageSize);
  }

  static Future<List<InfoEntity>> getUnreviewedInfoEntities(
      int pageNo, int pageSize, bool cacheFlag) async {
    final argObj = {
      "ArgJsonText": "int=$pageNo;int=$pageSize;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetUnreviewedInfoEntityList_Method",
    };
    final jsonItems = await _invokeInfoIndexApi(argObj, cacheFlag);
    final infoEntities =
        jsonItems.map<InfoEntity>((item) => InfoEntity.fromJson(item)).toList();
    return _initializeInfoEntities(infoEntities, pageNo, pageSize);
  }

  static Future<List<InfoEntity>> getUnreviewedInfoEntitiesByUserName(
      String userName, int pageNo, int pageSize, bool cacheFlag) async {
    final argObj = {
      "ArgJsonText": "string=$userName;int=$pageNo;int=$pageSize;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetUnreviewedInfoEntityListByUserName_Method",
    };
    final jsonItems = await _invokeInfoIndexApi(argObj, cacheFlag);
    final infoEntities =
        jsonItems.map<InfoEntity>((item) => InfoEntity.fromJson(item)).toList();
    return _initializeInfoEntities(infoEntities, pageNo, pageSize);
  }

  static Future<List<InfoEntity>> getUnreviewedReportInfoEntities(
      int pageNo, int pageSize, bool cacheFlag) async {
    final argObj = {
      "ArgJsonText": "int=$pageNo;int=$pageSize;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetUnreviewedReportInfoEntityList_Method",
    };
    final jsonItems = await _invokeInfoIndexApi(argObj, cacheFlag);
    final infoEntities =
        jsonItems.map<InfoEntity>((item) => InfoEntity.fromJson(item)).toList();
    return _initializeInfoEntities(infoEntities, pageNo, pageSize);
  }

  static Future<List<InfoEntity>> getReportInfoEntitiesByUserName(
      String userName, int pageNo, int pageSize, bool cacheFlag) async {
    final argObj = {
      "ArgJsonText": "string=$userName;int=$pageNo;int=$pageSize;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetReportInfoEntityListByUserName_Method",
    };
    final jsonItems = await _invokeInfoIndexApi(argObj, cacheFlag);
    final infoEntities =
        jsonItems.map<InfoEntity>((item) => InfoEntity.fromJson(item)).toList();
    return _initializeInfoEntities(infoEntities, pageNo, pageSize);
  }

  static Future<List<InfoEntity>> getRegisterInfoEntitiesByUserName(
      int keywordId,
      String userName,
      int pageNo,
      int pageSize,
      bool cacheFlag) async {
    final argObj = {
      "ArgJsonText":
          "int=$keywordId;string=$userName;int=$pageNo;int=$pageSize;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetRegisterInfoEntitiesByUserName_Method",
    };
    final jsonItems = await _invokeInfoIndexApi(argObj, cacheFlag);
    final infoEntities =
        jsonItems.map<InfoEntity>((item) => InfoEntity.fromJson(item)).toList();
    return _initializeInfoEntities(infoEntities, pageNo, pageSize);
  }

  static Future<List<InfoEntity>> getFavoriteInfoEntitiesByUserName(
      int keywordId,
      String userName,
      int pageNo,
      int pageSize,
      bool cacheFlag) async {
    final argObj = {
      "ArgJsonText":
          "int=$keywordId;string=$userName;int=$pageNo;int=$pageSize;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetFavoriteInfoEntitiesByUserName_Method",
    };
    final jsonItems = await _invokeInfoIndexApi(argObj, cacheFlag);
    final infoEntities =
        jsonItems.map<InfoEntity>((item) => InfoEntity.fromJson(item)).toList();
    return _initializeInfoEntities(infoEntities, pageNo, pageSize);
  }

  static Future<List<InfoEntity>> getFilteredFavoriteInfoEntitiesByUserName(
      String userName,
      String filterKeywords,
      int pageNo,
      int pageSize,
      bool cacheFlag) async {
    final argObj = {
      "ArgJsonText":
          "string=$userName;string=$filterKeywords;int=$pageNo;int=$pageSize;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetFilteredFavoriteInfoEntitiesByUserName_Method",
    };
    final jsonItems = await _invokeInfoIndexApi(argObj, cacheFlag);
    final infoEntities =
        jsonItems.map<InfoEntity>((item) => InfoEntity.fromJson(item)).toList();
    return _initializeInfoEntities(infoEntities, pageNo, pageSize);
  }

  static Future<List<InfoEntity>> getHotRankInfoEntities(String userName,
      int keywordId, int pageNo, int pageSize, bool cacheFlag) async {
    final argObj = {
      "ArgJsonText":
          "string=$userName;int=$keywordId;int=$pageNo;int=$pageSize;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetHotRankInfoEntities_Method",
    };
    final jsonItems = await _invokeInfoIndexApi(argObj, cacheFlag);
    final infoEntities =
        jsonItems.map<InfoEntity>((item) => InfoEntity.fromJson(item)).toList();
    return _initializeInfoEntities(infoEntities, pageNo, pageSize);
  }

  static Future<EntityModel> getInfoEntityDataModel(
      int entityId, bool cacheFlag) async {
    final argObj = {
      "ArgJsonText": "int=$entityId;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetInfoEntity_DataModel_Method",
    };
    final jsonData = await _invokeInfoIndexApi(argObj, cacheFlag);
    final entityModel = EntityModel.fromJson(jsonData);
    return entityModel;
  }

  static Future<String> getInfoEntityText(int entityId, bool cacheFlag) async {
    final argObj = {
      "ArgJsonText": "int=$entityId;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetInfoEntity_Text_Method",
    };
    return await _invokeInfoIndexApi(argObj, cacheFlag);
  }

  static Future<List<EntityType>> getEntityTypes(
      String bgKeyword,
      String keywordName,
      String searchStr,
      String relationType,
      bool allFlag,
      bool cacheFlag) async {
    final newKeywordName = DataFormat.formatArgument(keywordName);
    final newRelationType = relationType + "关系";
    final argObj = {
      "ArgJsonText":
          "string=$bgKeyword;string=$newKeywordName;string=$searchStr;string=$newRelationType;bool=$allFlag;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetEntityTypeList_Method",
    };
    final jsonItems = await _invokeInfoIndexApi(argObj, cacheFlag);
    return jsonItems
        .map<EntityType>((item) => EntityType.fromJson(item))
        .toList();
  }

  static Future<List<EntityType>> getFilteredEntityTypes(
      String bgKeyword,
      String keywordName,
      String relationType,
      String filteredKeywords,
      bool isParentFilter,
      bool allFlag,
      bool cacheFlag) async {
    final newKeywordName = DataFormat.formatArgument(keywordName);
    final newRelationType = relationType + "关系";
    final argObj = {
      "ArgJsonText":
          "string=$bgKeyword;string=$newKeywordName;string=$newRelationType;string=$filteredKeywords;bool=$isParentFilter;bool=$allFlag;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetFilteredEntityTypeList_Method",
    };
    final jsonItems = await _invokeInfoIndexApi(argObj, cacheFlag);
    return jsonItems
        .map<EntityType>((item) => EntityType.fromJson(item))
        .toList();
  }

  static Future<List<InfoEntity>> getSearchingMatchedKeywords(
      String topicKeyword,
      String searchStr,
      int pageNo,
      int pageSize,
      bool cacheFlag) async {
    final argObj = {
      "ArgJsonText":
          "string=$topicKeyword;string=$searchStr;int=$pageNo;int=$pageSize;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetSearchingMatchedKeywords_Method",
    };
    final jsonItems = await _invokeInfoIndexApi(argObj, cacheFlag);
    return jsonItems
        .map<InfoEntity>((item) => InfoEntity.fromJson(item))
        .toList();
  }

  static Future<List<InfoEntity>> getSearchingMatchedKeywordsFavorite(
      String userName,
      String searchStr,
      int pageNo,
      int pageSize,
      bool cacheFlag) async {
    final argObj = {
      "ArgJsonText":
          "string=$userName;string=$searchStr;int=$pageNo;int=$pageSize;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetSearchingMatchedKeywordsFavorite_Method",
    };
    final jsonItems = await _invokeInfoIndexApi(argObj, cacheFlag);
    return jsonItems
        .map<InfoEntity>((item) => InfoEntity.fromJson(item))
        .toList();
  }

  static Future<List<InfoEntity>> getSearchingMatchedKeywordsHistory(
      String userName,
      String searchStr,
      int pageNo,
      int pageSize,
      bool cacheFlag) async {
    final argObj = {
      "ArgJsonText":
          "string=$userName;string=$searchStr;int=$pageNo;int=$pageSize;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetSearchingMatchedKeywordsHistory_Method",
    };
    final jsonItems = await _invokeInfoIndexApi(argObj, cacheFlag);
    return jsonItems
        .map<InfoEntity>((item) => InfoEntity.fromJson(item))
        .toList();
  }

  static Future<String> addInfoEntityTags(
      String userName, int entityId, String tagNames) async {
    tagNames = DataFormat.formatArgument(tagNames);
    final argObj = {
      "ArgJsonText": "string=$userName;int=$entityId;string=$tagNames;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$AddInfoEntityTags_Method",
    };
    return await _invokeInfoIndexApi(argObj, false);
  }

  static Future<String> delInfoEntityTag(
      String userName, int entityId, String tagName) async {
    tagName = DataFormat.formatArgument(tagName);
    final argObj = {
      "ArgJsonText": "string=$userName;int=$entityId;string=$tagName;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$DeleteInfoEntityTagByName_Method",
    };
    return await _invokeInfoIndexApi(argObj, false);
  }

  static Future<String> saveKeywordInfo(int keywordId, String newKeywordName,
      int relationId, String relatedKeywordIds) async {
    newKeywordName = DataFormat.formatArgument(newKeywordName);
    relatedKeywordIds = DataFormat.formatArgument(relatedKeywordIds);
    final argObj = {
      "ArgJsonText":
          "int=$keywordId;string=$newKeywordName;int=$relationId;string=$relatedKeywordIds;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$SaveKeywordRelationInfo_Method",
    };
    return await _invokeInfoIndexApi(argObj, false);
  }

  static Future saveUserConnectionInfo(bool isFirstRun) async {
    final argObj = {
      "ArgJsonText": "bool=$isFirstRun;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$SaveUserConnectionInfo_Method",
    };
    return await _invokeInfoIndexApi(argObj, false);
  }

  static Future<String> incFilterRankValue(
      String topicKeyword, String filterName, int incRankCount) async {
    topicKeyword = DataFormat.formatArgument(topicKeyword);
    filterName = DataFormat.formatArgument(filterName);
    final argObj = {
      "ArgJsonText":
          "string=$topicKeyword;string=$filterName;int=$incRankCount;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$IncFilterRankValue_Method",
    };
    return await _invokeInfoIndexApi(argObj, false);
  }

  static Future<String> incInfoEntityViewCount(
      String userName, int infoEntityId) async {
    final argObj = {
      "ArgJsonText": "string=$userName;int=$infoEntityId;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$IncInfoEntityViewCount_Method",
    };
    return await _invokeInfoIndexApi(argObj, false);
  }

  static Future<String> favoriteInfoEntity(
      String userName, int infoEntityId) async {
    final argObj = {
      "ArgJsonText": "string=$userName;int=$infoEntityId;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$FavoriteInfoEntity_Method",
    };
    return await _invokeInfoIndexApi(argObj, false);
  }

  static Future<String> refAddInfoEntityTopic(
      String userName,
      int orgEntityId,
      String entityTitle,
      String entityOverview,
      String entityContent,
      String entityTags) async {
    entityTitle = DataFormat.formatArgument(entityTitle);
    entityOverview = DataFormat.formatArgument(entityOverview);
    entityContent = DataFormat.formatArgument(entityContent);
    entityTags = DataFormat.formatArgument(entityTags);
    final argObj = {
      "ArgJsonText":
          "string=$userName;int=$orgEntityId;string=$entityTitle;string=$entityOverview;string=$entityContent;string=$entityTags;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$RefAddInfoEntityTopic_Method",
    };
    return await _invokeInfoIndexApi(argObj, false);
  }

  static Future<String> saveInfoEntityTopic(
      String userName,
      int entityId,
      String entityTitle,
      String entityOverview,
      String entityContent,
      String entityTags) async {
    entityTitle = DataFormat.formatArgument(entityTitle);
    entityOverview = DataFormat.formatArgument(entityOverview);
    entityContent = DataFormat.formatArgument(entityContent);
    entityTags = DataFormat.formatArgument(entityTags);
    final argObj = {
      "ArgJsonText":
          "string=$userName;int=$entityId;string=$entityTitle;string=$entityOverview;string=$entityContent;string=$entityTags;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$SaveInfoEntityTopic_Method",
    };
    return await _invokeInfoIndexApi(argObj, false);
  }

  static Future<String> deleteInfoEntityTopic(
      String userName, int entityId) async {
    final argObj = {
      "ArgJsonText": "string=$userName;int=$entityId;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$DeleteInfoEntityTopic_Method",
    };
    return await _invokeInfoIndexApi(argObj, false);
  }

  static Future<PubMessage> getLatestPubMessage() async {
    final argObj = {
      "ArgJsonText": "",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetLatestPubMessage_Method",
    };
    final jsonData = await _invokeInfoIndexApi(argObj, true);
    final pubMessage = PubMessage.fromJson(jsonData);
    return pubMessage;
  }

  static Future<int> getEntityPageNoInTopic(
      String topicKeyword, int entityId, int pageSize) async {
    final argObj = {
      "ArgJsonText": "string=$topicKeyword;int=$entityId;int=$pageSize;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetEntityPageNoInTopic_Method",
    };
    final pageNo = await _invokeInfoIndexApi(argObj, true);
    return int.tryParse(pageNo) ?? 0;
  }

  static Future<String> getTopicTagsPyCodes(String topicKeyword) async {
    final argObj = {
      "ArgJsonText": "string=$topicKeyword;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetTopicTagsPyCodes_Method",
    };
    return await _invokeInfoIndexApi(argObj, true);
  }

  static Future<String> getFavoriteTagsPyCodes(String userName) async {
    final argObj = {
      "ArgJsonText": "string=$userName;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetFavoriteTagsPyCodes_Method",
    };
    return await _invokeInfoIndexApi(argObj, true);
  }

  static Future<String> getHistoryTagsPyCodes(String userName) async {
    final argObj = {
      "ArgJsonText": "string=$userName;",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$GetHistoryTagsPyCodes_Method",
    };
    return await _invokeInfoIndexApi(argObj, true);
  }

  static Future clearDataCache() async {
    final argObj = {
      "ArgJsonText": "",
      "ServiceGuid": "$InfoNavigation_Service",
      "MethodName": "$ClearCache_Method",
      "ClearCache": true
    };
    return await _invokeInfoIndexApi(argObj, false);
  }

  /// 从信息导航WebApi服务中读取数据
  /// cacheFlag=false时，直接访问数据库操作，可以是查询，也可以是修改
  static dynamic _invokeInfoIndexApi(Object argObj, bool cacheFlag) async {
    final webApi = WebApi(baseUrl: "$InfoIndex_BaseUrl");
    final argStr = convert.jsonEncode(argObj);
    final token = GlobalStore.userInfo?.accessToken;
    String postApiUrl;
    if (cacheFlag) {
      postApiUrl = sprintf(DyncInvoke_Post_ApiPath, [InfoIndex_BaseUrl]);
    } else {
      postApiUrl = sprintf(DyncInvokeDb_Post_ApiPath, [InfoIndex_BaseUrl]);
    }
    final body = "=" + argStr;
    dynamic resData =
        await webApi.postDataFromWebApiWithToken(postApiUrl, body, token);
    final jsonText = resData["JsonText"];
    if (jsonText == null) return null;
    if (jsonText[0] != '{' && jsonText[0] != '[') return jsonText;
    return json.decode(jsonText);
  }

  static List<Keyword> _initializeKeywords(
      List<Keyword> keywords, int pageNo, int pageSize,
      {int propertyMode}) {
    if (keywords != null) {
      for (var i = 0; i < keywords.length; i++) {
        keywords[i].index = pageNo * pageSize + i;
        keywords[i].pressed = false;
        if (propertyMode != null) {
          keywords[i].isProperty = propertyMode == 0 ? false : true;
        }
      }
    }
    return keywords;
  }

  static List<InfoEntity> _initializeInfoEntities(
      List<InfoEntity> infoEntities, int pageNo, int pageSize) {
    if (infoEntities != null) {
      for (var i = 0; i < infoEntities.length; i++) {
        infoEntities[i].id = pageNo * pageSize + i;
        infoEntities[i].pressed = false;
      }
    }
    return infoEntities;
  }
}
