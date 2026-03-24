import 'package:dio/dio.dart';

import '../app/config/app_config.dart';

class ApiService {
  ApiService(this._dio);

  final Dio _dio;

  String get baseUrl => AppConfig.apiBaseUrl;

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response<dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.post(path, data: data, queryParameters: queryParameters);
  }
}
