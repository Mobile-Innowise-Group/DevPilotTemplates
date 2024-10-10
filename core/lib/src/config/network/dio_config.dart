import 'package:dio/dio.dart';

import '../app_config.dart';
import 'interceptors/log_interceptor.dart';

class DioConfig {
  final AppConfig appConfig;

  final Dio _dio = Dio();

  Dio get dio => _dio;

  DioConfig({required this.appConfig}) {
    _dio
      ..options.baseUrl = appConfig.baseUrl
      ..interceptors.addAll(
        <Interceptor>[
          const AppLogInterceptor(),
        ],
      );
  }
}
