import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/errors/app_error.dart';
import '../../core/result/result.dart';
import '../../models/assignment/assignment_models.dart';
import '../../services/api_service.dart';

class AssignmentRepository {
  AssignmentRepository(this._apiService);

  final ApiService _apiService;

  Future<Result<AssignmentDetailModel>> assignmentDetail({
    required String assessmentId,
    required String moduleId,
  }) async {
    final path = assessmentId.isNotEmpty
        ? ApiConstants.userAssessmentDetail(assessmentId)
        : ApiConstants.userAssessmentsByModule(moduleId);

    try {
      final response = await _apiService.get(path);
      return Success(AssignmentDetailModel.fromJson(_asMap(response.data)));
    } on DioException catch (error) {
      return Failure(_mapDioException(error));
    } catch (_) {
      return const Failure(
        AppError(message: 'Unable to load assignment detail.'),
      );
    }
  }

  Future<Result<EssayDetailModel>> essayDetail(String essayId) async {
    try {
      final response = await _apiService.get(
        ApiConstants.userEssayDetail(essayId),
      );
      return Success(EssayDetailModel.fromJson(_asMap(response.data)));
    } on DioException catch (error) {
      return Failure(_mapDioException(error));
    } catch (_) {
      return const Failure(AppError(message: 'Unable to load essay detail.'));
    }
  }

  Future<Result<void>> submitEssay({
    required String essayId,
    required String content,
  }) async {
    try {
      await _apiService.post(
        ApiConstants.userEssaySubmissions,
        data: {'essayId': essayId, 'content': content},
      );
      return const Success(null);
    } on DioException catch (error) {
      return Failure(_mapDioException(error));
    } catch (_) {
      return const Failure(AppError(message: 'Unable to submit essay.'));
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
