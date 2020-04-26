import 'package:fish_redux/fish_redux.dart';

import '../../common/i10n/localization_intl.dart';
import 'about_action.dart';
import 'about_state.dart';

Effect<AboutState> buildEffect() {
  return combineEffects(<Object, Effect<AboutState>>{
    Lifecycle.initState: _init,
  });
}

void _init(Action action, Context<AboutState> ctx) {
  List<String> descriptions = [];

  /// 不使用Future.Delayed方法将会抛出异常，通过Delayed可以跳过首次执行顺序
  Future.delayed(Duration.zero, () {
    // descriptions.add(LinuxLocalizations.of(ctx.context).version110);
    // descriptions.add(LinuxLocalizations.of(ctx.context).version109);
    // descriptions.add(LinuxLocalizations.of(ctx.context).version108);
    // descriptions.add(LinuxLocalizations.of(ctx.context).version107);
    // descriptions.add(LinuxLocalizations.of(ctx.context).version106);
    // descriptions.add(LinuxLocalizations.of(ctx.context).version105);
    // descriptions.add(LinuxLocalizations.of(ctx.context).version104);
    // descriptions.add(LinuxLocalizations.of(ctx.context).version103);
    // descriptions.add(LinuxLocalizations.of(ctx.context).version102);
    // descriptions.add(LinuxLocalizations.of(ctx.context).version101);
    descriptions.add(LinuxLocalizations.of(ctx.context).version120);
    ctx.dispatch(AboutReducerCreator.initAboutReducer(descriptions));
  });
}
