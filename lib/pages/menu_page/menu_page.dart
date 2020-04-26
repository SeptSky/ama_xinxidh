import 'package:fish_redux/fish_redux.dart';

import '../widgets/wrapper_widget.dart';
import 'menu_effect.dart';
import 'menu_reducer.dart';
import 'menu_state.dart';
import 'menu_view.dart';

class MenuPage extends Page<MenuState, Map<String, dynamic>> {
  /// effect定义了当前页面的操作行为集合
  /// reducer定义了当前页面的数据修改行为集合
  MenuPage()
      : super(
          initState: initState,
          effect: buildEffect(),
          reducer: buildReducer(),
          view: buildView,
          wrapper: keepAliveWrapper,
          dependencies: Dependencies<MenuState>(
              adapter: null, slots: <String, Dependent<MenuState>>{}),
          middleware: <Middleware<MenuState>>[],
        );
}
