import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/logger/app_logger.dart';
import '../repositories/auth_repository.dart';
import '../repositories/home_repository.dart';
import '../services/api_service.dart';
import '../services/auth_interceptor.dart';
import '../services/auth_session_service.dart';
import '../services/secure_storage_service.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/home_viewmodel.dart';
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


