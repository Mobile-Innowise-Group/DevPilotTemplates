import 'package:core/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data.dart';

final class DataDI {
  static Future<void> initDependencies(GetIt locator) async {
    await _initApi(locator);
    _initProviders(locator);
    _initRepositories(locator);
  }

  static Future<void> _initApi(GetIt locator) async {
    locator.registerLazySingleton<DioConfig>(
      () => DioConfig(
        appConfig: locator<AppConfig>(),
      ),
    );

    locator.registerLazySingleton<ErrorHandler>(
      () => ErrorHandler(
        eventNotifier: locator<AppEventNotifier>(),
      ),
    );

    final SharedPreferences instance = await SharedPreferences.getInstance();
    locator.registerSingleton<LocalDataProvider>(
      LocalDataProvider(prefs: instance),
    );

    locator.registerLazySingleton<ApiProvider>(
      () => ApiProvider(
        dio: locator<DioConfig>().dio,
        errorHandler: locator<ErrorHandler>(),
        listResultField: ApiConstants.listResponseField,
      ),
    );

    locator.registerLazySingleton<WebSocketApiProvider>(
      () => WebSocketApiProvider(
        baseUrl: locator<AppConfig>().webSocketBaseUrl,
      ),
    );
  }

  static void _initProviders(GetIt locator) {}

  static void _initRepositories(GetIt locator) {}
}
