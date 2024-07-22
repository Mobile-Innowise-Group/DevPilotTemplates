import 'dart:io';

import 'package:core/core.dart';
import 'package:domain/domain.dart';

import '../../../data.dart';

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

  Future<T> request<T>({
    required ApiQuery query,
    required T Function(Map<String, dynamic> data) parser,
  }) async {
    return _request(
      query: query,
      parser: parser,
      canRefreshToken: query.useDefaultAuth,
    );
  }

  Future<List<T>> listRequest<T>({
    required ApiQuery query,
    required T Function(dynamic data) itemParser,
    String listResponseField = ApiConstants.listResponseField,
  }) async {
    return _request(
      query: query,
      parser: (Map<String, dynamic> data) {
        return data[listResponseField].map(itemParser).cast<T>().toList();
      },
      canRefreshToken: query.useDefaultAuth,
    );
  }

  Future<void> voidRequest(ApiQuery query) async {
    await _request(
      query: query,
      parser: (_) {},
      canRefreshToken: query.useDefaultAuth,
    );
  }

  Future<T> _request<T>({
    required ApiQuery query,
    required T Function(Map<String, dynamic> data) parser,
    required bool canRefreshToken,
  }) async {
    try {
      final Response<dynamic> response = await _dio.request(
        query.url,
        data: query.body,
        options: Options(
          method: query.method.key,
          headers: await _prepareRequestHeaders(query),
        ),
      );

      return parser(response.data);
    } on DioException catch (e) {
      if (canRefreshToken && e.response?.statusCode == HttpStatus.unauthorized) {
        await _refreshTokens();
        return _request(
          query: query,
          parser: parser,
          canRefreshToken: false,
        );
      } else {
        if (query.useErrorHandler) {
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

  Future<Map<String, dynamic>?> _prepareRequestHeaders(ApiQuery query) async {
    if (query.useDefaultAuth) {
      final Map<String, dynamic> headers = query.headers ?? <String, dynamic>{};
      final String? token = await _apiTokenProvider.readAccessToken();

      if (token != null) {
        // TODO: Set token properly
        headers['Authorization'] = token;
      }
    }

    return query.headers;
  }

  Future<void> _refreshTokens() async {
    // TODO: Refresh tokens
  }
}
