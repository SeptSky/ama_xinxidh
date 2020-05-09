import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';

import '../../../common/consts/constants.dart';
import '../../../common/consts/enum_types.dart';
import '../../../common/consts/param_names.dart';
import '../../../common/utilities/dialogs.dart';
import '../../../global_store/global_store.dart';
import '../../widgets/single_widgets.dart';
import '../entity_item_component/entity_state.dart';
import '../info_nav_action.dart';
import 'entity_action.dart';
import 'entity_input_controllers.dart';

Widget buildEntityBody(
    EntityState entityState, Dispatch dispatch, ViewService viewService) {
  final itemBackgroundColor =
      entityState.pressed ? Colors.grey[200] : GlobalStore.themeItemBackground;
  final isKeywordNav = entityState.isKeywordNav;
  return Container(
    padding: const EdgeInsets.all(5.0),
    decoration: buildShadowBox(itemBackgroundColor, Colors.grey[300], 6.0),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildEntityTitleSection(entityState, dispatch),
      buildEntityContentSection(
          entityState, dispatch, viewService, isKeywordNav),
      isKeywordNav ? SizedBox() : buildScrollTagsRow(entityState, dispatch),
    ]),
  );
}

GestureDetector _buildEntityTitleSection(
    EntityState entityState, Dispatch dispatch) {
  final bgColor = entityState.pressed ? Colors.white : Colors.red;
  return GestureDetector(
    child: Container(
        height: 36.0,
        decoration: buildUnderlineBox(bgColor, Color(0xFFEEEEEE)),
        child: Row(
          children: <Widget>[
            buildIcon(Icons.share, color: GlobalStore.themePrimaryIcon),
            Expanded(child: buildEntityTitleText(entityState)),
          ],
        ),
        alignment: AlignmentDirectional.centerStart),
    onTap: () {
      if (entityState.infoDisplayer == EntityType.browserUrlType) {
        dispatch(InfoNavPageActionCreator.onSharePageUrl(entityState));
      }
    },
  );
}

Widget buildEntityTitleText(EntityState entityState) {
  var title = _removeIdentifierFromTitle(entityState.title);
  return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: BouncingScrollPhysics(),
      child: Text(
        '$title',
        style: entityState.pressed
            ? GlobalStore.titleStyle.copyWith(fontWeight: FontWeight.bold)
            : GlobalStore.titleStyle,
      ));
}

Widget buildEntityContentSection(EntityState entityState, Dispatch dispatch,
    ViewService viewService, bool isKeywordNav) {
  switch (entityState.displayMode) {
    case DisplayMode.entityAction:
      return buildEntityActionSection(entityState, dispatch, viewService);
    case DisplayMode.tagAction:
      return buildTagActionSection(entityState, dispatch, viewService);
    default:
      return _buildEntitySubtitleSection(entityState, dispatch, isKeywordNav);
  }
}

Widget _buildEntitySubtitleSection(
    EntityState entityState, Dispatch dispatch, bool isKeywordNav) {
  final Color bgColor = entityState.pressed ? Colors.white : Colors.red;
  final bool hasMultilineOverview =
      entityState.overview != null && entityState.overview.contains('\\n');
  return GestureDetector(
    child: Container(
        decoration:
            isKeywordNav ? null : buildUnderlineBox(bgColor, Color(0xFFEEEEEE)),
        child: Row(
          children: [
            hasMultilineOverview
                ? SizedBox()
                : buildImageBox(entityState.imageUrl),
            Expanded(child: _buildEntitySubtitleText(entityState)),
          ],
        )),
    onTap: () =>
        dispatch(InfoNavPageActionCreator.onInfoEntityPressed(entityState)),
    onLongPress: () => onEntityLongPressed(entityState, dispatch),
  );
}

void onEntityLongPressed(EntityState entityState, Dispatch dispatch) {
  final roleId = GlobalStore.userInfo.roleId;
  if (roleId == Constants.superAdminRoleId) {
    _setEntityAction(entityState, dispatch, DisplayMode.entityAction);
  }
}

