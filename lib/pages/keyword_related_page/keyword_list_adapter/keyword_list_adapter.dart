import 'package:fish_redux/fish_redux.dart';

import '../../../common/consts/component_names.dart';
import '../../keyword_nav_page/keyword_item_component/keyword_item_component.dart';
import '../keyword_related_reducer.dart';
import '../keyword_related_state.dart';

class KeywordListAdapter extends SourceFlowAdapter<KeywordRelatedPageState> {
  KeywordListAdapter()
      : super(
          /// 为什么Adapter使用pool概念注册Item组件？因为Item组件是重复使用的，为提高效率而缓存
          pool: <String, Component<Object>>{
            /// 使用唯一的标识符注册KeywordItem组件
            ComponentNames.keywordComponent: KeywordItemComponent(),
          },
          reducer: buildReducer(),
        );
}
