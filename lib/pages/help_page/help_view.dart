import 'package:cached_network_image/cached_network_image.dart';
import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../common/utilities/tools.dart';
import '../../global_store/global_store.dart';
import 'help_content.dart';
import 'help_state.dart';

/// 状态数据变化刷新页面的本质：就是底层自动调用buildView方法，将变化的数据传入刷新界面
Widget buildView(HelpState state, Dispatch dispatch, ViewService viewService) {
  return Scaffold(
    appBar: AppBar(
      title: Text('操作指南'),
    ),
    body: _buildHelpUrlWidet(viewService),
  );
}

Widget _buildHelpUrlWidet(ViewService viewService) {
  var helpUrl = GlobalStore.currentTopicDef.helpUrl;
  if (helpUrl.indexOf('.md') > 0) {
    final helpName = Tools.getFileNameFromUrl(helpUrl);
    final imagePath = Tools.getPathFromUrl(helpUrl);
    return Markdown(
      selectable: true,
      data: helpContents[helpName],
      imageDirectory: imagePath,
    );
  } else if (helpUrl.indexOf('.gif') > 0) {
    return _buildGifImageWidget(viewService);
  }
  return SizedBox();
}

CachedNetworkImage _buildGifImageWidget(ViewService viewService) {
  var helpUrl = GlobalStore.currentTopicDef.helpUrl;
  return CachedNetworkImage(
    imageUrl: helpUrl ?? '',
    fit: BoxFit.cover,
    placeholder: (context, url) => Center(
      child: Container(
        height: 40,
        width: 40,
        margin: EdgeInsets.all(5),
        child: CircularProgressIndicator(),
      ),
    ),
    errorWidget: (context, url, error) =>
        Image(image: AssetImage('assets/images/amainfoindex.png')),
  );
}
