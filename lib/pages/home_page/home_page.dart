import 'package:fish_redux/fish_redux.dart';

import '../widgets/wrapper_widget.dart';
import 'home_effect.dart';
import 'home_reducer.dart';
import 'home_state.dart';
import 'home_view.dart';

class HomePage extends Page<HomeState, Map<String, dynamic>> {
  /// effect定义了当前页面的操作行为集合
  /// reducer定义了当前页面的数据修改行为集合
  HomePage()
      : super(
          initState: initState,
          effect: buildEffect(),
          reducer: buildReducer(),
          view: buildView,
          wrapper: keepAliveWrapper,
          dependencies: Dependencies<HomeState>(
              adapter: null, slots: <String, Dependent<HomeState>>{}),
          middleware: <Middleware<HomeState>>[],
        );
}