Widget _buildEntitySubtitleText(EntityState entityState) {
  final bool hasMultilineOverview =
      entityState.overview != null && entityState.overview.contains('\\n');
  if (hasMultilineOverview) {
    final List<String> lines = entityState.overview.split('\\n');
    List<Widget> widgetLines = List<Widget>();
    widgetLines.add(SizedBox(height: 4));
    widgetLines.addAll(lines
        .map((line) => Column(children: [
              Text(line, style: GlobalStore.subtitleStyle),
              const SizedBox(height: 4)
            ]))
        .toList());
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: widgetLines);
  }
  var subtitle = entityState.overview != null
      ? entityState.overview
      : entityState.subtitle;
  return Text(subtitle,
      style: GlobalStore.subtitleStyle,
      softWrap: true,
      maxLines: Constants.subtitleMaxLines);
}

Widget buildEntityActionSection(
    EntityState entityState, Dispatch dispatch, ViewService viewService) {
  final actionColor = GlobalStore.themePrimaryIcon;
  return Container(
      decoration: buildUnderlineBox(Colors.white, Color(0xFFEEEEEE)),
      child: Row(children: [
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildEntityActionList(entityState, dispatch, viewService),
        )),
        buildActionItem(Text('关闭', style: TextStyle(color: actionColor)),
            onTap: () =>
                _setEntityAction(entityState, dispatch, DisplayMode.normal))
      ]));
}

List<Widget> _buildEntityActionList(
    EntityState entityState, Dispatch dispatch, ViewService viewService) {
  final actionColor = GlobalStore.themePrimaryIcon;
  final isContentVisible = _isContentVisible(entityState);
  final addCaption = isContentVisible ? '参照添加信息条目' : '参照添加信息专题';
  final editCaption = isContentVisible ? '修改当前信息条目' : '修改当前信息专题';
  return [
    buildActionItem(Text(addCaption, style: TextStyle(color: actionColor)),
        onTap: () => _onAddNewEntity(entityState, dispatch, viewService)),
    SizedBox(height: 5),
    buildActionItem(Text(editCaption, style: TextStyle(color: actionColor)),
        onTap: () async => _onEditEntity(entityState, dispatch, viewService)),
    isContentVisible ? SizedBox(height: 5) : SizedBox(),
    isContentVisible
        ? buildActionItem(
            Text('删除当前信息条目', style: TextStyle(color: actionColor)),
            onTap: () => _onDeleteEntity(entityState, dispatch, viewService))
        : SizedBox(),
  ];
}

Widget buildTagActionSection(
    EntityState entityState, Dispatch dispatch, ViewService viewService) {
  final actionColor = GlobalStore.themePrimaryIcon;
  return Container(
      decoration: buildUnderlineBox(Colors.white, Color(0xFFEEEEEE)),
      child: Row(children: [
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildTagActionList(entityState, dispatch, viewService),
        )),
        buildActionItem(Text('关闭', style: TextStyle(color: actionColor)),
            onTap: () =>
                _setTagAction(entityState, dispatch, null, DisplayMode.normal))
      ]));
}

List<Widget> _buildTagActionList(
    EntityState entityState, Dispatch dispatch, ViewService viewService) {
  final actionColor = GlobalStore.themePrimaryIcon;
  return [
    buildActionItem(
        Text('查找【${entityState.performedTag}】关联专题',
            style: TextStyle(color: actionColor)),
        onTap: () async => dispatch(
            InfoNavPageActionCreator.onSearchRelatedTopics(
                entityState.performedTag))),
    SizedBox(height: 5),
    buildActionItem(Text('添加新标签', style: TextStyle(color: actionColor)),
        onTap: () => _onAddNewTag(entityState, dispatch, viewService)),
    SizedBox(height: 5),
    buildActionItem(
        Text('删除当前信息标签【${entityState.performedTag}】',
            style: TextStyle(color: actionColor)),
        onTap: () async =>
            _onDelTagFromEntity(entityState, dispatch, viewService)),
    SizedBox(height: 5),
    buildActionItem(
        Text('删除当前专题标签【${entityState.performedTag}】',
            style: TextStyle(color: actionColor)),
        onTap: () => _onDelTagFromTopic(entityState, dispatch, viewService)),
  ];
}

