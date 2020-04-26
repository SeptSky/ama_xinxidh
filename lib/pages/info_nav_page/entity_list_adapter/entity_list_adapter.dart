import 'package:fish_redux/fish_redux.dart';

import '../../../common/consts/component_names.dart';
import '../entity_item_component/entity_item_component.dart';
import '../info_nav_state.dart';
import 'entity_list_reducer.dart';

class EntityListAdapter extends SourceFlowAdapter<InfoNavPageState> {
  EntityListAdapter()
      : super(
          /// 为什么Adapter使用pool概念注册Item组件？因为Item组件是重复使用的，为提高效率而缓存
          pool: <String, Component<Object>>{
            /// 使用唯一的标识符注册InfoEntityItem组件
            ComponentNames.infoEntityComponent: EntityItemComponent(),
          },
          reducer: buildReducer(),
        );
}
