part of '../dio_config.dart';

class ErrorInterceptor extends Interceptor {
  final Dio dio;

  ErrorInterceptor(this.dio);

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    return handler.resolve(
      err.response ?? Response<dynamic>(requestOptions: err.requestOptions),
    );
  }
}