/// 创建不带分页功能的信息实体列表
Expanded buildEntityListView(ViewService viewService) {
  final ListAdapter adapter = viewService.buildAdapter();
  return Expanded(
      child: ListView.builder(
          itemBuilder: adapter.itemBuilder, itemCount: adapter.itemCount));
}

Widget buildScrollTagsRow(EntityState entityState, Dispatch dispatch) {
  final tags = entityState.entityTags.split(',');
  final tagColor = GlobalStore.themePrimaryIcon;
  final tagStyle = GlobalStore.subtitleStyle
      .copyWith(color: tagColor, decoration: TextDecoration.underline);
  final pressedTagStyle = GlobalStore.subtitleStyle.copyWith(
      fontWeight: FontWeight.bold,
      color: tagColor,
      decoration: TextDecoration.underline);
  final topicKeyword = GlobalStore.currentTopicDef.topicKeyword;
  final filteredTags = tags.where((tag) => tag != topicKeyword);
  final topicKeywordIndex = tags.indexOf(topicKeyword);
  if (topicKeywordIndex > 0) {
    final topicTitle = tags[0] + Constants.indexKeyword;
    return buildBoxContainerWithTap(
        null, Colors.transparent, 0, Text(topicTitle, style: tagStyle),
        onTap: () {
      dispatch(InfoNavPageActionCreator.onJumpToTopicDef(
          '$topicTitle,$topicKeyword'));
    });
  }
  final tagsBar = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: BouncingScrollPhysics(),
      child: Row(
        children: filteredTags.map((tag) {
          final filterKeywords = GlobalStore.filterKeywords;
          final pressed =
              filterKeywords != null && filterKeywords.indexOf(tag) >= 0;
          final style = pressed ? pressedTagStyle : tagStyle;
          if (entityState.isInvalidTag(tag)) return SizedBox();
          return buildBoxContainerWithTap(
              null, Colors.transparent, 0, Text(tag, style: style), onTap: () {
            dispatch(InfoNavPageActionCreator.onTagPressed(tag));
          }, onLongPress: () {
            _onTagLongPressed(entityState, dispatch, tag);
          });
        }).toList(),
      ));
  final favoriteIcon = entityState.favorite ? Icons.star : Icons.star_border;
  return Row(
    children: [
      Expanded(child: tagsBar),
      buildIconWithTap(favoriteIcon, () {
        dispatch(InfoNavPageActionCreator.onFavoriteInfoEntity(entityState));
      }, size: 18.0, margin: 0, color: tagColor),
      SizedBox(width: 4.0)
    ],
  );
}

void _onTagLongPressed(EntityState entityState, Dispatch dispatch, String tag) {
  final roleId = GlobalStore.userInfo.roleId;
  if (roleId == Constants.superAdminRoleId) {
    _setTagAction(entityState, dispatch, tag, DisplayMode.tagAction);
  } else {
    dispatch(InfoNavPageActionCreator.onSearchRelatedTopics(tag));
  }
}

void _onAddNewEntity(
    EntityState entityState, Dispatch dispatch, ViewService viewService) {
  if (!_validateOperation()) return;
  _setEntityAction(entityState, dispatch, DisplayMode.normal);
  _showAddEntityDialog(entityState, dispatch, viewService);
}

void _onEditEntity(
    EntityState entityState, Dispatch dispatch, ViewService viewService) {
  if (!_validateOperation()) return;
  _setEntityAction(entityState, dispatch, DisplayMode.normal);
  _showEditEntityDialog(entityState, dispatch, viewService);
}

