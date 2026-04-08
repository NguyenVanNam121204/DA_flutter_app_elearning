import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/errors/app_error.dart';
import '../../core/result/result.dart';
import '../../models/quiz/quiz_models.dart';
import '../../services/api_service.dart';

class QuizRepository {
  QuizRepository(this._apiService);

  final ApiService _apiService;

  Future<Result<QuizDetailModel>> quizById(String quizId) async {
    try {
      final response = await _apiService.get(ApiConstants.quizById(quizId));
      return Success(QuizDetailModel.fromJson(_asMap(response.data)));
    } on DioException catch (error) {
      return Failure(_mapDioException(error));
    } catch (_) {
      return const Failure(AppError(message: 'Unable to load quiz.'));
    }
  }

  Future<Result<QuizAttemptStartModel>> startAttempt(String? quizId) async {
    if ((quizId ?? '').isEmpty) {
      return const Failure(AppError(message: 'Quiz ID is required.'));
    }

    try {
      final response = await _apiService.post(
        ApiConstants.quizStartAttemptByQuizId(quizId!),
      );
      return Success(QuizAttemptStartModel.fromJson(_asMap(response.data)));
    } on DioException catch (_) {
      try {
        final fallbackResponse = await _apiService.post(
          ApiConstants.quizStartAttempt,
          data: {'quizId': quizId},
        );
        return Success(
          QuizAttemptStartModel.fromJson(_asMap(fallbackResponse.data)),
        );
      } on DioException catch (error) {
        return Failure(_mapDioException(error));
      } catch (_) {
        return const Failure(
          AppError(message: 'Unable to start quiz attempt.'),
        );
      }
    } catch (_) {
      return const Failure(AppError(message: 'Unable to start quiz attempt.'));
    }
  }

  Future<Result<void>> submitAttempt({
    required String attemptId,
    required List<Map<String, Object?>> answers,
  }) async {
    try {
      await _apiService.post(
        ApiConstants.quizSubmitAttempt(attemptId),
        data: {'answers': answers},
      );
      return const Success(null);
    } on DioException catch (error) {
      return Failure(_mapDioException(error));
    } catch (_) {
      return const Failure(AppError(message: 'Unable to submit quiz attempt.'));
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
