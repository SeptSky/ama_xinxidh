import 'package:fish_redux/fish_redux.dart';

import '../widgets/wrapper_widget.dart';
import 'intro_effect.dart';
import 'intro_reducer.dart';
import 'intro_state.dart';
import 'intro_view.dart';

class IntroPage extends Page<IntroState, Map<String, dynamic>> {
  IntroPage()
      : super(
          initState: initState,
          effect: buildEffect(),
          reducer: buildReducer(),
          view: buildView,
          wrapper: keepAliveWrapper,
          dependencies: Dependencies<IntroState>(
              adapter: null, slots: <String, Dependent<IntroState>>{}),
          middleware: <Middleware<IntroState>>[],
        );
}
