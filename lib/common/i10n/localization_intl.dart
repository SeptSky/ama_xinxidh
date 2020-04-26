import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'messages_all.dart';

class LinuxLocalizations {
  static Future<LinuxLocalizations> load(Locale locale) {
    final String name =
        locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);
    print("name是：$localeName");
    return initializeMessages(localeName).then((b) {
      Intl.defaultLocale = localeName;
      return new LinuxLocalizations();
    });
  }

  static LinuxLocalizations of(BuildContext context) {
    return Localizations.of<LinuxLocalizations>(context, LinuxLocalizations);
  }

  String get appName => Intl.message(
        "Linux Resouces Navigation",
        name: "appName",
        desc: "app的名字",
      );

  String get pressBackAgain => Intl.message(
        'Press back again to exit',
        name: 'pressBackAgain',
        desc: '再按一次退出',
      );

  String get characterIndex => Intl.message(
        'Character Index',
        name: 'characterIndex',
        desc: '特征组合检索',
      );

  String get changeTheme {
    return Intl.message(
      'Change Theme',
      name: 'changeTheme',
      desc: '切换主题',
    );
  }
  String get aboutApp {
    return Intl.message(
      'About',
      name: 'aboutApp',
      desc: '关于',
    );
  }

  String get versionDescription => Intl.message(
        'Version Description',
        name: 'versionDescription',
        desc: '版本描述',
      );
  String get projectLink => Intl.message(
        'Project Link',
        name: 'projectLink',
        desc: '下载地址',
      );
  String get myGithub => Intl.message(
        'Author\'s Github',
        name: 'myGithub',
        desc: '作者的github',
      );
  String get checkUpdate {
    return Intl.message(
      'Check Update',
      name: 'checkUpdate',
      desc: '检查更新',
    );
  }

  String get pink {
    return Intl.message(
      'pink',
      name: 'pink',
      desc: '主题颜色',
    );
  }

  String get coffee {
    return Intl.message(
      'coffee',
      name: 'coffee',
      desc: '主题颜色',
    );
  }

  String get cyan {
    return Intl.message(
      'cyan',
      name: 'cyan',
      desc: '主题颜色',
    );
  }

  String get green {
    return Intl.message(
      'green',
      name: 'green',
      desc: '主题颜色',
    );
  }

  String get purple {
    return Intl.message(
      'purple',
      name: 'purple',
      desc: '主题颜色',
    );
  }

  String get dark {
    return Intl.message(
      'dark',
      name: 'dark',
      desc: '主题颜色',
    );
  }

  String get blueGray {
    return Intl.message(
      'blue-gray',
      name: 'blueGray',
      desc: '主题颜色',
    );
  }

  String get version120 => Intl.message(
        'Version:1.2.0 \n\n'
        'The Version 1.2.0 released!\n',
        name: 'version120',
        desc: '版本:1.2.0 \n\n',
      );
}

//Locale代理类
class LinuxLocalizationsDelegate
    extends LocalizationsDelegate<LinuxLocalizations> {
  const LinuxLocalizationsDelegate();

  //是否支持某个Local
  @override
  bool isSupported(Locale locale) => ['en', 'zh'].contains(locale.languageCode);

  // Flutter会调用此类加载相应的Locale资源类
  @override
  Future<LinuxLocalizations> load(Locale locale) {
    //3
    return LinuxLocalizations.load(locale);
  }

  // 当Localizations Widget重新build时，是否调用load重新加载Locale资源.
  @override
  bool shouldReload(LinuxLocalizationsDelegate old) => false;
}
