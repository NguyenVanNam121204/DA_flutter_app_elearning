class ApiConstants {
  static const authBase = '/api/auth';
  static const userBase = '/api/user';

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
}
