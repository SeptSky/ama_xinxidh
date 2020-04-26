import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action;

import 'entity_edit_action.dart';
import 'entity_edit_state.dart';

/// 状态数据变化刷新页面的本质：就是底层自动调用buildView方法，将变化的数据传入刷新界面
Widget buildView(
    EntityEditState state, Dispatch dispatch, ViewService viewService) {
  return Scaffold(
    appBar: AppBar(
      // backgroundColor: state.appTheme.barBgColor,
      title: const Text('Todo'),
    ),
    body: Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
                Container(
                  child: const Text('title:',
                      style: TextStyle(color: Colors.black, fontSize: 20.0)),
                  width: 56.0,
                  alignment: AlignmentDirectional.topEnd,
                ),
                Expanded(
                    child: Container(
                  color: const Color(0xFFE0E0E0),
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.only(left: 8.0),
                  child: EditableText(
                    controller: state.nameEditController,
                    focusNode: state.focusNodeName,
                    autofocus: true,
                    style: const TextStyle(color: Colors.black, fontSize: 16.0),
                    cursorColor: Colors.yellow,
                    backgroundCursorColor: const Color(0xFFFFF59D),
                  ),
                ))
              ],
            ),
          ),
          RaisedButton(
              padding: const EdgeInsets.only(
                  left: 20.0, top: 10.0, right: 20.0, bottom: 10.0),
              color: Colors.blue,
              child: const Text('Change theme',
                  style: TextStyle(fontSize: 18),
                  overflow: TextOverflow.ellipsis),
              onPressed: () {
                dispatch(EntityEditActionCreator.onChangeTheme());
              }),
          Expanded(
              child: Container(
            margin: const EdgeInsets.only(top: 32.0),
            alignment: AlignmentDirectional.topStart,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: const Text('desc:',
                      style: TextStyle(color: Colors.black, fontSize: 20.0)),
                  width: 56.0,
                  alignment: AlignmentDirectional.topEnd,
                ),
                Expanded(
                    child: Container(
                  color: const Color(0xFFE0E0E0),
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.only(left: 8.0),
                  child: EditableText(
                      controller: state.descEditController,
                      backgroundCursorColor: const Color(0xFFE0E0E0),
                      maxLines: 10,
                      focusNode: state.focusNodeDesc,
                      style:
                          const TextStyle(color: Colors.black, fontSize: 16.0),
                      cursorColor: Colors.yellow),
                ))
              ],
            ),
          ))
        ],
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => dispatch(EntityEditActionCreator.onDone()),
      tooltip: 'Done',
      child: const Icon(Icons.done),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
  );
}
