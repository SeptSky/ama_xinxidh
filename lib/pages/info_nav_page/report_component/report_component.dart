import 'package:fish_redux/fish_redux.dart';

import 'report_state.dart';
import 'report_view.dart';

class ReportComponent extends Component<ReportState> {
  ReportComponent()
      : super(
          view: buildView,
        );
}
