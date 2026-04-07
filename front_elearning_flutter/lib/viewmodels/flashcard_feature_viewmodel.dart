import '../core/result/result.dart';
import 'api_data_viewmodel.dart';

class FlashcardFeatureViewModel {
  FlashcardFeatureViewModel(this._api);

  final ApiDataViewModel _api;

  Future<Result<List<Map<String, dynamic>>>> lessonFlashcards(String lessonId) async {
    final res = await _api.get('/api/user/flashcards/lesson/$lessonId');
    return switch (res) {
      Success(:final value) => Success(_asList(value)),
      Failure(:final error) => Failure(error),
    };
  }

  Future<Result<List<Map<String, dynamic>>>> dueReviewCards() async {
    final res = await _api.get('/api/user/flashcard-review/due');
    return switch (res) {
      Success(:final value) => Success(_asList(value)),
      Failure(:final error) => Failure(error),
    };
  }

  Future<Result<void>> reviewCard({
    required String flashCardId,
    required int quality,
  }) async {
    final res = await _api.post(
      '/api/user/flashcard-review/review',
      body: {'FlashCardId': flashCardId, 'Quality': quality},
    );
    return switch (res) {
      Success() => const Success(null),
      Failure(:final error) => Failure(error),
    };
  }

  List<Map<String, dynamic>> _asList(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final data = raw['data'] ?? raw['Data'] ?? raw;
      if (data is List) return data.whereType<Map<String, dynamic>>().toList();
      if (data is Map<String, dynamic>) {
        final cards = data['flashCards'] ?? data['cards'] ?? data['data'];
        if (cards is List) return cards.whereType<Map<String, dynamic>>().toList();
      }
    } else if (raw is List) {
      return raw.whereType<Map<String, dynamic>>().toList();
    }
    return const [];
  }
}

