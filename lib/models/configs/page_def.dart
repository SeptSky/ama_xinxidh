import 'package:flutter/material.dart';

import '../../common/consts/page_names.dart';

class PageDef {
  PageDef(this.pageName, this.title, this.icon);

  String pageName;
  String title;
  IconData icon;
}

List<PageDef> tabPageDefs = [
  PageDef(PageNames.infoNavPage, '导航', Icons.navigation),
  PageDef(PageNames.infoNavPage, '互动', Icons.message),
  // PageDef(PageNames.infoNavPage, '收藏', Icons.favorite),
  PageDef(PageNames.menuPage, '功能', Icons.person),
];
