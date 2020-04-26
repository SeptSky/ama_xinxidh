import 'package:fish_redux/fish_redux.dart';

import '../widgets/wrapper_widget.dart';
import 'keyword_list_adapter/keyword_list_adapter.dart';
import 'keyword_related_effect.dart';
import 'keyword_related_reducer.dart';
import 'keyword_related_state.dart';
import 'keyword_related_view.dart';

class KeywordRelatedPage
    extends Page<KeywordRelatedPageState, Map<String, dynamic>> {
  /// effect定义了当前页面的操作行为集合
  /// reducer定义了当前页面的数据修改行为集合
  KeywordRelatedPage()
      : super(
          initState: initState,
          effect: buildEffect(),
          reducer: buildReducer(),
          view: buildView,
          wrapper: keepAliveWrapper,
          dependencies: Dependencies<KeywordRelatedPageState>(
            /// adapter对接数据列表子组件
            adapter: NoneConn<KeywordRelatedPageState>() + KeywordListAdapter(),

            /// 为什么使用slots概念注册普通的子组件，因为不像列表数据需要重复使用
            /// slots连接若干单一的子组件，在View文件中，使用viewService.buildComponent('report')创建子组件界面
            // slots: <String, Dependent<KeywordNavPageState>>{
            //   'report': ReportConnector() + ReportComponent()
            // }
          ),

          /// 页面私有AOP, 如果需要
          // middleware: <Middleware<PageState>>[
          //   logMiddleware(tag: 'ToDoListPage'),
          // ],
        );
}
