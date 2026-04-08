import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/errors/app_error.dart';
import '../../core/result/result.dart';
import '../../models/learning/lecture_models.dart';
import '../../services/api_service.dart';

class LectureRepository {
  LectureRepository(this._apiService);

  final ApiService _apiService;

  Future<Result<List<LectureListItemModel>>> moduleLectures(
    String moduleId,
  ) async {
    try {
      final response = await _apiService.get(
        ApiConstants.userLecturesByModule(moduleId),
      );
      return Success(
        _asList(response.data).map(LectureListItemModel.fromJson).toList(),
      );
    } on DioException catch (error) {
      return Failure(_mapDioException(error));
    } catch (_) {
      return const Failure(AppError(message: 'Unable to load lectures.'));
    }
  }

  Future<Result<LectureDetailModel>> lectureDetail(String lectureId) async {
    try {
      final response = await _apiService.get(
        ApiConstants.userLectureDetail(lectureId),
      );
      return Success(LectureDetailModel.fromJson(_asMap(response.data)));
    } on DioException catch (error) {
      return Failure(_mapDioException(error));
    } catch (_) {
      return const Failure(AppError(message: 'Unable to load lecture detail.'));
    }
  }

  Map<String, dynamic> _asMap(Object? raw) {
    if (raw is Map<String, dynamic>) {
      final data = raw['data'] ?? raw['Data'] ?? raw;
      if (data is Map<String, dynamic>) return data;
      return raw;
    }
    return const {};
  }

  List<Map<String, dynamic>> _asList(Object? raw) {
    if (raw is Map<String, dynamic>) {
      final data = raw['data'] ?? raw['Data'] ?? raw['items'] ?? raw['Items'];
      if (data is List) return data.whereType<Map<String, dynamic>>().toList();
    } else if (raw is List) {
      return raw.whereType<Map<String, dynamic>>().toList();
    }
    return const [];
  }

  AppError _mapDioException(DioException error) {
    final responseData = error.response?.data;
    final message = responseData is Map<String, dynamic>
        ? (responseData['message'] ??
                  responseData['Message'] ??
                  'Unable to connect to server')
              .toString()
        : 'Unable to connect to server';
    return AppError(message: message, statusCode: error.response?.statusCode);
  }
}
