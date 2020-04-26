import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart';

import '../../common/consts/component_names.dart';
import '../../common/consts/enum_types.dart';
import '../../global_store/global_state.dart';
import '../../models/configs/config.dart';
import '../../models/entities/info_entity.dart';
import '../../models/themes/theme_bean.dart';
import '../../models/users/user_info.dart';
import 'entity_item_component/entity_state.dart';

class InfoNavPageState extends MutableSource
    implements GlobalBaseState, Cloneable<InfoNavPageState> {
  ScrollController scrollController = ScrollController();
  TextEditingController textController = TextEditingController();
  bool isLoading = false;
  bool hasMoreEntities = true;
  int nextPageNo = 0;
  String filterKeywords;
  bool jumpFlag = false;
  bool jumpComplete = false;
  bool isKeywordNav = false;
  bool autoSearch = true;
  List<InfoEntity> infoEntities;

  @override
  bool hasError;

  @override
  bool isLoadingWebData;

  @override
  ThemeBean currentTheme;

  @override
  UserInfo userInfo;

  @override
  AppConfig appConfig;

  @override
  bool searchMode;

  @override
  SourceType sourceType;

  @override
  ContentType contentType;

  @override
  InfoNavPageState clone() {
    return InfoNavPageState()
      ..scrollController = scrollController
      ..textController = textController
      ..isLoading = isLoading
      ..hasMoreEntities = hasMoreEntities
      ..nextPageNo = nextPageNo
      ..autoSearch = autoSearch
      ..infoEntities = infoEntities
      ..filterKeywords = filterKeywords
      ..jumpFlag = jumpFlag
      ..jumpComplete = jumpComplete
      ..isKeywordNav = isKeywordNav
      ..filterKeywords = filterKeywords
      ..currentTheme = currentTheme
      ..userInfo = userInfo
      ..appConfig = appConfig
      ..searchMode = searchMode
      ..sourceType = sourceType
      ..contentType = contentType;
  }

  @override
  Object getItemData(int index) {
    var infoEntity = infoEntities[index];
    return EntityState()
      ..keyId = infoEntity.keyId
      ..index = infoEntity.id
      ..title = infoEntity.title
      ..subtitle = infoEntity.subtitle
      ..overview = _processOverview(infoEntity.infoDisplayer,
          infoEntity.overview, filterKeywords, infoEntity.pressed)
      ..infoDisplayer = infoEntity.infoDisplayer
      ..entityTags = infoEntity.entityTags
      ..pressed = infoEntity.pressed ?? false
      ..performedTag = infoEntity.tag
      ..displayMode = infoEntity.displayMode
      ..imageUrl = infoEntity.imageUrl
      ..selectable = unjumpable
      ..isKeywordNav = isKeywordNav
      ..favorite = infoEntity.deleted
      ..filterKeywords = filterKeywords
      ..userInfo = userInfo
      ..appConfig = appConfig
      ..currentTheme = currentTheme;
  }

  /// 使用唯一的标识符注册InfoEntityItem组件
  @override
  String getItemType(int index) => ComponentNames.infoEntityComponent;

  @override
  int get itemCount => infoEntities?.length ?? 0;

  /// 修改ItemState属性，首先修改ItemList对应的元素，然后在getItemData中提取
  @override
  void setItemData(int index, Object data) {
    EntityState entityState = data;
    infoEntities[index].pressed = entityState.pressed;
    infoEntities[index].deleted = entityState.favorite;
    infoEntities[index].tag = entityState.performedTag;
    infoEntities[index].displayMode = entityState.displayMode;
    infoEntities[index].entityTags = entityState.entityTags;
  }

  bool get unjumpable =>
      filterKeywords == null || filterKeywords != null && jumpFlag;

  InfoEntity getInfoEntityById(int entityId,
      {List<InfoEntity> exInfoEntities}) {
    final infoEntityList = exInfoEntities ?? infoEntities;
    final infoEntity = infoEntityList
        .firstWhere((entity) => entity.keyId == entityId, orElse: () => null);
    if (infoEntity == null) return null;
    return infoEntity;
  }

  int getPressedEntityId() {
    final infoEntity =
        infoEntities.firstWhere((entity) => entity.pressed, orElse: () => null);
    if (infoEntity == null) return null;
    return infoEntity.keyId;
  }

  bool hasFilters() {
    return filterKeywords != null && filterKeywords.length > 0;
  }

  bool hasParagraph() {
    if (infoEntities == null) return false;
    final index = infoEntities.indexWhere(
        (entity) => entity.infoDisplayer == EntityType.paragraphType);
    return index >= 0;
  }

  bool hasEntityKeyword() {
    if (infoEntities == null) return false;
    final index = infoEntities
        .indexWhere((entity) => entity.infoDisplayer == EntityType.keywordType);
    return index >= 0;
  }

  String _processOverview(String infoDisplayer, String oldOverview,
      String filteredKeyword, bool pressed) {
    if (oldOverview == null || oldOverview == '') return null;
    if (pressed &&
        (infoDisplayer == EntityType.paragraphType ||
            infoDisplayer == EntityType.paragraphUrlType)) {
      if (oldOverview[0] == '#') {
        return oldOverview.replaceFirst('# ', '# *') + '*';
      }
      return '*$oldOverview*';
    }
    if (filteredKeyword == null ||
        filteredKeyword == '' ||
        infoDisplayer != EntityType.paragraphType &&
            infoDisplayer != EntityType.paragraphUrlType) {
      return oldOverview;
    }
    var filters = filteredKeyword.split(',');
    oldOverview = oldOverview.replaceAll('**', '@@');
    var newOverview = oldOverview;
    filters.forEach((filter) {
      if (filter[0] == '【') {
        var newFilter = filter.replaceFirst('【', '');
        newFilter = newFilter.replaceFirst('】', '').trim();
        newOverview = newOverview.replaceAll(filter, '【*$newFilter*】');
      } else {
        newOverview = newOverview.replaceAll(filter, '*$filter*');
      }
    });
    newOverview = newOverview.replaceAll('**', '');
    newOverview = newOverview.replaceAll('@@', '**');
    return newOverview;
  }
}

InfoNavPageState initState(Map<String, dynamic> args) {
  final pageState = InfoNavPageState();
  return pageState;
}
