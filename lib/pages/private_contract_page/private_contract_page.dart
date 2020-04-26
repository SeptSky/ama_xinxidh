import 'package:fish_redux/fish_redux.dart';

import '../widgets/wrapper_widget.dart';
import 'private_contract_state.dart';
import 'private_contract_view.dart';

class PrivateContractPage extends Page<PrivateContractState, Map<String, dynamic>> {
  PrivateContractPage()
      : super(
          initState: initState,
          view: buildView,
          wrapper: keepAliveWrapper,
          dependencies: Dependencies<PrivateContractState>(
              adapter: null, slots: <String, Dependent<PrivateContractState>>{}),
          middleware: <Middleware<PrivateContractState>>[],
        );
}
