import 'dart:io';

import 'package:core/core.dart';

import '../../../../../data.dart';

class ApiProvider {
  final Dio _dio;
  final ErrorHandler _errorHandler;

  final String _listResultField;

  const ApiProvider({
    required Dio dio,
    required ErrorHandler errorHandler,
    required String listResultField,
  })  : _dio = dio,
        _errorHandler = errorHandler,
        _listResultField = listResultField;

  Future<T> object<T>({
    required ApiRequest request,
    required T Function(Map<String, dynamic> data) parser,
    ApiRequestOptions options = const ApiRequestOptions(),
  }) async {
    final dynamic data = await _request(
      request: request,
      options: options,
    );

    return parser(data);
  }

  Future<List<T>> list<T>({
    required ApiRequest request,
    required T Function(Map<String, dynamic> data) parser,
    ApiRequestOptions options = const ApiRequestOptions(),
    String? listResultField,
  }) async {
    final dynamic data = await _request(
      request: request,
      options: options,
    );

    final String dataField = listResultField ?? _listResultField;
    final List<dynamic> list = data is List ? data : data[dataField];
    return list.map((dynamic e) => parser(e as Map<String, dynamic>)).cast<T>().toList();
  }

  Future<T> raw<T>({
    required ApiRequest request,
    ApiRequestOptions options = const ApiRequestOptions(),
  }) async {
    final dynamic data = await _request(
      request: request,
      options: options,
    );

    return data;
  }

  Future<void> none({
    required ApiRequest request,
    ApiRequestOptions options = const ApiRequestOptions(),
  }) async {
    await _request(
      request: request,
      options: options,
    );
  }

  Future<dynamic> _request({
    required ApiRequest request,
    required ApiRequestOptions options,
    bool didRefreshTokens = false,
  }) async {
    try {
      Map<String, dynamic>? headers = request.headers;

      if (options.useDefaultAuth) {
        headers ??= <String, dynamic>{};
        // TODO: Apply auth headers
      }

      final Response<dynamic> response = await _dio.request(
        request.url,
        data: request.body,
        queryParameters: request.params,
        options: Options(
          method: request.method.key,
          headers: headers,
        ),
      );

      return response.data;
    } on DioException catch (e) {
      final bool unauthorized = e.response?.statusCode == HttpStatus.unauthorized;
      final bool canRefresh = options.useDefaultAuth && !didRefreshTokens;

      if (unauthorized && canRefresh) {
        // TODO: Refresh tokens
      }

      if (options.useErrorHandler) {
        await _errorHandler.handleError(e);
      } else {
        throw AppException(message: e.toString());
      }
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }
}
