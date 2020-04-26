import 'package:amainfoindex/common/data_access/app_def.dart';
import 'package:amainfoindex/common/data_access/webApi/info_nav_services.dart';
import 'package:amainfoindex/models/configs/config.dart';
import 'package:amainfoindex/models/configs/topic_def.dart';
import 'package:amainfoindex/models/entities/entity_type.dart';
import 'package:amainfoindex/models/entities/info_entity.dart';
import 'package:amainfoindex/models/keywords/keyword.dart';
import 'package:amainfoindex/models/keywords/relation_type.dart';
import 'package:amainfoindex/models/messages/pub_message.dart';
import 'package:amainfoindex/models/users/user_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('信息导航查询服务测试', () {
    test('读取APP配置信息测试', () async {
      AppConfig config =
          await InfoNavServices.getInfoIndexConfigFromWebApi(Xinxidh_App_Guid);
      expect(config.appName, '专题资源检索');
    });
    test('读取APP专题检索定义列表', () async {
      TopicDef topic = await InfoNavServices.getAppTopicFromWebApi(
          Xinxidh_App_Guid, -1, true);
      expect(topic != null, true);
    });
    test('用户登录测试', () async {
      UserInfo userInfo = await InfoNavServices.login('ama', 'hwq710517');
      expect(userInfo.roleId, "1");
    });
    test('读取特征关键词所包含的子关键词测试', () async {
      List<Keyword> keywordsCache =
          await InfoNavServices.getFilterSubKeywords("国内期货", true);
      expect(keywordsCache.length > 0, true);
      List<Keyword> keywordsDb =
          await InfoNavServices.getFilterSubKeywords("国内期货", false);
      expect(keywordsDb.length > 0, true);
    });
    test('读取导航关键词列表测试', () async {
      List<Keyword> infoNavCatalogs = await InfoNavServices.getInfoNavKeywords(
          "生活", "包含", "", true, 0, 10, true);
      expect(infoNavCatalogs.length > 0, true);
    });
    test('读取关联关键词列表测试', () async {
      List<Keyword> relatedKeywords = await InfoNavServices.getRelatedKeywords(
          "养生_", "包含", "王", 0, 10, true, 1);
      expect(relatedKeywords.length > 0, true);
    });
    test('读取指定用户的关联关键词列表测试', () async {
      List<Keyword> relatedKeywords =
          await InfoNavServices.getRelatedKeywordsByUserName(
              "ama", "生活", "包含", 0, 10, false, 1);
      expect(relatedKeywords.length > 0, true);
    });
    test('读取关键词筛选结果列表测试', () async {
      List<Keyword> filteredKeywords =
          await InfoNavServices.getFilteredKeywords(
              "养生_", "包含", "养生,王", true, 0, 10, false, 1, true);
      expect(filteredKeywords.length > 0, true);
    });
    test('读取删除的关键词列表测试', () async {
      List<Keyword> deletedKeywords =
          await InfoNavServices.getDeletedKeywords(0, 10, false);
      expect(deletedKeywords.length == 0, true);
    });
    test('读取指定用户删除的关键词列表测试', () async {
      List<Keyword> deletedKeywords =
          await InfoNavServices.getDeletedKeywordsByUserName(
              "ama", 0, 10, false);
      expect(deletedKeywords.length == 0, true);
    });
    test('读取指定用户删除的关键词列表测试', () async {
      List<Keyword> deletedKeywords =
          await InfoNavServices.getDeletedKeywordsByUserName(
              "ama", 0, 10, false);
      expect(deletedKeywords.length == 0, true);
    });
    test('读取未审核的关键词列表测试', () async {
      List<Keyword> unreviewedKeywords =
          await InfoNavServices.getUnreviewedKeywords(0, 10, false);
      expect(unreviewedKeywords.length == 0, true);
    });
    test('读取指定用户未审核的关键词列表测试', () async {
      List<Keyword> unreviewedKeywords =
          await InfoNavServices.getUnreviewedKeywordsByUserName(
              "ama", 0, 10, false);
      expect(unreviewedKeywords.length == 0, true);
    });
    test('读取未审核的举报关键词列表测试', () async {
      List<Keyword> unreviewedReportKeywords =
          await InfoNavServices.getUnreviewedReportKeywords(0, 10, false);
      expect(unreviewedReportKeywords.length == 0, true);
    });
    test('读取指定用户的举报关键词列表测试', () async {
      List<Keyword> reportKeywords =
          await InfoNavServices.getReportKeywordsByUserName(
              "ama", 0, 10, false);
      expect(reportKeywords.length == 1, true);
    });
    test('读取指定用户的注册关键词列表测试', () async {
      List<Keyword> registerKeywords =
          await InfoNavServices.getRegisterKeywordsByUserName(
              "ama", 0, 10, false);
      expect(registerKeywords.length > 0, true);
    });
    test('读取指定用户的收藏关键词列表测试', () async {
      List<Keyword> favoriteKeywords =
          await InfoNavServices.getFavoriteKeywordsByUserName(
              "ama", 0, 10, false, 1);
      expect(favoriteKeywords.length > 0, true);
    });
    test('读取指定用户的投资关键词列表测试', () async {
      List<Keyword> investKeywords =
          await InfoNavServices.getInvestKeywordsByUserName(
              "ama", 0, 10, false);
      expect(investKeywords.length > 0, true);
    });
    test('读取热榜关键词列表测试', () async {
      List<Keyword> hotKeywords =
          await InfoNavServices.getHotRankKeywords("ama", 0, 10, 0, false, 1);
      expect(hotKeywords.length > 0, true);
    });
    test('读取检索关键词列表测试', () async {
      List<Keyword> seminarKeywords =
          await InfoNavServices.getSeminarKeywords(0, 10, false);
      expect(seminarKeywords.length > 0, true);
    });
    test('读取关键词关系汇总信息测试', () async {
      List<RelationType> relationTypes =
          await InfoNavServices.getRelationTypes("生活", "", true, false);
      expect(relationTypes.length > 0, true);
    });
    test('读取关键词筛选关系汇总信息测试', () async {
      List<RelationType> relationTypes =
          await InfoNavServices.getFilteredRelationTypes(
              "养生_", "包含", "养生,王", true, false);
      expect(relationTypes.length > 0, true);
    });
    test('读取关键词筛选特征词列表测试', () async {
      List<Keyword> properties = await InfoNavServices.getKeywordProperties(
          "养生_", "包含", 0, 10, true, true);
      expect(properties.length > 0, true);
    });
    test('读取我的收藏信息标签列表测试', () async {
      List<Keyword> properties =
          await InfoNavServices.getKeywordPropertiesFavorite(
              "ama", "", 0, 10, true);
      expect(properties.length > 0, true);
    });
    test('读取历史浏览信息标签列表测试', () async {
      List<Keyword> properties =
          await InfoNavServices.getKeywordPropertiesHistory(
              "ama", "", 0, 10, true);
      expect(properties.length > 0, true);
    });
    test('读取指定关键词所关联的信息列表测试', () async {
      List<InfoEntity> entitiesCache = await InfoNavServices.getInfoEntities(
          "网站图谱导航", "生活", "", "包含", "全部", 0, 10, true, true);
      expect(entitiesCache.length > 0, true);
      List<InfoEntity> entitiesDb = await InfoNavServices.getInfoEntities(
          "网站图谱导航", "生活", "", "包含", "全部", 0, 10, false, true);
      expect(entitiesDb.length > 0, true);
    });
    test('读取指定关键词所关联的筛选信息列表测试', () async {
      List<InfoEntity> entities = await InfoNavServices.getFilteredInfoEntities(
          "网站图谱导航",
          "养生,冬_",
          "包含",
          "秋,七旬营养师的养生经-秋冬篇(3)",
          "全部",
          false,
          0,
          10,
          false,
          true);
      expect(entities.length > 0, true);
    });
    test('读取指定用户的关键词关联信息列表测试', () async {
      List<InfoEntity> entities =
          await InfoNavServices.getInfoEntitiesByUserName(
              "ama", "生活", "包含", "全部", 0, 10, false);
      expect(entities.length > 0, true);
    });
    test('读取最新历史信息列表测试', () async {
      List<InfoEntity> entities =
          await InfoNavServices.getInfoEntityViewHistoryList(
              "ama", 0, 10, false);
      expect(entities.length > 0, true);
    });
    test('读取删除信息列表测试', () async {
      List<InfoEntity> entities =
          await InfoNavServices.getDeletedInfoEntities(0, 10, false);
      expect(entities.length == 0, true);
    });
    test('读取指定用户的删除信息列表测试', () async {
      List<InfoEntity> entities =
          await InfoNavServices.getDeletedInfoEntitiesByUserName(
              "ama", 0, 10, false);
      expect(entities.length == 0, true);
    });
    test('读取未审核的信息列表测试', () async {
      List<InfoEntity> entities =
          await InfoNavServices.getUnreviewedInfoEntities(0, 10, false);
      expect(entities.length == 0, true);
    });
    test('读取指定用户未审核的信息列表测试', () async {
      List<InfoEntity> entities =
          await InfoNavServices.getUnreviewedInfoEntitiesByUserName(
              "ama", 0, 10, false);
      expect(entities.length == 0, true);
    });
    test('读取未审核的举报信息列表测试', () async {
      List<InfoEntity> entities =
          await InfoNavServices.getUnreviewedReportInfoEntities(0, 10, false);
      expect(entities.length == 0, true);
    });
    test('读取指定用户的举报信息列表测试', () async {
      List<InfoEntity> entities =
          await InfoNavServices.getReportInfoEntitiesByUserName(
              "ama", 0, 10, false);
      expect(entities.length == 0, true);
    });
    test('读取指定用户和关键词的注册信息列表测试', () async {
      List<InfoEntity> entities =
          await InfoNavServices.getRegisterInfoEntitiesByUserName(
              63374, "ama", 0, 10, false);
      expect(entities.length > 0, true);
    });
    test('读取指定用户和关键词的收藏信息列表测试', () async {
      List<InfoEntity> entities =
          await InfoNavServices.getFavoriteInfoEntitiesByUserName(
              17874, "ama", 0, 10, false);
      expect(entities.length > 0, true);
    });
    test('读取热榜信息列表测试', () async {
      List<InfoEntity> entities = await InfoNavServices.getHotRankInfoEntities(
          "ama", 17874, 0, 10, false);
      expect(entities.length > 0, true);
    });
    test('读取匹配搜索字符串的特征词列表测试', () async {
      List<InfoEntity> entities =
          await InfoNavServices.getSearchingMatchedKeywords(
              "专题定义", 'l', 0, 10, false);
      expect(entities.length > 0, true);
    });
    // test('读取指定Id的信息模型测试', () async {
    //   // 后台解析有问题，待处理
    //   EntityModel entityModel =
    //       await InfoNavServices.getInfoEntityDataModel(84, false);
    //   expect(entityModel != null, true);
    // });
    test('读取指定Id的信息文本测试', () async {
      String entityText = await InfoNavServices.getInfoEntityText(84, false);
      expect(entityText.length > 0, true);
    });
    test('读取指定关键词所关联的信息类型汇总信息测试', () async {
      List<EntityType> entityTypes = await InfoNavServices.getEntityTypes(
          "网站图谱导航", "残局讲解", "", "操作", true, true);
      expect(entityTypes.length > 0, true);
    });
    test('读取指定关键词所关联的筛选信息类型汇总信息测试', () async {
      List<EntityType> entityTypes =
          await InfoNavServices.getFilteredEntityTypes(
              "网站图谱导航", "养生_", "包含", "冬,春夏养阳秋冬养阴", false, true, true);
      expect(entityTypes.length > 0, true);
    });
    test('获取最新发布消息测试', () async {
      PubMessage pubMessage = await InfoNavServices.getLatestPubMessage();
      expect(pubMessage != null, true);
    });
    test('获取指定信息在专题内的页号测试', () async {
      int pageNo = await InfoNavServices.getEntityPageNoInTopic(
          '新冠疫情皮肤科防护诊疗规范', 142615, 15);
      expect(pageNo == 2, true);
    });
    test('读取指定专题标签首字母测试', () async {
      String pyCodes = await InfoNavServices.getTopicTagsPyCodes('专题定义');
      expect(pyCodes.length > 0, true);
    });
  });
  group('信息导航非查询服务测试', () {
    test('保存是否首次登录信息', () async {
      await InfoNavServices.saveUserConnectionInfo(true);
      expect(true, true);
    });
    test('增加特征词排名值', () async {
      final result =
          await InfoNavServices.incFilterRankValue('新冠患者行程', '北京', 0);
      expect(result == 'ok', true);
    });
    test('清除后台缓存数据', () async {
      await InfoNavServices.clearDataCache();
      expect(true, true);
    });
  });
}
