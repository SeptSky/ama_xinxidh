import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:package_info/package_info.dart';

import '../../common/i10n/localization_intl.dart';
import '../../common/utilities/tools.dart';
import '../../global_store/global_store.dart';
import 'about_state.dart';

/// 状态数据变化刷新页面的本质：就是底层自动调用buildView方法，将变化的数据传入刷新界面
Widget buildView(AboutState state, Dispatch dispatch, ViewService viewService) {
  return Scaffold(
    appBar: AppBar(
      title: Text(LinuxLocalizations.of(viewService.context).aboutApp),
    ),
    body: _buildAboutBody(state, dispatch, viewService),
  );
}

Container _buildAboutBody(
    AboutState state, Dispatch dispatch, ViewService viewService) {
  return Container(
    margin: EdgeInsets.all(20),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildAboutHeaderSection(state, dispatch, viewService),
        _buildAboutContentSection(state, dispatch, viewService),
      ],
    ),
  );
}

Row _buildAboutHeaderSection(
    AboutState state, Dispatch dispatch, ViewService viewService) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      _buildAboutHeaderIcon(state, dispatch, viewService),
      _buildAboutHeaderText(state, dispatch, viewService),
    ],
  );
}

Container _buildAboutHeaderIcon(
    AboutState state, Dispatch dispatch, ViewService viewService) {
  return Container(
      child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Container(
              width: 70,
              height: 70,
              margin: EdgeInsets.all(10),
              child: Image.asset(
                "assets/images/amainfoindex.png",
                fit: BoxFit.contain,
              ))));
}

Container _buildAboutHeaderText(
    AboutState state, Dispatch dispatch, ViewService viewService) {
  return Container(
    margin: const EdgeInsets.only(left: 10, top: 2),
    height: 90,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildAboutHeaderTitle(state, dispatch, viewService),
        _buildAboutHeaderVersion(state, dispatch, viewService),
      ],
    ),
  );
}

Expanded _buildAboutHeaderTitle(
    AboutState state, Dispatch dispatch, ViewService viewService) {
  return Expanded(
    child: Container(
      child: Text(
        GlobalStore.currentTopicDef.topicName,
        style: const TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

Expanded _buildAboutHeaderVersion(
    AboutState state, Dispatch dispatch, ViewService viewService) {
  return Expanded(
    child: Container(
      alignment: Alignment.bottomLeft,
      child: FutureBuilder(
          future: PackageInfo.fromPlatform(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              PackageInfo packageInfo = snapshot.data;
              return Text(
                '本地：${packageInfo.version}；最新：${GlobalStore.appConfig.latestVersion}',
                softWrap: true,
                style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).primaryColor == Color(0xff212121)
                        ? Colors.white
                        : Color.fromRGBO(141, 141, 141, 1.0)),
              );
            } else
              return Container();
          }),
    ),
  );
}

Expanded _buildAboutContentSection(
    AboutState state, Dispatch dispatch, ViewService viewService) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.only(top: 20, bottom: 0),
      child: _buildAboutContentCard(state, dispatch, viewService),
    ),
  );
}

Card _buildAboutContentCard(
    AboutState state, Dispatch dispatch, ViewService viewService) {
  return Card(
    elevation: 5,
    shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(10))),
    child: _buildAboutContentList(state, dispatch, viewService),
  );
}

Container _buildAboutContentList(
    AboutState state, Dispatch dispatch, ViewService viewService) {
  var descriptions = state.descriptions;
  return Container(
      margin: const EdgeInsets.only(left: 20, top: 15, right: 20),
      child: ListView(
          children: List.generate(descriptions.length + 1, (index) {
        if (index == 0) {
          return _buildAboutContentTitle(state, dispatch, viewService);
        } else {
          return _buildAboutContentItem(state, dispatch, viewService, index);
        }
      })));
}

Container _buildAboutContentTitle(
    AboutState state, Dispatch dispatch, ViewService viewService) {
  return Container(
    margin: const EdgeInsets.only(bottom: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          LinuxLocalizations.of(viewService.context).versionDescription,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        InkWell(
          child: Text(
            "✨${LinuxLocalizations.of(viewService.context).projectLink}✨",
            style: const TextStyle(color: Colors.blue),
          ),
          onTap: () {
            final String downloadUrl = GlobalStore.appConfig.downloadUrl;
            Tools.openUrl(downloadUrl);
          },
        )
      ],
    ),
  );
}

Container _buildAboutContentItem(
    AboutState state, Dispatch dispatch, ViewService viewService, int index) {
  var descriptions = state.descriptions;
  final data = descriptions[index - 1];
  return Container(
    margin: const EdgeInsets.only(right: 14),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(top: 7),
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color.fromRGBO(141, 141, 141, 1.0),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(data)),
      ],
    ),
  );
}
