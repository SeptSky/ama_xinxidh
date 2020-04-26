import 'package:fish_redux/fish_redux.dart';

import 'entity_effect.dart';
import 'entity_reducer.dart';
import 'entity_state.dart';
import 'entity_view.dart';

class EntityItemComponent extends Component<EntityState> {
  /// effect定义了当前组件的操作行为集合
  /// reducer定义了当前组件的数据修改行为集合
  EntityItemComponent()
      : super(
          view: buildView,
          effect: buildEffect(),
          reducer: buildReducer(),
        );
}
