import 'package:dio/dio.dart';

import '../core/errors/app_error.dart';
import '../core/result/result.dart';
import '../services/api_service.dart';

class ApiDataRepository {
  ApiDataRepository(this._apiService);

  final ApiService _apiService;

  Future<Result<dynamic>> get(String path, {Map<String, dynamic>? query}) async {
    try {
      final response = await _apiService.get(path, queryParameters: query);
      return Success(response.data);
    } on DioException catch (error) {
      return Failure(_mapDioException(error));
    } catch (_) {
      return const Failure(AppError(message: 'Khong the tai du lieu.'));
    }
  }

  Future<Result<dynamic>> post(
    String path, {
    dynamic body,
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await _apiService.post(
        path,
        data: body,
        queryParameters: query,
      );
      return Success(response.data);
    } on DioException catch (error) {
      return Failure(_mapDioException(error));
    } catch (_) {
      return const Failure(AppError(message: 'Khong the gui du lieu.'));
    }
  }

  Future<Result<dynamic>> put(
    String path, {
    dynamic body,
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await _apiService.put(
        path,
        data: body,
        queryParameters: query,
      );
      return Success(response.data);
    } on DioException catch (error) {
      return Failure(_mapDioException(error));
    } catch (_) {
      return const Failure(AppError(message: 'Khong the cap nhat du lieu.'));
    }
  }

  AppError _mapDioException(DioException error) {
    final responseData = error.response?.data;
    final message = responseData is Map<String, dynamic>
        ? (responseData['message'] ??
                  responseData['Message'] ??
                  'Khong the ket noi den he thong')
              .toString()
        : 'Khong the ket noi den he thong';

    return AppError(message: message, statusCode: error.response?.statusCode);
  }
}
