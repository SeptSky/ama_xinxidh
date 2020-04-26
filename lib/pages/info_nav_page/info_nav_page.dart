import 'package:fish_redux/fish_redux.dart';

import 'entity_list_adapter/entity_list_adapter.dart';
import 'info_nav_effect.dart';
import 'info_nav_reducer.dart';
import 'info_nav_state.dart';
import 'info_nav_view.dart';

class InfoNavPage extends Page<InfoNavPageState, Map<String, dynamic>> {
  /// effect定义了当前页面的操作行为集合
  /// reducer定义了当前页面的数据修改行为集合
  InfoNavPage()
      : super(
          initState: initState,
          effect: buildEffect(),
          reducer: buildReducer(),
          view: buildView,
          dependencies: Dependencies<InfoNavPageState>(
            /// adapter对接数据列表子组件
            adapter: NoneConn<InfoNavPageState>() + EntityListAdapter(),

            /// 为什么使用slots概念注册普通的子组件，因为不像列表数据需要重复使用
            /// slots连接若干单一的子组件，在View文件中，使用viewService.buildComponent('report')创建子组件界面
            // slots: <String, Dependent<InfoNavPageState>>{
            //   'report': ReportConnector() + ReportComponent()
            // }
          ),

          /// 页面私有AOP, 如果需要
          // middleware: <Middleware<PageState>>[
          //   logMiddleware(tag: 'ToDoListPage'),
          // ],
        );
}
