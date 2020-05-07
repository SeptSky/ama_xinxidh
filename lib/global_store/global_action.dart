import 'package:amainfoindex/common/consts/enum_types.dart';
import 'package:fish_redux/fish_redux.dart';

import '../models/configs/topic_def.dart';
import '../models/themes/theme_bean.dart';
import '../models/users/user_info.dart';

enum GlobalReducerEnum {
  setFilterKeywordsReducer,
  setSearchModeReducer,
  setSourceTypeReducer,
  setContentTypeReducer,
  setErrorStatusReducer,
  setWebLoadingStatusReducer,
  changeCurrentThemeReducer,
  changeTopicDefReducer,
  setUserInfoReducer,
}

class GlobalReducerCreator {
  static Action setFilterKeywordsReducer(String filterKeywords) {
    return Action(GlobalReducerEnum.setFilterKeywordsReducer,
        payload: filterKeywords);
  }

  static Action setSearchModeReducer(bool searchMode) {
    return Action(GlobalReducerEnum.setSearchModeReducer, payload: searchMode);
  }

  static Action setSourceTypeReducer(SourceType sourceType) {
    return Action(GlobalReducerEnum.setSourceTypeReducer, payload: sourceType);
  }

  static Action setContentTypeReducer(ContentType contentType) {
    return Action(GlobalReducerEnum.setContentTypeReducer,
        payload: contentType);
  }

  static Action setErrorStatusReducer(bool hasError) {
    return Action(GlobalReducerEnum.setErrorStatusReducer, payload: hasError);
  }

  static Action setWebLoadingStatusReducer(bool isWebLoading) {
    return Action(GlobalReducerEnum.setWebLoadingStatusReducer,
        payload: isWebLoading);
  }

  static Action changeCurrentThemeReducer(ThemeBean themeBean) {
    return Action(GlobalReducerEnum.changeCurrentThemeReducer,
        payload: themeBean);
  }

  static Action changeTopicDefReducer(TopicDef topicDef) {
    return Action(GlobalReducerEnum.changeTopicDefReducer, payload: topicDef);
  }

  static Action setUserInfoReducer(UserInfo userInfo) {
    return Action(GlobalReducerEnum.setUserInfoReducer, payload: userInfo);
  }
}
