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

locator.registerLazySingleton<ApiProvider>(
() => ApiProvider(
dio: locator<DioConfig>().dio,
errorHandler: locator<ErrorHandler>(),
listResultField: ApiConstants.listResponseField,
),
);
