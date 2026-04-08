import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/errors/app_error.dart';
import '../../core/result/result.dart';
import '../../models/learning/course_models.dart';
import '../../services/api_service.dart';

class ProfileRepository {
  ProfileRepository(this._apiService);

  final ApiService _apiService;

  Future<Result<UserProfileModel>> profile() async {
    try {
      final response = await _apiService.get(ApiConstants.profile);
      return Success(_asModel(response.data));
    } on DioException catch (error) {
      return Failure(_mapDioException(error));
    } catch (_) {
      return const Failure(AppError(message: 'Unable to load profile.'));
    }
  }

  UserProfileModel _asModel(Object? raw) {
    if (raw is Map<String, dynamic>) {
      final data = raw['data'] ?? raw['Data'] ?? raw;
      if (data is Map<String, dynamic>) return UserProfileModel.fromJson(data);
      return UserProfileModel.fromJson(raw);
    }
    return const UserProfileModel(fullName: '-', email: '-', role: '-');
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
