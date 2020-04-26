import 'package:fish_redux/fish_redux.dart';

import '../widgets/wrapper_widget.dart';
import 'login_effect.dart';
import 'login_reducer.dart';
import 'login_state.dart';
import 'login_view.dart';

class LoginPage extends Page<LoginState, Map<String, dynamic>> {
  /// effect定义了当前页面的操作行为集合
  /// reducer定义了当前页面的数据修改行为集合
  LoginPage()
      : super(
          initState: initState,
          effect: buildEffect(),
          reducer: buildReducer(),
          view: buildView,
          wrapper: keepAliveWrapper,
          dependencies: Dependencies<LoginState>(
              adapter: null, slots: <String, Dependent<LoginState>>{}),
          middleware: <Middleware<LoginState>>[],
        );
}
