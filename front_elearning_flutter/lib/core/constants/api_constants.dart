class ApiConstants {
  static const authBase = '/api/auth';
  static const userBase = '/api/user';
  static const teacherBase = '/api/teacher';

  static const login = '$authBase/login';
  static const register = '$authBase/register';
  static const verifyEmail = '$authBase/verify-email';
  static const forgotPassword = '$authBase/forgot-password';
  static const verifyOtp = '$authBase/verify-otp';
  static const setNewPassword = '$authBase/set-new-password';
  static const refreshToken = '$authBase/refresh-token';
  static const profile = '$authBase/profile';

  static const systemCourses = '$userBase/courses/system-courses';
  static const myEnrolledCourses = '$userBase/enrollments/my-courses';
  static const streak = '$userBase/streaks';

  static const notifications = '$userBase/notifications';
  static const vocabularyNotebook = '$userBase/vocabulary/notebook';

  static const paymentProcess = '$userBase/payments/process';
  static const paymentHistory = '$userBase/payments/history';

  static const userEssays = '$userBase/essays';
  static const userEssaySubmissions = '$userBase/essay-submissions';
  static const userAssessments = '$userBase/assessments';

  static const teacherCourses = '$teacherBase/courses';
  static const teacherLessons = '$teacherBase/lessons';
  static const teacherEssaySubmissions = '$teacherBase/essay-submissions';
  static const teacherQuizAttempts = '$teacherBase/quiz-attempts';

  static String notificationMarkAsRead(String id) =>
      '$notifications/$id/mark-as-read';
  static String payOsCreateLink(String paymentId) =>
      '$userBase/payments/payos/create-link/$paymentId';
  static String payOsConfirm(String paymentId) =>
      '$userBase/payments/payos/confirm/$paymentId';

  static String quizById(String quizId) => '$userBase/quizzes/quiz/$quizId';
  static String quizStartAttemptByQuizId(String quizId) =>
      '$userBase/quiz-attempts/start/$quizId';
  static const quizStartAttempt = '$userBase/quiz-attempts/start';
  static String quizSubmitAttempt(String attemptId) =>
      '$userBase/quiz-attempts/$attemptId/submit';
  static String quizAttemptResult(String attemptId) =>
      '$userBase/quiz-attempts/$attemptId/result';

  static String userCourseDetail(String courseId) =>
      '$userBase/courses/$courseId';
  static const userSearchCourses = '$userBase/courses/search';
  static String userLessonsByCourse(String courseId) =>
      '$userBase/lessons/course/$courseId';
  static String userLessonDetail(String lessonId) =>
      '$userBase/lessons/$lessonId';
  static String userModulesByLesson(String lessonId) =>
      '$userBase/modules/lesson/$lessonId';
  static String userLecturesByModule(String moduleId) =>
      '$userBase/lectures/module/$moduleId';
  static String userLectureDetail(String lectureId) =>
      '$userBase/lectures/$lectureId';

  static String userPronunciationsByModule(String moduleId) =>
      '$userBase/pronunciation-assessments/module/$moduleId';
  static String userPronunciationDetail(String pronunciationId) =>
      '$userBase/pronunciation-assessments/$pronunciationId';

  static String userEssayDetail(String essayId) => '$userEssays/$essayId';
  static String userAssessmentDetail(String assessmentId) =>
      '$userAssessments/$assessmentId';
  static String userAssessmentsByModule(String moduleId) =>
      '$userAssessments/module/$moduleId';

  static const enrollCourse = '$userBase/enrollments/course';

  static const userFlashcards = '$userBase/flashcards';
  static const userFlashcardReview = '$userBase/flashcard-review';

  static String teacherCourseDetail(String courseId) =>
      '$teacherCourses/$courseId';
  static String teacherCourseStudents(String courseId) =>
      '$teacherCourses/$courseId/students';
  static String teacherLessonDetail(String lessonId) =>
      '$teacherLessons/$lessonId';
  static String teacherEssaySubmissionsByEssay(String essayId) =>
      '$teacherEssaySubmissions/essay/$essayId';
  static String teacherSubmissionDetail(String submissionId) =>
      '$teacherEssaySubmissions/$submissionId';
  static String teacherQuizAttemptsByQuiz(String quizId) =>
      '$teacherQuizAttempts/quiz/$quizId/paged';
  static String teacherQuizAttemptDetail(String attemptId) =>
      '$teacherQuizAttempts/$attemptId/review';
}
