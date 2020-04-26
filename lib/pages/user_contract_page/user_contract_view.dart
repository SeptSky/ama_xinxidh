import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:flutter_markdown/flutter_markdown.dart';

import 'user_contract.dart';
import 'user_contract_state.dart';

/// 状态数据变化刷新页面的本质：就是底层自动调用buildView方法，将变化的数据传入刷新界面
Widget buildView(
    UserContractState state, Dispatch dispatch, ViewService viewService) {
  return Scaffold(
      appBar: AppBar(
        title: Text('用户协议'),
      ),
      body: Markdown(selectable: true, data: markdownData));
}