void _onDeleteEntity(
    EntityState entityState, Dispatch dispatch, ViewService viewService) async {
  final result =
      await Dialogs.showConfirmDialog(viewService.context, '是否删除当前信息条目？');
  if (result == Constants.dialogYes) {
    dispatch(InfoNavPageActionCreator.onDelInfoEntity(entityState.keyId));
    _setEntityAction(entityState, dispatch, DisplayMode.normal);
  }
}

void _onAddNewTag(
    EntityState entityState, Dispatch dispatch, ViewService viewService) {
  if (!_validateOperation()) return;
  _setTagAction(entityState, dispatch, null, DisplayMode.normal);
  _showAddTagDialog(entityState, dispatch, viewService);
}

void _onDelTagFromEntity(
    EntityState entityState, Dispatch dispatch, ViewService viewService) async {
  final result = await Dialogs.showConfirmDialog(
      viewService.context, '是否删除当前信息标签【${entityState.performedTag}】？');
  if (result == Constants.dialogYes) {
    final delTagParam = {
      ParamNames.entityIdParam: entityState.keyId,
      ParamNames.tagParam: entityState.performedTag
    };
    dispatch(InfoNavPageActionCreator.onDelInfoEntityTag(delTagParam));
    _setTagAction(entityState, dispatch, null, DisplayMode.normal);
  }
}

void _onDelTagFromTopic(
    EntityState entityState, Dispatch dispatch, ViewService viewService) async {
  final sourceType = GlobalStore.sourceType;
  final contentType = GlobalStore.contentType;
  final bgColor = GlobalStore.themePrimaryIcon;
  if (sourceType != SourceType.normal ||
      contentType != ContentType.infoEntity) {
    Dialogs.showInfoToast('只能在专题内删除指定的标签！', bgColor);
    return;
  }
  final result = await Dialogs.showConfirmDialog(
      viewService.context, '是否删除当前专题标签【${entityState.performedTag}】？');
  if (result == Constants.dialogYes) {
    final tagName = entityState.performedTag;
    dispatch(InfoNavPageActionCreator.onDelTagFromTopic(tagName));
    _setTagAction(entityState, dispatch, null, DisplayMode.normal);
  }
}

void _setEntityAction(
    EntityState entityState, Dispatch dispatch, DisplayMode displayMode) {
  final index = entityState.index;
  final dynamic displayModeParam = {
    ParamNames.indexParam: index,
    ParamNames.displayModeParam: displayMode
  };
  dispatch(InfoEntityReducerCreator.setDisplayModeReducer(displayModeParam));
  dispatch(InfoNavPageReducerCreator.updateEntityItemReducer(index));
}

void _setTagAction(EntityState entityState, Dispatch dispatch, String tag,
    DisplayMode displayMode) {
  final index = entityState.index;
  final dynamic displayModeParam = {
    ParamNames.indexParam: index,
    ParamNames.tagParam: tag,
    ParamNames.displayModeParam: displayMode
  };
  dispatch(InfoEntityReducerCreator.setDisplayModeReducer(displayModeParam));
  dispatch(InfoNavPageReducerCreator.updateEntityItemReducer(index));
}

void _showAddEntityDialog(
    EntityState entityState, Dispatch dispatch, ViewService viewService) {
  EntityInputControllers.clearAll();
  final height = _getDialogHeight(entityState);
  final dialog = _buildEmptyDialog(viewService.context, height);
  dialog.widget(_buildAddEntityBody(
      entityState, dispatch, viewService, () => dialog.dismiss()));
  dialog.show();
}

void _showEditEntityDialog(
    EntityState entityState, Dispatch dispatch, ViewService viewService) {
  EntityInputControllers.clearAll();
  EntityInputControllers.titleController.text = entityState.title;
  EntityInputControllers.overviewController.text = entityState.overview;
  EntityInputControllers.contentController.text = entityState.subtitle;
  EntityInputControllers.tagController.text = entityState.entityTags;
  final height = _getDialogHeight(entityState);
  final dialog = _buildEmptyDialog(viewService.context, height);
  dialog.widget(_buildEditEntityBody(entityState, dispatch, viewService));
  dialog.show();
}

