import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/errors/app_error.dart';
import '../../core/result/result.dart';
import '../../models/teacher/teacher_course_models.dart';
import '../../models/teacher/teacher_quiz_attempt_models.dart';
import '../../models/teacher/teacher_submission_models.dart';
import '../../services/api_service.dart';

class TeacherRepository {
  TeacherRepository(this._apiService);

  final ApiService _apiService;

  Future<Result<List<TeacherCourseModel>>> myCourses() async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.teacherCourses}/my-courses',
      );
      return Success(
        _asList(response.data, mapper: TeacherCourseModel.fromJson),
      );
    } on DioException catch (error) {
      return Failure(_mapDioException(error));
    } catch (_) {
      return const Failure(
        AppError(message: 'Unable to load teacher courses.'),
      );
    }
  }

  Future<Result<TeacherCourseModel>> courseDetail(String courseId) async {
    try {
      final response = await _apiService.get(
        ApiConstants.teacherCourseDetail(courseId),
      );
      return Success(TeacherCourseModel.fromJson(_asMap(response.data)));
    } on DioException catch (error) {
      return Failure(_mapDioException(error));
    } catch (_) {
      return const Failure(AppError(message: 'Unable to load course detail.'));
    }
  }

  Future<Result<List<TeacherClassStudentModel>>> classStudents(
    String courseId,
  ) async {
    try {
      final response = await _apiService.get(
        ApiConstants.teacherCourseStudents(courseId),
      );
      return Success(
        _asList(response.data, mapper: TeacherClassStudentModel.fromJson),
      );
    } on DioException catch (error) {
      return Failure(_mapDioException(error));
    } catch (_) {
      return const Failure(AppError(message: 'Unable to load class students.'));
    }
  }

  Future<Result<void>> createCourse(Map<String, dynamic> body) async {
    try {
      await _apiService.post(ApiConstants.teacherCourses, data: body);
      return const Success(null);
    } on DioException catch (error) {
      return Failure(_mapDioException(error));
    } catch (_) {
      return const Failure(AppError(message: 'Unable to create course.'));
    }
  }

  Future<Result<TeacherLessonDetailModel>> lessonDetail(String lessonId) async {
    try {
      final response = await _apiService.get(
        ApiConstants.teacherLessonDetail(lessonId),
      );
      return Success(TeacherLessonDetailModel.fromJson(_asMap(response.data)));
    } on DioException catch (error) {
      return Failure(_mapDioException(error));
    } catch (_) {
      return const Failure(AppError(message: 'Unable to load lesson detail.'));
    }
  }

  Future<Result<List<TeacherSubmissionListItemModel>>> essaySubmissions(
    String essayId,
  ) async {
    try {
      final response = await _apiService.get(
        ApiConstants.teacherEssaySubmissionsByEssay(essayId),
        queryParameters: {'pageNumber': 1, 'pageSize': 20},
      );
      return Success(
        _asList(
          response.data,
          paged: true,
          mapper: TeacherSubmissionListItemModel.fromJson,
        ),
      );
    } on DioException catch (error) {
      return Failure(_mapDioException(error));
    } catch (_) {
      return const Failure(
        AppError(message: 'Unable to load essay submissions.'),
      );
    }
  }

  Future<Result<List<TeacherQuizAttemptListItemModel>>> quizAttempts(
    String quizId,
  ) async {
    try {
      final response = await _apiService.get(
        ApiConstants.teacherQuizAttemptsByQuiz(quizId),
        queryParameters: {'pageNumber': 1, 'pageSize': 20},
      );
      return Success(
        _asList(
          response.data,
          paged: true,
          mapper: TeacherQuizAttemptListItemModel.fromJson,
        ),
      );
    } on DioException catch (error) {
      return Failure(_mapDioException(error));
    } catch (_) {
      return const Failure(AppError(message: 'Unable to load quiz attempts.'));
    }
  }

  Future<Result<TeacherQuizAttemptDetailModel>> quizAttemptDetail(
    String attemptId,
  ) async {
    try {
      final response = await _apiService.get(
        ApiConstants.teacherQuizAttemptDetail(attemptId),
      );
      return Success(
        TeacherQuizAttemptDetailModel.fromJson(_asMap(response.data)),
      );
    } on DioException catch (error) {
      return Failure(_mapDioException(error));
    } catch (_) {
      return const Failure(
        AppError(message: 'Unable to load quiz attempt detail.'),
      );
    }
  }

  Future<Result<TeacherSubmissionDetailModel>> submissionDetail(
    String submissionId,
  ) async {
    try {
      final response = await _apiService.get(
        ApiConstants.teacherSubmissionDetail(submissionId),
      );
      return Success(
        TeacherSubmissionDetailModel.fromJson(_asMap(response.data)),
      );
    } on DioException catch (error) {
      return Failure(_mapDioException(error));
    } catch (_) {
      return const Failure(
        AppError(message: 'Unable to load submission detail.'),
      );
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

  List<T> _asList<T>(
    Object? raw, {
    bool paged = false,
    required T Function(Map<String, dynamic>) mapper,
  }) {
    if (raw is Map<String, dynamic>) {
      var data = raw['data'] ?? raw['Data'];
      if (paged && data is Map<String, dynamic>) {
        data = data['items'] ?? data['Items'];
      }
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().map(mapper).toList();
      }
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
