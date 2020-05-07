import 'package:fish_redux/fish_redux.dart';

import '../../../common/consts/enum_types.dart';
import '../../../global_store/global_state.dart';
import '../../../models/configs/config.dart';
import '../../../models/themes/theme_bean.dart';
import '../../../models/users/user_info.dart';

class EntityType {
  static const topicDefType = 'Topic';
  static const browserUrlType = 'BrowserUrl';
  static const paragraphType = 'Paragraph';
  static const paragraphUrlType = 'ParagraphUrl';
  static const plainTextType = 'PlainText';
  static const keywordType = 'Keyword';
  static const pageLinkType = 'PageLink';
}

enum DisplayMode { normal, entityEdit, entityAction, tagEdit, tagAction }

class EntityState implements GlobalBaseState, Cloneable<EntityState> {
  int keyId;
  int index;
  String title;
  String subtitle;
  String overview;
  String infoDisplayer;
  String entityTags;
  bool pressed = false;
  String imageUrl;
  bool selectable;
  bool isKeywordNav;
  bool favorite = false;
  String performedTag;
  DisplayMode displayMode = DisplayMode.normal;

  EntityState(
      {this.keyId,
      this.index,
      this.title,
      this.subtitle,
      this.overview,
      this.infoDisplayer,
      this.entityTags,
      this.pressed,
      this.imageUrl});

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
  EntityState clone() {
    return EntityState()
      ..keyId = keyId
      ..index = index
      ..title = title
      ..subtitle = subtitle
      ..overview = overview
      ..infoDisplayer = infoDisplayer
      ..entityTags = entityTags
      ..pressed = pressed
      ..imageUrl = imageUrl
      ..selectable = selectable
      ..isKeywordNav = isKeywordNav
      ..favorite = favorite
      ..filterKeywords = filterKeywords
      ..performedTag = performedTag
      ..displayMode = displayMode
      ..currentTheme = currentTheme
      ..userInfo = userInfo
      ..appConfig = appConfig
      ..searchMode = searchMode
      ..sourceType = sourceType
      ..contentType = contentType;
  }

  bool isInvalidTag(String tag) {
    if (infoDisplayer == EntityType.paragraphType &&
            (tag == '目录' || tag.contains('编号')) ||
        tag == '专题定义') return true;
    return false;
  }
}

EntityState initState(Map<String, dynamic> args) {
  final entityState = EntityState();
  return entityState;
}
