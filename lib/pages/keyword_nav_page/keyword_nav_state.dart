import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart';

import '../../common/consts/component_names.dart';
import '../../common/consts/constants.dart';
import '../../common/consts/enum_types.dart';
import '../../common/utilities/tools.dart';
import '../../global_store/global_state.dart';
import '../../global_store/global_store.dart';
import '../../models/configs/config.dart';
import '../../models/keywords/keyword.dart';
import '../../models/themes/theme_bean.dart';
import '../../models/users/user_info.dart';
import 'keyword_item_component/keyword_state.dart';

class KeywordNavPageState extends MutableSource
    implements GlobalBaseState, Cloneable<KeywordNavPageState> {
  ScrollController scrollController = ScrollController();
  bool keywordMode = true;
  bool isLoading = false;
  bool hasMoreFilters = true;
  int nextPageNo = 0;
  List<Keyword> filters;

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
  KeywordNavPageState clone() {
    return KeywordNavPageState()
      ..scrollController = scrollController
      ..keywordMode = keywordMode
      ..isLoading = isLoading
      ..nextPageNo = nextPageNo
      ..filters = filters
      ..currentTheme = currentTheme
      ..userInfo = userInfo
      ..appConfig = appConfig
      ..searchMode = searchMode
      ..sourceType = sourceType
      ..contentType = contentType;
  }

  @override
  Object getItemData(int index) {
    var filter = filters[index];
    return KeywordState()
      ..keyId = filter.keyId
      ..index = filter.index
      ..title = filter.title
      ..isProperty = filter.isProperty
      ..pressed = filter.pressed
      ..userInfo = userInfo
      ..appConfig = appConfig
      ..currentTheme = currentTheme;
  }

  /// 使用唯一的标识符注册KeywordItem组件
  @override
  String getItemType(int index) => ComponentNames.filterComponent;

  @override
  int get itemCount => filters?.length ?? 0;

  @override
  void setItemData(int index, Object data) {
    KeywordState keywordState = data;
    filters[index].pressed = keywordState.pressed;
  }

  List<Keyword> getPressedPropertyFilterList() {
    if (Tools.hasNotElements(filters)) return null;
    var pressedFilters = filters
        .where((filter) => filter.pressed && filter.isProperty == true)
        .toList();
    if (Tools.hasNotElements(pressedFilters)) return null;
    return pressedFilters;
  }

  List<Keyword> getPressedParentFilterList() {
    if (Tools.hasNotElements(filters)) return null;
    var pressedParents = filters
        .where((filter) => filter.pressed && filter.isProperty == false)
        .toList();
    return pressedParents;
  }

  List<Keyword> getUnpressedParentFilterList() {
    if (Tools.hasNotElements(filters)) return null;
    var pressedParents = filters
        .where((filter) => !filter.pressed && filter.isProperty == false)
        .toList();
    if (Tools.hasNotElements(pressedParents)) return null;
    return pressedParents;
  }

  int getPressedPropertyFilterCount() {
    if (Tools.hasNotElements(filters)) return 0;
    var pressedFilters = filters
        .where((filter) => filter.pressed && filter.isProperty == true)
        .toList();
    if (Tools.hasNotElements(pressedFilters)) return 0;
    return pressedFilters.length;
  }

  int getUnpressedPropertyFilterCount() {
    if (Tools.hasNotElements(filters)) return 0;
    var pressedFilters = filters
        .where((filter) => !filter.pressed && filter.isProperty == true)
        .toList();
    if (Tools.hasNotElements(pressedFilters)) return 0;
    return pressedFilters.length;
  }

  String getPressedPropertyFilterText({int excludeIndex}) {
    if (Tools.hasNotElements(filters)) return null;
    var pressedFilters = filters
        .where((filter) =>
            excludeIndex == null &&
                filter.pressed &&
                filter.isProperty == true ||
            excludeIndex != null &&
                filter.pressed &&
                filter.isProperty == true &&
                filter.index != excludeIndex)
        .toList();
    if (Tools.hasNotElements(pressedFilters)) return null;
    return pressedFilters.map((filter) => filter.title).join(',');
  }

  bool isPropertyFilter(String filterName) {
    if (Tools.hasNotElements(filters)) return null;
    var propertyFilter =
        filters.firstWhere((filter) => filter.pressed, orElse: () => null);
    if (propertyFilter == null) return null;
    return propertyFilter.isProperty;
  }

  int getGridColCount() {
    final condition = getPressedPropertyFilterText();
    final topicFirst = GlobalStore.currentTopicDef.topicFirst;
    final hasRelated = GlobalStore.currentTopicDef.hasRelated;
    return condition == null || topicFirst && !hasRelated
        ? Constants.maxColCount
        : 1;
  }
}

KeywordNavPageState initState(Map<String, dynamic> args) {
  var pageState = KeywordNavPageState();
  return pageState;
}
