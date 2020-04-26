import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart';

import '../../common/consts/component_names.dart';
import '../../common/consts/enum_types.dart';
import '../../common/consts/param_names.dart';
import '../../common/utilities/tools.dart';
import '../../global_store/global_state.dart';
import '../../models/configs/config.dart';
import '../../models/keywords/keyword.dart';
import '../../models/themes/theme_bean.dart';
import '../../models/users/user_info.dart';
import '../keyword_nav_page/keyword_item_component/keyword_state.dart';

class KeywordRelatedPageState extends MutableSource
    implements GlobalBaseState, Cloneable<KeywordRelatedPageState> {
  ScrollController scrollController = ScrollController();
  bool isLoading = false;
  bool hasMoreKeywords = true;
  int nextPageNo = 0;
  String filterKeywords;
  List<Keyword> keywords;

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
  KeywordRelatedPageState clone() {
    return KeywordRelatedPageState()
      ..scrollController = scrollController
      ..isLoading = isLoading
      ..nextPageNo = nextPageNo
      ..filterKeywords = filterKeywords
      ..keywords = keywords
      ..currentTheme = currentTheme
      ..userInfo = userInfo
      ..appConfig = appConfig
      ..searchMode = searchMode
      ..sourceType = sourceType
      ..contentType = contentType;
  }

  @override
  Object getItemData(int index) {
    final keyword = keywords[index];
    return KeywordState()
      ..keyId = keyword.keyId
      ..index = keyword.index
      ..title = keyword.title
      ..isProperty = keyword.isProperty
      ..pressed = keyword.pressed
      ..userInfo = userInfo
      ..appConfig = appConfig
      ..currentTheme = currentTheme;
  }

  /// 使用唯一的标识符注册KeywordItem组件
  @override
  String getItemType(int index) => ComponentNames.keywordComponent;

  @override
  int get itemCount => keywords?.length ?? 0;

  @override
  void setItemData(int index, Object data) {
    KeywordState keywordState = data;
    keywords[index].pressed = keywordState.pressed;
  }

  Keyword getPressedKeyword() {
    if (Tools.hasNotElements(keywords)) return null;
    final pressedKeyword =
        keywords.firstWhere((keyword) => keyword.pressed, orElse: () => null);
    return pressedKeyword;
  }

  String getPressedFilterKeywords() {
    final pressedKeyword = getPressedKeyword();
    final pressedFilterKeywords = pressedKeyword != null
        ? '$filterKeywords,${pressedKeyword.title}'
        : '$filterKeywords';
    return pressedFilterKeywords;
  }
}

KeywordRelatedPageState initState(Map<String, dynamic> args) {
  final filterKeywords = args[ParamNames.filterKeywordsParam];
  final pageState = KeywordRelatedPageState()..filterKeywords = filterKeywords;
  return pageState;
}
