import 'package:core/core.dart';

import '../../data.dart';

abstract class DataDI {
  static void initDependencies(GetIt locator) {
    _initApi(locator);
    _initProviders(locator);
    _initRepositories(locator);
  }

  static void _initApi(GetIt locator) {
    locator.registerLazySingleton<DioConfig>(
      () => DioConfig(
        appConfig: locator<AppConfig>(),
      ),
    );

    locator.registerLazySingleton<ErrorHandler>(
      ErrorHandler.new,
    );

    locator.registerLazySingleton<LocalDataProvider>(
      LocalDataProvider.new,
    );

    locator.registerLazySingleton<ApiTokenProvider>(
      () => ApiTokenProvider(
        localDataProvider: locator<LocalDataProvider>(),
      ),
    );

    locator.registerLazySingleton<ApiProvider>(
      () => ApiProvider(
        dio: locator<DioConfig>().dio,
        errorHandler: locator<ErrorHandler>(),
        apiTokenProvider: locator<ApiTokenProvider>(),
      ),
    );
  }

  static void _initProviders(GetIt locator) {}

  static void _initRepositories(GetIt locator) {}
}
