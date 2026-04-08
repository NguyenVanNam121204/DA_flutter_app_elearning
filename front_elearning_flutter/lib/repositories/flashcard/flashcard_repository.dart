import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/errors/app_error.dart';
import '../../core/result/result.dart';
import '../../models/flashcard/flashcard_models.dart';
import '../../services/api_service.dart';

class FlashcardRepository {
  FlashcardRepository(this._apiService);

  final ApiService _apiService;

  Future<Result<List<FlashcardModel>>> lessonFlashcards(String lessonId) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.userFlashcards}/lesson/$lessonId',
      );
      return Success(_asList(response.data));
    } on DioException catch (error) {
      return Failure(_mapDioException(error));
    } catch (_) {
      return const Failure(AppError(message: 'Unable to load flashcards.'));
    }
  }

  Future<Result<List<FlashcardModel>>> dueReviewCards() async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.userFlashcardReview}/due',
      );
      return Success(_asList(response.data));
    } on DioException catch (error) {
      return Failure(_mapDioException(error));
    } catch (_) {
      return const Failure(AppError(message: 'Unable to load review cards.'));
    }
  }

  Future<Result<void>> reviewCard({
    required String flashCardId,
    required int quality,
  }) async {
    try {
      await _apiService.post(
        '${ApiConstants.userFlashcardReview}/review',
        data: {'FlashCardId': flashCardId, 'Quality': quality},
      );
      return const Success(null);
    } on DioException catch (error) {
      return Failure(_mapDioException(error));
    } catch (_) {
      return const Failure(AppError(message: 'Unable to review flashcard.'));
    }
  }

  List<FlashcardModel> _asList(Object? raw) {
    if (raw is Map<String, dynamic>) {
      final data = raw['data'] ?? raw['Data'] ?? raw;
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(FlashcardModel.fromJson)
            .toList();
      }
      if (data is Map<String, dynamic>) {
        final cards = data['flashCards'] ?? data['cards'] ?? data['data'];
        if (cards is List) {
          return cards
              .whereType<Map<String, dynamic>>()
              .map(FlashcardModel.fromJson)
              .toList();
        }
      }
    } else if (raw is List) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map(FlashcardModel.fromJson)
          .toList();
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
