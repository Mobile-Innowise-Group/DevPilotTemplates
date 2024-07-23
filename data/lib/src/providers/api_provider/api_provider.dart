import 'dart:io';

import 'package:core/core.dart';
import 'package:domain/domain.dart';

import '../../../data.dart';

typedef ApiObjectParser<T> = T Function(Map<String, dynamic> data);

typedef ApiRawParser<T> = T Function(dynamic data);

class ApiProvider {
  final Dio _dio;
  final ApiTokenProvider _apiTokenProvider;
  final ErrorHandler _errorHandler;

  ApiProvider({
    required Dio dio,
    required ApiTokenProvider apiTokenProvider,
    required ErrorHandler errorHandler,
  })  : _dio = dio,
        _apiTokenProvider = apiTokenProvider,
        _errorHandler = errorHandler;

  Future<T> expectObject<T>({
    required ApiRequest request,
    required ApiObjectParser<T> parser,
  }) async {
    final dynamic data = await _request(
      request: request,
      canRefreshToken: request.useDefaultAuth,
    );

    return parser(data as Map<String, dynamic>);
  }

  Future<List<T>> expectList<T>({
    required ApiRequest request,
    required ApiObjectParser<T> itemParser,
    String listResponseField = ApiConstants.listResponseField,
  }) async {
    final dynamic data = await _request(
      request: request,
      canRefreshToken: request.useDefaultAuth,
    );

    final List<dynamic> items = data is List ? data : data[listResponseField];
    return items.map((dynamic e) => itemParser(e as Map<String, dynamic>)).cast<T>().toList();
  }

  Future<void> expectVoid(ApiRequest request) async {
    await _request(
      request: request,
      canRefreshToken: request.useDefaultAuth,
    );
  }

  Future<T> expectRaw<T>({
    required ApiRequest request,
    required ApiRawParser<T> parser,
  }) async {
    final dynamic data = await _request(
      request: request,
      canRefreshToken: request.useDefaultAuth,
    );

    return parser(data);
  }

  Future<dynamic> _request({
    required ApiRequest request,
    required bool canRefreshToken,
  }) async {
    try {
      final Response<dynamic> response = await _dio.request(
        request.url,
        data: request.body,
        options: Options(
          method: request.method.key,
          headers: await _prepareRequestHeaders(request),
        ),
      );

      return response.data;
    } on DioException catch (e) {
      if (canRefreshToken && e.response?.statusCode == HttpStatus.unauthorized) {
        await _refreshTokens();
        return _request(
          request: request,
          canRefreshToken: false,
        );
      } else {
        if (request.useErrorHandler) {
          await _errorHandler.handleError(e);
        } else {
          throw AppException(e.message ?? e.toString());
        }
      }
    } on AppException catch (_) {
      rethrow;
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  Future<Map<String, dynamic>?> _prepareRequestHeaders(ApiRequest request) async {
    if (request.useDefaultAuth) {
      final Map<String, dynamic> headers = request.headers ?? <String, dynamic>{};
      final String? token = await _apiTokenProvider.readAccessToken();

      if (token != null) {
        // TODO: Set token properly
        headers['Authorization'] = 'Bearer $token';
      }

      return headers;
    }

    return request.headers;
  }

  Future<void> _refreshTokens() async {
    // TODO: Refresh tokens
  }
}
