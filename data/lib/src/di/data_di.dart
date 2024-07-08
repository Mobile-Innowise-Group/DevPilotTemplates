import 'package:core/core.dart';

import '../../data.dart';

final DataDI dataDI = DataDI();

class DataDI {
  void initDependencies() {
    _initDio();
    _initApi();
  }

  void _initDio() {
    appLocator.registerLazySingleton<DioConfig>(
      () => DioConfig(
        appConfig: appLocator<AppConfig>(),
      ),
    );
  }

  void _initApi() {
    appLocator.registerLazySingleton<ErrorHandler>(
      ErrorHandler.new,
    );

    appLocator.registerLazySingleton<ApiProvider>(
      () => ApiProvider(
        appLocator<DioConfig>().dio,
      ),
    );
  }
}
