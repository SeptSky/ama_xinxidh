import 'package:fish_redux/fish_redux.dart';

import '../widgets/wrapper_widget.dart';
import 'about_effect.dart';
import 'about_reducer.dart';
import 'about_state.dart';
import 'about_view.dart';

class AboutPage extends Page<AboutState, Map<String, dynamic>> {
  /// effect定义了当前页面的操作行为集合
  /// reducer定义了当前页面的数据修改行为集合
  AboutPage()
      : super(
          initState: initState,
          effect: buildEffect(),
          reducer: buildReducer(),
          view: buildView,
          wrapper: keepAliveWrapper,
          dependencies: Dependencies<AboutState>(
              adapter: null, slots: <String, Dependent<AboutState>>{}),
          middleware: <Middleware<AboutState>>[],
        );
}
