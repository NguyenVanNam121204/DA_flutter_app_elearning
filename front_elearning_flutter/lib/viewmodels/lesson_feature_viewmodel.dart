import '../core/result/result.dart';
import 'api_data_viewmodel.dart';

class LessonFeatureViewModel {
  LessonFeatureViewModel(this._api);

  final ApiDataViewModel _api;

  Future<Result<Map<String, dynamic>>> courseDetail(String courseId) async {
    final res = await _api.get('/api/user/courses/$courseId');
    return _mapResult(res, (raw) => _asMap(raw));
  }

  Future<Result<List<Map<String, dynamic>>>> searchCourses(String keyword) async {
    final res = await _api.get('/api/user/courses/search', query: {'keyword': keyword});
    return _mapResult(res, (raw) => _asList(raw));
  }

  Future<Result<List<Map<String, dynamic>>>> lessonsByCourse(String courseId) async {
    final res = await _api.get('/api/user/lessons/course/$courseId');
    return _mapResult(res, (raw) => _asList(raw));
  }

  Future<Result<Map<String, dynamic>>> lessonDetailBundle(String lessonId) async {
    final lesson = await _api.get('/api/user/lessons/$lessonId');
    if (lesson case Failure(:final error)) return Failure(error);
    final modules = await _api.get('/api/user/modules/lesson/$lessonId');
    if (modules case Failure(:final error)) return Failure(error);
    return Success({
      'lesson': _asMap((lesson as Success<dynamic>).value),
      'modules': _asList((modules as Success<dynamic>).value),
    });
  }

  Future<Result<List<Map<String, dynamic>>>> moduleLectures(String moduleId) async {
    final res = await _api.get('/api/user/lectures/module/$moduleId');
    return _mapResult(res, (raw) => _asList(raw));
  }

  Future<Result<Map<String, dynamic>>> lectureDetail(String lectureId) async {
    final res = await _api.get('/api/user/lectures/$lectureId');
    return _mapResult(res, (raw) => _asMap(raw));
  }

  Future<Result<List<Map<String, dynamic>>>> pronunciationList(String moduleId) async {
    final res = await _api.get('/api/user/pronunciations/$moduleId');
    return _mapResult(res, (raw) => _asList(raw));
  }

  Future<Result<Map<String, dynamic>>> pronunciationDetail(String pronunciationId) async {
    final res = await _api.get('/api/user/pronunciations/$pronunciationId');
    return _mapResult(res, (raw) => _asMap(raw));
  }

  Future<Result<Map<String, dynamic>>> lessonResult(String attemptId) async {
    final res = await _api.get('/api/user/quiz-attempts/$attemptId/result');
    return _mapResult(res, (raw) => _asMap(raw));
  }

  Future<Result<T>> _mapResult<T>(
    Result<dynamic> result,
    T Function(dynamic raw) mapper,
  ) async {
    return switch (result) {
      Success(:final value) => Success(mapper(value)),
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

  List<Map<String, dynamic>> _asList(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final data = raw['data'] ?? raw['Data'] ?? raw['items'] ?? raw['Items'];
      if (data is List) return data.whereType<Map<String, dynamic>>().toList();
    } else if (raw is List) {
      return raw.whereType<Map<String, dynamic>>().toList();
    }
    return const [];
  }
}

