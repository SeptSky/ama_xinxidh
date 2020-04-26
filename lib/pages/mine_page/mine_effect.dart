import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action;

import '../../common/consts/keys.dart';
import '../../common/utilities/shared_util.dart';
import '../../global_store/global_action.dart';
import '../../global_store/global_store.dart';
import '../../models/users/user_info.dart';
import '../home_page/home_action.dart';
import '../info_nav_page/info_nav_action.dart';
import 'mine_action.dart';
import 'mine_state.dart';

Effect<MineState> buildEffect() {
  return combineEffects(<Object, Effect<MineState>>{
    Lifecycle.initState: _init,
    MineActionEnum.onSignOut: _onSignOut,
  });
}

void _init(Action action, Context<MineState> ctx) {
  /// 不使用Future.Delayed方法将会抛出异常，通过Delayed可以跳过首次执行顺序
  Future.delayed(Duration.zero, () {
    // ctx.dispatch(MineReducerCreator.switchPageIndexReducer(0));
  });
}

void _onSignOut(Action action, Context<MineState> ctx) async {
  Navigator.of(ctx.context).pop();
  final userInfo = UserInfo.getInstance();
  GlobalStore.store.dispatch(GlobalReducerCreator.setUserInfoReducer(userInfo));
  await GlobalStore.clearLocalCache();
  await SharedUtil.instance.removeString(Keys.userInfo);
  ctx.broadcast(InfoNavPageActionCreator.onSetFilteredKeyword(null));
  ctx.broadcast(HomeActionCreator.onChangeUser());
}
