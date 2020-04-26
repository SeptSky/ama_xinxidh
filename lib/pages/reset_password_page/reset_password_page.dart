import 'package:fish_redux/fish_redux.dart';

import '../widgets/wrapper_widget.dart';
import 'reset_password_effect.dart';
import 'reset_password_reducer.dart';
import 'reset_password_state.dart';
import 'reset_password_view.dart';

class ResetPasswordPage extends Page<ResetPasswordState, Map<String, dynamic>> {
  /// effect定义了当前页面的操作行为集合
  /// reducer定义了当前页面的数据修改行为集合
  ResetPasswordPage()
      : super(
          initState: initState,
          effect: buildEffect(),
          reducer: buildReducer(),
          view: buildView,
          wrapper: keepAliveWrapper,
          dependencies: Dependencies<ResetPasswordState>(
              adapter: null, slots: <String, Dependent<ResetPasswordState>>{}),
          middleware: <Middleware<ResetPasswordState>>[],
        );
}
