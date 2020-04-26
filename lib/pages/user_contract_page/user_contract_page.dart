import 'package:fish_redux/fish_redux.dart';

import '../widgets/wrapper_widget.dart';
import 'user_contract_state.dart';
import 'user_contract_view.dart';

class UserContractPage extends Page<UserContractState, Map<String, dynamic>> {
  UserContractPage()
      : super(
          initState: initState,
          view: buildView,
          wrapper: keepAliveWrapper,
          dependencies: Dependencies<UserContractState>(
              adapter: null, slots: <String, Dependent<UserContractState>>{}),
          middleware: <Middleware<UserContractState>>[],
        );
}
