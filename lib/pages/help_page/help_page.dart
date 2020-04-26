import 'package:fish_redux/fish_redux.dart';

import '../widgets/wrapper_widget.dart';
import 'help_state.dart';
import 'help_view.dart';

class HelpPage extends Page<HelpState, Map<String, dynamic>> {
  HelpPage()
      : super(
          initState: initState,
          view: buildView,
          wrapper: keepAliveWrapper,
          dependencies: Dependencies<HelpState>(
              adapter: null, slots: <String, Dependent<HelpState>>{}),
          middleware: <Middleware<HelpState>>[],
        );
}