Widget _buildAddEntityBody(EntityState entityState, Dispatch dispatch,
    ViewService viewService, Function onClose) {
  final isContentVisible = _isContentVisible(entityState);
  final caption = isContentVisible ? '参照添加信息条目' : '参照添加信息专题';
  return Container(
    padding: _buildDialogPadding(),
    child: Column(children: [
      _buildDialogTitle(caption),
      SizedBox(height: 5),
      Container(decoration: buildUnderlineBox(null, Color(0xFFEEEEEE))),
      SizedBox(height: 5),
      _buildAddEditEntityTextForm(entityState, dispatch, viewService),
      SizedBox(height: 20),
      _buildAddEntityButtonBar(onClose, entityState, dispatch),
    ]),
  );
}

Widget _buildEditEntityBody(
    EntityState entityState, Dispatch dispatch, ViewService viewService) {
  final isContentVisible = _isContentVisible(entityState);
  final caption = isContentVisible ? '修改当前信息条目' : '修改当前信息专题';
  return Container(
    padding: _buildDialogPadding(),
    child: Column(children: [
      _buildDialogTitle(caption),
      SizedBox(height: 5),
      Container(decoration: buildUnderlineBox(null, Color(0xFFEEEEEE))),
      SizedBox(height: 5),
      _buildAddEditEntityTextForm(entityState, dispatch, viewService),
      SizedBox(height: 20),
      _buildEditEntityButtonBar(entityState, dispatch, viewService),
    ]),
  );
}

EdgeInsets _buildDialogPadding() {
  return const EdgeInsets.fromLTRB(10.0, 38.0, 10.0, 10.0);
}

Widget _buildDialogTitle(String tile) {
  return Text(tile, style: TextStyle(fontSize: 18.0));
}

Widget _buildAddEntityButtonBar(
    Function onClose, EntityState entityState, Dispatch dispatch) {
  final color = GlobalStore.themePrimaryIcon;
  return buildDualButtonRow(
    buildCustomButton('关闭', color, onClose),
    buildCustomButton('添加', color, () {
      if (_addInfoEntity(entityState, dispatch)) onClose();
    }),
  );
}

bool _addInfoEntity(EntityState entityState, Dispatch dispatch) {
  final title = EntityInputControllers.titleController.text.trim();
  if (title.isEmpty) {
    Dialogs.showErrorToast('信息标题不能为空！');
    return false;
  }
  final overview = EntityInputControllers.overviewController.text.trim();
  final content = EntityInputControllers.contentController.text.trim();
  if (overview.isEmpty && content.isEmpty) {
    Dialogs.showErrorToast('信息概述和信息内容不能都为空！');
    return false;
  }
  final tags = EntityInputControllers.tagController.text.trim();
  final addEntityParam = {
    ParamNames.entityIdParam: entityState.keyId,
    ParamNames.entityTitleParam: _formatEntityTitle(entityState, title),
    ParamNames.entityOverviewParam: overview,
    ParamNames.entityContentParam: content,
    ParamNames.tagParam: tags
  };
  dispatch(InfoNavPageActionCreator.onAddInfoEntity(addEntityParam));
  return true;
}

Widget _buildEditEntityButtonBar(
    EntityState entityState, Dispatch dispatch, ViewService viewService) {
  final color = GlobalStore.themePrimaryIcon;
  return buildDualButtonRow(
    buildCustomButton('关闭', color, () => _closeDialog(viewService.context)),
    buildCustomButton('保存', color, () {
      if (_saveInfoEntity(entityState, dispatch))
        _closeDialog(viewService.context);
    }),
  );
}

