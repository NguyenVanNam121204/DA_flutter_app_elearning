import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/errors/app_error.dart';
import '../../core/result/result.dart';
import '../../models/learning/pronunciation_models.dart';
import '../../services/api_service.dart';

class PronunciationRepository {
  PronunciationRepository(this._apiService);

  final ApiService _apiService;

  Future<Result<List<PronunciationItemModel>>> pronunciationList(
    String moduleId,
  ) async {
    try {
      var response = await _apiService.get(
        ApiConstants.userPronunciationsByModule(moduleId),
      );
      var list = _asList(response.data);
      if (list.isEmpty) {
        response = await _apiService.get(
          '${ApiConstants.userBase}/pronunciations/$moduleId',
        );
        list = _asList(response.data);
      }
      return Success(list.map(PronunciationItemModel.fromJson).toList());
    } on DioException catch (error) {
      return Failure(_mapDioException(error));
    } catch (_) {
      return const Failure(AppError(message: 'Unable to load pronunciations.'));
    }
  }

  Future<Result<PronunciationDetailModel>> pronunciationDetail(
    String pronunciationId,
  ) async {
    try {
      var response = await _apiService.get(
        ApiConstants.userPronunciationDetail(pronunciationId),
      );
      var detailMap = _asMap(response.data);
      if (detailMap.isEmpty) {
        response = await _apiService.get(
          '${ApiConstants.userBase}/pronunciations/$pronunciationId',
        );
        detailMap = _asMap(response.data);
      }
      return Success(PronunciationDetailModel.fromJson(detailMap));
    } on DioException catch (error) {
      return Failure(_mapDioException(error));
    } catch (_) {
      return const Failure(
        AppError(message: 'Unable to load pronunciation detail.'),
      );
    }
  }

  Map<String, dynamic> _asMap(Object? raw) {
    if (raw is Map<String, dynamic>) {
      final data = raw['data'] ?? raw['Data'] ?? raw;
      if (data is Map<String, dynamic>) return data;
      return raw;
    }
    return const {};
  }

  List<Map<String, dynamic>> _asList(Object? raw) {
    if (raw is Map<String, dynamic>) {
      final data = raw['data'] ?? raw['Data'] ?? raw['items'] ?? raw['Items'];
      if (data is List) return data.whereType<Map<String, dynamic>>().toList();
    } else if (raw is List) {
      return raw.whereType<Map<String, dynamic>>().toList();
    }
    return const [];
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
