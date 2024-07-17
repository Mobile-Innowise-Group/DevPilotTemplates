import 'package:dio/dio.dart';

class ApiProvider {
  final Dio _dio;

  const ApiProvider(Dio dio) : _dio = dio;
}
