import 'package:fish_redux/fish_redux.dart';

import '../widgets/wrapper_widget.dart';
import 'theme_effect.dart';
import 'theme_reducer.dart';
import 'theme_state.dart';
import 'theme_view.dart';

class ThemePage extends Page<ThemeState, Map<String, dynamic>> {
  /// effect定义了当前页面的操作行为集合
  /// reducer定义了当前页面的数据修改行为集合
  ThemePage()
      : super(
          initState: initState,
          effect: buildEffect(),
          reducer: buildReducer(),
          view: buildView,
          wrapper: keepAliveWrapper,
          dependencies: Dependencies<ThemeState>(
              adapter: null, slots: <String, Dependent<ThemeState>>{}),
          middleware: <Middleware<ThemeState>>[],
        );
}
