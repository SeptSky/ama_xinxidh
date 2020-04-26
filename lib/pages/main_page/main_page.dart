import 'package:fish_redux/fish_redux.dart';

import '../widgets/wrapper_widget.dart';
import 'main_effect.dart';
import 'main_reducer.dart';
import 'main_state.dart';
import 'main_view.dart';

class MainPage extends Page<MainState, Map<String, dynamic>> {
  /// effect定义了当前页面的操作行为集合
  /// reducer定义了当前页面的数据修改行为集合
  MainPage()
      : super(
          initState: initState,
          effect: buildEffect(),
          reducer: buildReducer(),
          view: buildView,
          wrapper: keepAliveWrapper,
          dependencies: Dependencies<MainState>(
              adapter: null, slots: <String, Dependent<MainState>>{}),
          middleware: <Middleware<MainState>>[],
        );
}
