import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action;

import '../../common/consts/enum_types.dart';
import '../../global_store/global_state.dart';
import '../../models/configs/config.dart';
import '../../models/entities/info_entity.dart';
import '../../models/themes/theme_bean.dart';
import '../../models/users/user_info.dart';

class EntityEditState implements GlobalBaseState, Cloneable<EntityEditState> {
  InfoEntity infoEntity;

  TextEditingController nameEditController;
  TextEditingController descEditController;

  FocusNode focusNodeName;
  FocusNode focusNodeDesc;

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
  String filterKeywords;

  @override
  bool searchMode;

  @override
  SourceType sourceType;

  @override
  ContentType contentType;

  @override
  EntityEditState clone() {
    return EntityEditState()
      ..nameEditController = nameEditController
      ..descEditController = descEditController
      ..focusNodeName = focusNodeName
      ..focusNodeDesc = focusNodeDesc
      ..infoEntity = infoEntity
      ..currentTheme = currentTheme
      ..userInfo = userInfo
      ..appConfig = appConfig
      ..filterKeywords = filterKeywords
      ..searchMode = searchMode
      ..sourceType = sourceType
      ..contentType = contentType;
  }
}

EntityEditState initState(InfoEntity arg) {
  final EntityEditState state = EntityEditState();
  state.infoEntity = arg?.clone() ?? InfoEntity();
  state.nameEditController = TextEditingController(text: arg?.title);
  state.descEditController = TextEditingController(text: arg?.subtitle);
  state.focusNodeName = FocusNode();
  state.focusNodeDesc = FocusNode();

  return state;
}
