import 'package:core/core.dart';

final GetIt appLocator = GetIt.instance;

const String unauthScope = 'unauthScope';
const String authScope = 'authScope';

abstract class AppDI {
  static void initDependencies(GetIt locator, Flavor flavor) {
    locator.registerSingleton<AppConfig>(
      AppConfig.fromFlavor(flavor),
    );

    locator.registerLazySingleton<AppEvenBus>(
      () => AppEvenBus(),
    );

    locator.registerLazySingleton<AppEventNotifier>(
      () => appLocator<AppEvenBus>(),
    );

    locator.registerLazySingleton<AppEventObserver>(
      () => appLocator<AppEvenBus>(),
    );
  }
}
