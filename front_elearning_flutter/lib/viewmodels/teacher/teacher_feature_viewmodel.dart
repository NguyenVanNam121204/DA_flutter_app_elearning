import '../../core/result/result.dart';
import '../../models/teacher/teacher_course_models.dart';
import '../../models/teacher/teacher_quiz_attempt_models.dart';
import '../../models/teacher/teacher_submission_models.dart';
import '../../repositories/teacher/teacher_repository.dart';

class TeacherFeatureViewModel {
  TeacherFeatureViewModel(this._repository);

  final TeacherRepository _repository;

  Future<Result<List<TeacherCourseModel>>> myCourses() async {
    return _repository.myCourses();
  }

  Future<Result<TeacherCourseModel>> courseDetail(String courseId) async {
    return _repository.courseDetail(courseId);
  }

  Future<Result<List<TeacherClassStudentModel>>> classStudents(
    String courseId,
  ) async {
    return _repository.classStudents(courseId);
  }

  Future<Result<void>> createCourse(Map<String, dynamic> body) async {
    return _repository.createCourse(body);
  }

  Future<Result<TeacherLessonDetailModel>> lessonDetail(String lessonId) async {
    return _repository.lessonDetail(lessonId);
  }

  Future<Result<List<TeacherSubmissionListItemModel>>> essaySubmissions(
    String essayId,
  ) async {
    return _repository.essaySubmissions(essayId);
  }

  Future<Result<List<TeacherQuizAttemptListItemModel>>> quizAttempts(
    String quizId,
  ) async {
    return _repository.quizAttempts(quizId);
  }

  Future<Result<TeacherQuizAttemptDetailModel>> quizAttemptDetail(
    String attemptId,
  ) async {
    return _repository.quizAttemptDetail(attemptId);
  }

  Future<Result<TeacherSubmissionDetailModel>> submissionDetail(
    String submissionId,
  ) async {
    return _repository.submissionDetail(submissionId);
  }
}
