enum HttpMethod {
  get('GET'),
  post('POST'),
  put('PUT'),
  delete('DELETE'),
  patch('PATCH'),
  head('HEAD');

  final String key;

  const HttpMethod(this.key);
}

typedef ApiResponseBodyParser<T> = T Function(Map<String, dynamic>);

class ApiQuery {
  final HttpMethod method;
  final String url;
  final Map<String, dynamic>? params;
  final Object? body;
  final Map<String, dynamic>? headers;
  final bool useDefaultAuth;
  final bool useErrorHandler;

  ApiQuery({
    required this.method,
    required this.url,
    this.body = const <String, dynamic>{},
    this.params,
    this.headers,
    this.useDefaultAuth = true,
    this.useErrorHandler = true,
  });
}
