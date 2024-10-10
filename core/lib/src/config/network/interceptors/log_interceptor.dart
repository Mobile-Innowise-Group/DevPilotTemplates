import 'package:dio/dio.dart';

import '../../../logger/logger.dart';

class AppLogInterceptor extends Interceptor {
  const AppLogInterceptor();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final String headers = options.headers.entries
        .map((MapEntry<String, dynamic> entry) => '${entry.key}: ${entry.value}')
        .join('\n');

    AppLogger().debug(
      'NETWORK REQUEST: ${options.method} ${options.uri}\n'
      'Query: ${options.data}\n'
      'Headers:\n$headers',
    );

    return handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    if (response.data != null || response.data != <dynamic>[]) {
      AppLogger().info(
        'NETWORK RESPONSE [code ${response.statusCode}]:\n'
        '🟢 ${response.data} 🟢',
      );
    }

    return handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    AppLogger().error(
      'NETWORK ERROR: ${err.error}: ${err.response}\n'
      'path=${err.requestOptions.path}',
    );

    return handler.next(err);
  }
}