bool _saveInfoEntity(EntityState entityState, Dispatch dispatch) {
  final title = EntityInputControllers.titleController.text.trim();
  if (title.isEmpty) {
    Dialogs.showErrorToast('信息标题不能为空！');
    return false;
  }
  final overview = EntityInputControllers.overviewController.text.trim();
  final content = EntityInputControllers.contentController.text.trim();
  if (overview.isEmpty && content.isEmpty) {
    Dialogs.showErrorToast('信息概述和信息内容不能都为空！');
    return false;
  }
  final tags = EntityInputControllers.tagController.text.trim();
  final editEntityParam = {
    ParamNames.entityIdParam: entityState.keyId,
    ParamNames.entityTitleParam: title,
    ParamNames.entityOverviewParam: overview,
    ParamNames.entityContentParam: content,
    ParamNames.tagParam: tags
  };
  dispatch(InfoNavPageActionCreator.onEditInfoEntity(editEntityParam));
  return true;
}

Widget _buildAddEditEntityTextForm(
    EntityState state, Dispatch dispatch, ViewService viewService) {
  final isContentVisible = _isContentVisible(state);
  return Container(
    decoration: const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
      color: Colors.white,
    ),
    child: Form(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildEntityTitleInput(state, viewService),
          _buildSeparatorLine(),
          _buildEntitySubtitleInput(state, viewService),
          _buildSeparatorLine(),
          isContentVisible
              ? _buildEntityContentInput(state, viewService)
              : SizedBox(),
          isContentVisible ? _buildSeparatorLine() : SizedBox(),
          _buildEntityTagsInput(state, viewService),
          _buildSeparatorLine(),
        ],
      ),
    ),
  );
}

Widget _buildEntityTitleInput(EntityState state, ViewService viewService) {
  final titleController = EntityInputControllers.titleController;
  final requestNode = EntityInputControllers.overviewFocusNode;
  return _buildEntityTextInput(
      viewService.context, titleController, '信息标题', Icons.title,
      requestNode: requestNode);
}

Widget _buildEntitySubtitleInput(EntityState state, ViewService viewService) {
  final subtitleController = EntityInputControllers.overviewController;
  final focusNode = EntityInputControllers.overviewFocusNode;
  final requestNode = EntityInputControllers.contentFocusNode;
  return _buildEntityTextInput(
      viewService.context, subtitleController, '信息概述', Icons.subject,
      maxLines: 2, focusNode: focusNode, requestNode: requestNode);
}

Widget _buildEntityContentInput(EntityState state, ViewService viewService) {
  final contentController = EntityInputControllers.contentController;
  final focusNode = EntityInputControllers.contentFocusNode;
  final requestNode = EntityInputControllers.tagFocusNode;
  return _buildEntityTextInput(
      viewService.context, contentController, '信息内容或链接地址', Icons.subject,
      maxLines: 2, focusNode: focusNode, requestNode: requestNode);
}

Widget _buildEntityTagsInput(EntityState state, ViewService viewService) {
  final tagController = EntityInputControllers.tagController;
  final focusNode = EntityInputControllers.tagFocusNode;
  return _buildEntityTextInput(
      viewService.context, tagController, '一个或多个信息标签', Icons.label_outline,
      focusNode: focusNode);
}

void _showAddTagDialog(
    EntityState entityState, Dispatch dispatch, ViewService viewService) {
  EntityInputControllers.clearAll();
  final dialog = _buildEmptyDialog(viewService.context, 180);
  dialog.widget(_buildAddTagBody(entityState, dispatch, viewService));
  dialog.show();
}

Widget _buildAddTagBody(
    EntityState entityState, Dispatch dispatch, ViewService viewService) {
  return Container(
    padding: _buildDialogPadding(),
    child: Column(children: [
      _buildDialogTitle("添加一组信息标签"),
      SizedBox(height: 5),
      Container(decoration: buildUnderlineBox(null, Color(0xFFEEEEEE))),
      SizedBox(height: 5),
      _buildAddEntityTagForm(entityState, dispatch, viewService),
      SizedBox(height: 20),
      _buildAddTagButtonBar(entityState.keyId, dispatch, viewService),
    ]),
  );
}

