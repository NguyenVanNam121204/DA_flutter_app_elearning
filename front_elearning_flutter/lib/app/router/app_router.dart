import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../views/screens/auth/forgot_password_screen.dart';
import '../../views/screens/auth/login_screen.dart';
import '../../views/screens/auth/register_screen.dart';
import '../../views/screens/auth/reset_password_screen.dart';
import '../../views/screens/auth/verify_email_otp_screen.dart';
import '../../views/screens/auth/verify_reset_otp_screen.dart';
import '../../views/screens/home/home_screen.dart';
import '../../views/screens/loading/loading_page.dart';
import '../../views/screens/navigation/main_tabs_screen.dart';
import '../../views/screens/pro/pro_screen.dart';
import '../../views/screens/assignment/assignment_detail_screen.dart';
import '../../views/screens/assignment/essay_screen.dart';
import '../../views/screens/course/course_detail_screen.dart';
import '../../views/screens/flashcard/flashcard_learning_screen.dart';
import '../../views/screens/flashcard/flashcard_review_session_screen.dart';
import '../../views/screens/lesson/lecture_detail_screen.dart';
import '../../views/screens/lesson/lesson_detail_screen.dart';
import '../../views/screens/lesson/lesson_list_screen.dart';
import '../../views/screens/lesson/lesson_result_screen.dart';
import '../../views/screens/lesson/module_learning_screen.dart';
import '../../views/screens/lesson/pronunciation_detail_screen.dart';
import '../../views/screens/notification/notification_screen.dart';
import '../../views/screens/payment/payment_failed_screen.dart';
import '../../views/screens/payment/payment_history_screen.dart';
import '../../views/screens/payment/payment_screen.dart';
import '../../views/screens/payment/payment_success_screen.dart';
import '../../views/screens/quiz/quiz_screen.dart';
import '../../views/screens/search/search_screen.dart';
import '../../views/screens/teacher/create_course_screen.dart';
import '../../views/screens/teacher/teacher_class_list_screen.dart';
import '../../views/screens/teacher/teacher_course_submissions_screen.dart';
import '../../views/screens/teacher/teacher_course_detail_screen.dart';
import '../../views/screens/teacher/teacher_essay_submissions_screen.dart';
import '../../views/screens/teacher/teacher_home_screen.dart';
import '../../views/screens/teacher/teacher_lesson_detail_screen.dart';
import '../../views/screens/teacher/teacher_quiz_attempt_detail_screen.dart';
import '../../views/screens/teacher/teacher_quiz_attempts_screen.dart';
import '../../views/screens/teacher/teacher_submission_detail_screen.dart';
import '../providers.dart';
import 'route_paths.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(
    authViewModelProvider.select((state) => state.isAuthenticated),
  );

  return GoRouter(
    initialLocation: RoutePaths.login,
    redirect: (context, state) {
      final isAuth = isAuthenticated;
      final isAuthPage =
          state.matchedLocation == RoutePaths.login ||
          state.matchedLocation == RoutePaths.register ||
          state.matchedLocation == RoutePaths.forgotPassword ||
          state.matchedLocation == RoutePaths.verifyEmailOtp ||
          state.matchedLocation == RoutePaths.verifyResetOtp ||
          state.matchedLocation == RoutePaths.resetPassword;

      if (!isAuth && !isAuthPage) {
        return RoutePaths.login;
      }

      if (isAuth && isAuthPage) {
        return RoutePaths.mainApp;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.loading,
        builder: (context, state) => const LoadingPage(),
      ),
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RoutePaths.verifyEmailOtp,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return VerifyEmailOtpScreen(email: email);
        },
      ),
      GoRoute(
        path: RoutePaths.verifyResetOtp,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return VerifyResetOtpScreen(email: email);
        },
      ),
      GoRoute(
        path: RoutePaths.resetPassword,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          final otpCode = state.uri.queryParameters['otpCode'] ?? '';
          return ResetPasswordScreen(email: email, otpCode: otpCode);
        },
      ),
      GoRoute(
        path: RoutePaths.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: RoutePaths.mainApp,
        builder: (context, state) => const MainTabsScreen(),
      ),
      GoRoute(
        path: RoutePaths.pro,
        builder: (context, state) => const ProScreen(),
      ),
      GoRoute(
        path: RoutePaths.courseDetail,
        builder: (context, state) => CourseDetailScreen(
          courseId: state.uri.queryParameters['courseId'] ?? '',
        ),
      ),
      GoRoute(
        path: RoutePaths.search,
        builder: (context, state) => SearchScreen(
          keyword: state.uri.queryParameters['keyword'] ?? '',
        ),
      ),
      GoRoute(
        path: RoutePaths.lessonList,
        builder: (context, state) => LessonListScreen(
          courseId: state.uri.queryParameters['courseId'] ?? '',
        ),
      ),
      GoRoute(
        path: RoutePaths.lessonDetail,
        builder: (context, state) => LessonDetailScreen(
          lessonId: state.uri.queryParameters['lessonId'] ?? '',
        ),
      ),
      GoRoute(
        path: RoutePaths.moduleLearning,
        builder: (context, state) => ModuleLearningScreen(
          moduleId: state.uri.queryParameters['moduleId'] ?? '',
        ),
      ),
      GoRoute(
        path: RoutePaths.pronunciationDetail,
        builder: (context, state) => PronunciationDetailScreen(
          pronunciationId: state.uri.queryParameters['pronunciationId'] ?? '',
        ),
      ),
      GoRoute(
        path: RoutePaths.lectureDetail,
        builder: (context, state) => LectureDetailScreen(
          lectureId: state.uri.queryParameters['lectureId'] ?? '',
        ),
      ),
      GoRoute(
        path: RoutePaths.assignmentDetail,
        builder: (context, state) => AssignmentDetailScreen(
          assessmentId: state.uri.queryParameters['assessmentId'] ?? '',
          moduleId: state.uri.queryParameters['moduleId'] ?? '',
        ),
      ),
      GoRoute(
        path: RoutePaths.quiz,
        builder: (context, state) => QuizScreen(
          quizId: state.uri.queryParameters['quizId'] ?? '',
        ),
      ),
      GoRoute(
        path: RoutePaths.lessonResult,
        builder: (context, state) => LessonResultScreen(
          attemptId: state.uri.queryParameters['attemptId'] ?? '',
        ),
      ),
      GoRoute(
        path: RoutePaths.essay,
        builder: (context, state) => EssayScreen(
          essayId: state.uri.queryParameters['essayId'] ?? '',
        ),
      ),
      GoRoute(
        path: RoutePaths.payment,
        builder: (context, state) => PaymentScreen(
          paymentId: state.uri.queryParameters['paymentId'] ?? '',
          courseId: state.uri.queryParameters['courseId'] ?? '',
          courseTitle: state.uri.queryParameters['courseTitle'] ?? '',
          packageId: state.uri.queryParameters['packageId'] ?? '',
          packageName: state.uri.queryParameters['packageName'] ?? '',
          price: state.uri.queryParameters['price'] ?? '',
        ),
      ),
      GoRoute(
        path: RoutePaths.paymentSuccess,
        builder: (context, state) => PaymentSuccessScreen(
          paymentId: state.uri.queryParameters['paymentId'] ?? '',
          courseId: state.uri.queryParameters['courseId'] ?? '',
          orderCode: state.uri.queryParameters['orderCode'] ?? '',
        ),
      ),
      GoRoute(
        path: RoutePaths.paymentFailed,
        builder: (context, state) => PaymentFailedScreen(
          reason: state.uri.queryParameters['reason'] ?? '',
        ),
      ),
      GoRoute(
        path: RoutePaths.paymentHistory,
        builder: (context, state) => const PaymentHistoryScreen(),
      ),
      GoRoute(
        path: RoutePaths.notifications,
        builder: (context, state) => const NotificationScreen(),
      ),
      GoRoute(
        path: RoutePaths.flashcardLearning,
        builder: (context, state) => FlashCardLearningScreen(
          lessonId: state.uri.queryParameters['lessonId'] ?? '',
        ),
      ),
      GoRoute(
        path: RoutePaths.flashcardReview,
        builder: (context, state) => const FlashCardReviewSession(),
      ),
      GoRoute(
        path: RoutePaths.teacherHome,
        builder: (context, state) => const TeacherHomeScreen(),
      ),
      GoRoute(
        path: RoutePaths.teacherClasses,
        builder: (context, state) => TeacherClassListScreen(
          courseId: state.uri.queryParameters['courseId'] ?? '',
        ),
      ),
      GoRoute(
        path: RoutePaths.teacherCreateCourse,
        builder: (context, state) => const CreateCourseScreen(),
      ),
      GoRoute(
        path: RoutePaths.teacherCourseDetail,
        builder: (context, state) => TeacherCourseDetailScreen(
          courseId: state.uri.queryParameters['courseId'] ?? '',
        ),
      ),
      GoRoute(
        path: RoutePaths.teacherLessonDetail,
        builder: (context, state) => TeacherLessonDetailScreen(
          lessonId: state.uri.queryParameters['lessonId'] ?? '',
        ),
      ),
      GoRoute(
        path: RoutePaths.teacherCourseSubmissions,
        builder: (context, state) => TeacherCourseSubmissionsScreen(
          essayId: state.uri.queryParameters['essayId'] ?? '',
        ),
      ),
      GoRoute(
        path: RoutePaths.teacherEssaySubmissions,
        builder: (context, state) => TeacherEssaySubmissionsScreen(
          essayId: state.uri.queryParameters['essayId'] ?? '',
        ),
      ),
      GoRoute(
        path: RoutePaths.teacherSubmissionDetail,
        builder: (context, state) => TeacherSubmissionDetailScreen(
          submissionId: state.uri.queryParameters['submissionId'] ?? '',
        ),
      ),
      GoRoute(
        path: RoutePaths.teacherQuizAttempts,
        builder: (context, state) => TeacherQuizAttemptsScreen(
          quizId: state.uri.queryParameters['quizId'] ?? '',
        ),
      ),
      GoRoute(
        path: RoutePaths.teacherQuizAttemptDetail,
        builder: (context, state) => TeacherQuizAttemptDetailScreen(
          attemptId: state.uri.queryParameters['attemptId'] ?? '',
        ),
      ),
    ],
  );
});


