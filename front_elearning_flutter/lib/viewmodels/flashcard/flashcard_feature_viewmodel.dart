import '../../core/result/result.dart';
import '../../models/flashcard/flashcard_models.dart';
import '../../repositories/flashcard/flashcard_repository.dart';

class FlashcardFeatureViewModel {
  FlashcardFeatureViewModel(this._repository);

  final FlashcardRepository _repository;

  Future<Result<List<FlashcardModel>>> lessonFlashcards(String lessonId) async {
    return _repository.lessonFlashcards(lessonId);
  }

  Future<Result<List<FlashcardModel>>> dueReviewCards() async {
    return _repository.dueReviewCards();
  }

  Future<Result<void>> reviewCard({
    required String flashCardId,
    required int quality,
  }) async {
    return _repository.reviewCard(flashCardId: flashCardId, quality: quality);
  }
}
