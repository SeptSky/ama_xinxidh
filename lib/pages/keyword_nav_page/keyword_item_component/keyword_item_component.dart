import 'package:fish_redux/fish_redux.dart';

import 'keyword_effect.dart';
import 'keyword_reducer.dart';
import 'keyword_state.dart';
import 'keyword_view.dart';

class KeywordItemComponent extends Component<KeywordState> {
  /// effect定义了当前组件的操作行为集合
  /// reducer定义了当前组件的数据修改行为集合
  KeywordItemComponent()
      : super(
          view: buildView,
          effect: buildEffect(),
          reducer: buildReducer(),
        );
}
