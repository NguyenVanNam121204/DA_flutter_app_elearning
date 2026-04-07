import '../core/result/result.dart';
import 'api_data_viewmodel.dart';

class TeacherFeatureViewModel {
  TeacherFeatureViewModel(this._api);

  final ApiDataViewModel _api;

  Future<Result<List<Map<String, dynamic>>>> myCourses() async {
    final res = await _api.get('/api/teacher/courses/my-courses');
    return _toList(res);
  }

  Future<Result<Map<String, dynamic>>> courseDetail(String courseId) async {
    final res = await _api.get('/api/teacher/courses/$courseId');
    return _toMap(res);
  }

  Future<Result<List<Map<String, dynamic>>>> classStudents(String courseId) async {
    final res = await _api.get('/api/teacher/courses/$courseId/students');
    return _toList(res);
  }

  Future<Result<void>> createCourse(Map<String, dynamic> body) async {
    final res = await _api.post('/api/teacher/courses', body: body);
    return switch (res) {
      Success() => const Success(null),
      Failure(:final error) => Failure(error),
    };
  }

  Future<Result<List<Map<String, dynamic>>>> essaySubmissions(String essayId) async {
    final res = await _api.get('/api/teacher/essay-submissions/essay/$essayId', query: {'pageNumber': 1, 'pageSize': 20});
    return _toList(res, paged: true);
  }

  Future<Result<List<Map<String, dynamic>>>> quizAttempts(String quizId) async {
    final res = await _api.get('/api/teacher/quiz-attempts/quiz/$quizId/paged', query: {'pageNumber': 1, 'pageSize': 20});
    return _toList(res, paged: true);
  }

  Future<Result<Map<String, dynamic>>> quizAttemptDetail(String attemptId) async {
    final res = await _api.get('/api/teacher/quiz-attempts/$attemptId/review');
    return _toMap(res);
  }

  Future<Result<Map<String, dynamic>>> submissionDetail(String submissionId) async {
    final res = await _api.get('/api/teacher/essay-submissions/$submissionId');
    return _toMap(res);
  }

  Future<Result<Map<String, dynamic>>> _toMap(Result<dynamic> res) async {
    return switch (res) {
      Success(:final value) => Success(_asMap(value)),
      Failure(:final error) => Failure(error),
    };
  }

  Future<Result<List<Map<String, dynamic>>>> _toList(
    Result<dynamic> res, {
    bool paged = false,
  }) async {
    return switch (res) {
      Success(:final value) => Success(_asList(value, paged: paged)),
      Failure(:final error) => Failure(error),
    };
  }

  Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final data = raw['data'] ?? raw['Data'] ?? raw;
      if (data is Map<String, dynamic>) return data;
      return raw;
    }
    return const {};
  }

  List<Map<String, dynamic>> _asList(dynamic raw, {bool paged = false}) {
    if (raw is Map<String, dynamic>) {
      var data = raw['data'] ?? raw['Data'];
      if (paged && data is Map<String, dynamic>) {
        data = data['items'] ?? data['Items'];
      }
      if (data is List) return data.whereType<Map<String, dynamic>>().toList();
    }
    return const [];
  }
}

