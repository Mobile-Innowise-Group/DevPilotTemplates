import 'package:core/core.dart';

final GetIt appLocator = GetIt.instance;

const String unauthScope = 'unauthScope';
const String authScope = 'authScope';

abstract class AppDI {
  static void initDependencies(GetIt locator, Flavor flavor) {
    locator.registerSingleton<AppConfig>(
      AppConfig.fromFlavor(flavor),
    );

    locator.registerLazySingleton<AppEvenBusImpl>(
      () => AppEvenBusImpl(),
    );

    locator.registerLazySingleton<AppEventNotifier>(
      () => appLocator<AppEvenBusImpl>(),
    );

    locator.registerLazySingleton<AppEventObserver>(
      () => appLocator<AppEvenBusImpl>(),
    );
  }
}
