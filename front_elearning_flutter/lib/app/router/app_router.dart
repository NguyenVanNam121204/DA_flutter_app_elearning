import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../views/screens/forgot_password_screen.dart';
import '../../views/screens/home_screen.dart';
import '../../views/screens/login_screen.dart';
import '../../views/screens/register_screen.dart';
import '../../views/screens/reset_password_screen.dart';
import '../../views/screens/verify_email_otp_screen.dart';
import '../../views/screens/verify_reset_otp_screen.dart';
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
        return RoutePaths.home;
      }

      return null;
    },
    routes: [
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
    ],
  );
});


