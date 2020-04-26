import 'package:fish_redux/fish_redux.dart';

import 'reset_password_state.dart';

Effect<ResetPasswordState> buildEffect() {
  return combineEffects(<Object, Effect<ResetPasswordState>>{
    Lifecycle.initState: _init,
  });
}

void _init(Action action, Context<ResetPasswordState> ctx) {
  /// 不使用Future.Delayed方法将会抛出异常，通过Delayed可以跳过首次执行顺序
  Future.delayed(Duration.zero, () {
    // ctx.dispatch(ResetPasswordReducerCreator.switchPageIndexReducer(0));
  });
}
