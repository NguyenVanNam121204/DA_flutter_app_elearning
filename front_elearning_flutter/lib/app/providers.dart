import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/logger/app_logger.dart';
import '../repositories/api_data_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/home_repository.dart';
import '../services/api_service.dart';
import '../services/auth_interceptor.dart';
import '../services/auth_session_service.dart';
import '../services/secure_storage_service.dart';
import '../viewmodels/api_data_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/flashcard_feature_viewmodel.dart';
import '../viewmodels/flashcard_learning_viewmodel.dart';
import '../viewmodels/flashcard_review_session_viewmodel.dart';
import '../viewmodels/home_viewmodel.dart';
import '../viewmodels/lesson_feature_viewmodel.dart';
import '../viewmodels/payment_feature_viewmodel.dart';
import '../viewmodels/payment_screen_viewmodel.dart';
import '../viewmodels/teacher_feature_viewmodel.dart';
import '../viewmodels/teacher_create_course_viewmodel.dart';
import '../viewmodels/quiz_screen_viewmodel.dart';
import 'config/app_config.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final authSessionProvider = Provider<AuthSessionService>((ref) {
  final service = AuthSessionService();
  ref.onDispose(service.dispose);
  return service;
});

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: Duration(milliseconds: AppConfig.connectTimeoutMs),
      receiveTimeout: Duration(milliseconds: AppConfig.receiveTimeoutMs),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  final refreshDio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: Duration(milliseconds: AppConfig.connectTimeoutMs),
      receiveTimeout: Duration(milliseconds: AppConfig.receiveTimeoutMs),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(
    AuthInterceptor(
      ref.read(secureStorageProvider),
      dio,
      refreshDio,
      ref.read(authSessionProvider),
    ),
  );

  if (AppConfig.enableNetworkLog) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          AppLogger.info('${options.method} ${options.uri}');
          handler.next(options);
        },
        onError: (error, handler) {
          AppLogger.error('${error.requestOptions.uri} - ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  return dio;
});

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(ref.read(dioProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(apiServiceProvider));
});

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(ref.read(apiServiceProvider));
});

final _apiDataRepositorySourceProvider = Provider<ApiDataRepository>((ref) {
  return ApiDataRepository(ref.read(apiServiceProvider));
});

final apiDataViewModelProvider = Provider<ApiDataViewModel>((ref) {
  return ApiDataViewModel(ref.read(_apiDataRepositorySourceProvider));
});

final lessonFeatureViewModelProvider = Provider<LessonFeatureViewModel>((ref) {
  return LessonFeatureViewModel(ref.read(apiDataViewModelProvider));
});

final paymentFeatureViewModelProvider = Provider<PaymentFeatureViewModel>((ref) {
  return PaymentFeatureViewModel(ref.read(apiDataViewModelProvider));
});

final teacherFeatureViewModelProvider = Provider<TeacherFeatureViewModel>((ref) {
  return TeacherFeatureViewModel(ref.read(apiDataViewModelProvider));
});

final flashcardFeatureViewModelProvider = Provider<FlashcardFeatureViewModel>((ref) {
  return FlashcardFeatureViewModel(ref.read(apiDataViewModelProvider));
});

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((
  ref,
) {
  return AuthViewModel(
    ref.read(authRepositoryProvider),
    ref.read(secureStorageProvider),
    ref.read(authSessionProvider),
  );
});

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((
  ref,
) {
  return HomeViewModel(ref.read(homeRepositoryProvider));
});

final quizScreenViewModelProvider = StateNotifierProvider.family<
    QuizScreenViewModel, QuizScreenState, String>((ref, quizId) {
  final vm = QuizScreenViewModel(ref.read(apiDataViewModelProvider));
  vm.initialize(quizId);
  return vm;
});

final paymentScreenViewModelProvider = StateNotifierProvider.family<
    PaymentScreenViewModel, PaymentScreenState, PaymentScreenArgs>((ref, args) {
  final vm = PaymentScreenViewModel(ref.read(paymentFeatureViewModelProvider));
  vm.initialize(args);
  return vm;
});

final flashcardLearningViewModelProvider = StateNotifierProvider.family<
    FlashcardLearningViewModel, FlashcardLearningState, String>((ref, lessonId) {
  final vm = FlashcardLearningViewModel(ref.read(flashcardFeatureViewModelProvider));
  vm.initialize(lessonId);
  return vm;
});

final flashcardReviewSessionViewModelProvider = StateNotifierProvider<
    FlashcardReviewSessionViewModel, FlashcardReviewSessionState>((ref) {
  final vm =
      FlashcardReviewSessionViewModel(ref.read(flashcardFeatureViewModelProvider));
  vm.initialize();
  return vm;
});

final teacherCreateCourseViewModelProvider = StateNotifierProvider<
    TeacherCreateCourseViewModel, TeacherCreateCourseState>((ref) {
  return TeacherCreateCourseViewModel(ref.read(teacherFeatureViewModelProvider));
});

