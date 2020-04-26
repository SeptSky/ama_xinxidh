import 'package:fish_redux/fish_redux.dart';

import '../../common/consts/constants.dart';
import '../../common/consts/param_names.dart';
import '../../models/entities/info_entity.dart';
import 'info_nav_action.dart';
import 'info_nav_state.dart';

Reducer<InfoNavPageState> buildReducer() {
  /// 建立Reducer名称与Reducer实现之间的映射关系
  return asReducer(
    <Object, Reducer<InfoNavPageState>>{
      // 小心不要使用InfoNavPageReducerCreator作为Key，会导致匹配失败，无法执行Reducer逻辑
      InfoNavPageReducerEnum.initEntitiesReducer: _initEntitiesReducer,
      InfoNavPageReducerEnum.setPrevPageEntitiesReducer:
          _setPrevPageEntitiesReducer,
      InfoNavPageReducerEnum.setNextPageEntitiesReducer:
          _setNextPageEntitiesReducer,
      InfoNavPageReducerEnum.setJumpPageEntitiesReducer:
          _setJumpPageEntitiesReducer,
      InfoNavPageReducerEnum.setIsLoadingFlagReducer: _setIsLoadingFlagReducer,
      InfoNavPageReducerEnum.setFilteredKeywordReducer:
          _setFilteredKeywordReducer,
      InfoNavPageReducerEnum.updateEntityItemReducer: _updateEntityItemReducer,
      InfoNavPageReducerEnum.setJumpCompletedFlagReducer:
          _setJumpCompletedFlagReducer,
      InfoNavPageReducerEnum.setAutoSearchReducer: _setAutoSearchReducer,
      InfoNavPageReducerEnum.setIsKeywordNavReducer: _setIsKeywordNavReducer,
    },
  );
}

InfoNavPageState _initEntitiesReducer(InfoNavPageState state, Action action) {
  final List<InfoEntity> infoEntities = action.payload ?? <InfoEntity>[];
  final newState = state.clone();
  newState.infoEntities = infoEntities;
  if (infoEntities.isNotEmpty) {
    newState.hasMoreEntities = infoEntities.length % Constants.pageSize == 0;
    newState.nextPageNo = 1;
    _resetInfoEntityIndex(newState.infoEntities);
  } else {
    newState.hasMoreEntities = false;
    newState.nextPageNo = 0;
  }
  return newState;
}

InfoNavPageState _setPrevPageEntitiesReducer(
    InfoNavPageState state, Action action) {
  final List<InfoEntity> infoEntities = action.payload ?? <InfoEntity>[];
  // 需要考虑重复读取的情况
  if (infoEntities.isNotEmpty &&
      state.infoEntities.indexWhere(
              (keyword) => keyword.title == infoEntities[0].title) >=
          0) {
    return state;
  }
  final newState = state.clone();
  if (infoEntities.isNotEmpty) {
    infoEntities.addAll(newState.infoEntities);
    newState.infoEntities = infoEntities;
    newState.hasMoreEntities = infoEntities.length % Constants.pageSize == 0;
    _resetInfoEntityIndex(newState.infoEntities);
  } else {
    newState.hasMoreEntities = false;
    newState.nextPageNo = 0;
  }
  return newState;
}

InfoNavPageState _setNextPageEntitiesReducer(
    InfoNavPageState state, Action action) {
  final List<InfoEntity> infoEntities = action.payload ?? <InfoEntity>[];
  // 需要考虑重复读取的情况
  if (infoEntities.isNotEmpty &&
      state.infoEntities.indexWhere(
              (keyword) => keyword.title == infoEntities[0].title) >=
          0) {
    return state;
  }
  final newState = state.clone();
  if (infoEntities.isNotEmpty) {
    newState.infoEntities.addAll(infoEntities);
    newState.hasMoreEntities = infoEntities.length % Constants.pageSize == 0;
    newState.nextPageNo = newState.nextPageNo + 1;
    _resetInfoEntityIndex(newState.infoEntities);
  } else {
    newState.hasMoreEntities = false;
    newState.nextPageNo = 0;
  }
  return newState;
}

InfoNavPageState _setJumpPageEntitiesReducer(
    InfoNavPageState state, Action action) {
  final List<InfoEntity> infoEntities =
      action.payload[ParamNames.infoEntitiesParam] ?? [];
  final int pageNo = action.payload[ParamNames.pageNoParam];
  final newState = state.clone();
  if (infoEntities.isNotEmpty) {
    newState.infoEntities = infoEntities;
    newState.hasMoreEntities = infoEntities.length % Constants.pageSize == 0;
    newState.nextPageNo = pageNo + 1;
    newState.jumpFlag = true;
    newState.jumpComplete = false;
    _resetInfoEntityIndex(newState.infoEntities);
  } else {
    newState.hasMoreEntities = false;
    newState.nextPageNo = 0;
    newState.jumpFlag = false;
    newState.jumpComplete = false;
  }
  return newState;
}

InfoNavPageState _setIsLoadingFlagReducer(
    InfoNavPageState state, Action action) {
  final isLoading = action.payload ?? false;
  if (isLoading == state.isLoading) return state;
  final newState = state.clone()..isLoading = isLoading;
  return newState;
}

InfoNavPageState _setFilteredKeywordReducer(
    InfoNavPageState state, Action action) {
  final filterKeywords = action.payload;
  if (filterKeywords == state.filterKeywords) return state;
  final newState = state.clone()
    ..filterKeywords = filterKeywords
    ..jumpFlag = false
    ..jumpComplete = false;
  return newState;
}

InfoNavPageState _updateEntityItemReducer(
    InfoNavPageState state, Action action) {
  final index = action.payload;
  return state.updateItemData(index, state.getItemData(index), false).clone();
}

InfoNavPageState _setAutoSearchReducer(InfoNavPageState state, Action action) {
  final autoSearch = action.payload;
  if (autoSearch == state.autoSearch) return state;
  final newState = state.clone()..autoSearch = autoSearch;
  return newState;
}

InfoNavPageState _setJumpCompletedFlagReducer(
    InfoNavPageState state, Action action) {
  final newState = state.clone()..jumpComplete = true;
  return newState;
}

InfoNavPageState _setIsKeywordNavReducer(
    InfoNavPageState state, Action action) {
  final isKeywordNav = action.payload ?? false;
  if (isKeywordNav == state.isKeywordNav) return state;
  final newState = state.clone()..isKeywordNav = isKeywordNav;
  return newState;
}

void _resetInfoEntityIndex(List<InfoEntity> infoEntities) {
  var index = 0;
  infoEntities.forEach((entity) => entity.id = index++);
}
