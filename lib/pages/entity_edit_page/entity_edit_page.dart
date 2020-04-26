import 'package:fish_redux/fish_redux.dart';

import '../../models/entities/info_entity.dart';
import 'entity_edit_effect.dart';
import 'entity_edit_state.dart';
import 'entity_edit_view.dart';

class EntityEditPage extends Page<EntityEditState, InfoEntity> {
  /// effect定义了当前页面的操作行为集合
  /// reducer定义了当前页面的数据修改行为集合
  EntityEditPage()
      : super(
          initState: initState,
          effect: buildEffect(),
          view: buildView,

          /// 页面私有AOP，如果需要
          // middleware: <Middleware<TodoEditState>>[
          //   logMiddleware(tag: 'TodoEditPage'),
          // ],
        );
}
