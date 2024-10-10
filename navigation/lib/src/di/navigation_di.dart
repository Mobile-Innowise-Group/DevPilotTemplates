import 'package:core/core.dart';

import '../app_router/app_router.dart';

final class NavigationDI {
  static void initDependencies(GetIt locator) {
    locator.registerSingleton(AppRouter());
  }
}