Widget _buildAddEntityTagForm(
    EntityState state, Dispatch dispatch, ViewService viewService) {
  return Container(
    decoration: const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
      color: Colors.white,
    ),
    child: Form(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildEntityTagInput(state, viewService),
          _buildSeparatorLine(),
        ],
      ),
    ),
  );
}

Widget _buildEntityTagInput(EntityState state, ViewService viewService) {
  final tagController = EntityInputControllers.tagController;
  return _buildEntityTextInput(
      viewService.context, tagController, '输入新标签，空格分隔多标签', Icons.label_outline);
}

Widget _buildAddTagButtonBar(
    int entityId, Dispatch dispatch, ViewService viewService) {
  final tagController = EntityInputControllers.tagController;
  final color = GlobalStore.themePrimaryIcon;
  return buildDualButtonRow(
    buildCustomButton('关闭', color, () => _closeDialog(viewService.context)),
    buildCustomButton('添加', color, () {
      if (tagController.text.isEmpty) return;
      final addTagParam = {
        ParamNames.entityIdParam: entityId,
        ParamNames.tagParam: tagController.text
      };
      dispatch(InfoNavPageActionCreator.onAddInfoEntityTags(addTagParam));
      _closeDialog(viewService.context);
    }),
  );
}

YYDialog _buildEmptyDialog(BuildContext context, double height) {
  final screenWidth = MediaQuery.of(context).size.width;
  final dialog = YYDialog().build();
  dialog.gravity = Gravity.top;
  dialog.gravityAnimationEnable = true;
  dialog.borderRadius = 4.0;
  dialog.barrierDismissible = false;
  dialog.width = screenWidth;
  dialog.height = height;
  return dialog;
}

Widget _buildEntityTextInput(BuildContext context,
    TextEditingController controller, String hintText, IconData iconName,
    {int maxLines = 1, FocusNode focusNode, FocusNode requestNode}) {
  final color = GlobalStore.themePrimaryIcon;
  return Padding(
    padding: const EdgeInsets.only(left: 5.0, right: 5.0, top: 0.0),
    child: TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: TextInputType.text,
      autocorrect: false,
      autofocus: false,
      enabled: true,
      focusNode: focusNode,
      onEditingComplete: () => FocusScope.of(context).requestFocus(requestNode),
      decoration: InputDecoration(
          icon: Icon(iconName, color: color),
          hintText: hintText,
          border: InputBorder.none,
          suffixIcon: _buildTextClearButton(controller)),
      style: TextStyle(fontSize: 16),
    ),
  );
}

Widget _buildTextClearButton(TextEditingController textController) {
  return IconButton(
      icon: const Icon(Icons.cancel),
      color: Colors.grey,
      iconSize: 18.0,
      onPressed: () {
        try {
          textController.clear();
        } catch (err) {
          throw Exception('');
        }
      });
}

Widget _buildSeparatorLine() {
  return Container(height: 1.0, color: Colors.grey[200]);
}

String _removeIdentifierFromTitle(String title) {
  var atIndex = title.lastIndexOf('@');
  if (atIndex < 0) return title;
  return title.substring(0, atIndex);
}

double _getDialogHeight(EntityState entityState) {
  if (_isContentVisible(entityState)) {
    return 352;
  }
  return 290;
}

bool _isContentVisible(EntityState entityState) {
  switch (entityState.infoDisplayer) {
    case EntityType.topicDefType:
      return false;
    default:
      return true;
  }
}

String _formatEntityTitle(EntityState entityState, String title) {
  switch (entityState.infoDisplayer) {
    case EntityType.topicDefType:
      if (!title.endsWith(Constants.indexKeyword))
        return title + Constants.indexKeyword;
      return title;
    default:
      return title;
  }
}

Future _closeDialog(BuildContext context) async {
  if (Navigator.of(context).canPop()) {
    Navigator.of(context).pop();
  }
}

bool _validateOperation() {
  if (GlobalStore.searchMode) {
    Dialogs.showInfoToast('搜索状态不能执行操作！', GlobalStore.themePrimaryIcon);
    return false;
  }
  return true;
}
