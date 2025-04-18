locator.registerLazySingleton<WebSocketApiProvider>(
() => WebSocketApiProvider(
baseUrl: locator<AppConfig>().webSocketBaseUrl,
),
);