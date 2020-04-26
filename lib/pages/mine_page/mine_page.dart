import 'package:fish_redux/fish_redux.dart';

import '../widgets/wrapper_widget.dart';
import 'mine_effect.dart';
import 'mine_reducer.dart';
import 'mine_state.dart';
import 'mine_view.dart';

class MinePage extends Page<MineState, Map<String, dynamic>> {
  /// effect定义了当前页面的操作行为集合
  /// reducer定义了当前页面的数据修改行为集合
  MinePage()
      : super(
          initState: initState,
          effect: buildEffect(),
          reducer: buildReducer(),
          view: buildView,
          wrapper: keepAliveWrapper,
          dependencies: Dependencies<MineState>(
              adapter: null, slots: <String, Dependent<MineState>>{}),
          middleware: <Middleware<MineState>>[],
        );
}
