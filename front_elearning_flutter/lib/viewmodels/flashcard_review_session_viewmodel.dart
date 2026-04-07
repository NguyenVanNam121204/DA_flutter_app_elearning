import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/result/result.dart';
import 'flashcard_feature_viewmodel.dart';

class FlashcardReviewSessionState {
  const FlashcardReviewSessionState({
    this.isLoading = true,
    this.isSubmitting = false,
    this.isFinished = false,
    this.index = 0,
    this.cards = const [],
    this.showBack = false,
    this.mastered = 0,
  });

  final bool isLoading;
  final bool isSubmitting;
  final bool isFinished;
  final int index;
  final List<Map<String, dynamic>> cards;
  final bool showBack;
  final int mastered;

  FlashcardReviewSessionState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    bool? isFinished,
    int? index,
    List<Map<String, dynamic>>? cards,
    bool? showBack,
    int? mastered,
  }) {
    return FlashcardReviewSessionState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isFinished: isFinished ?? this.isFinished,
      index: index ?? this.index,
      cards: cards ?? this.cards,
      showBack: showBack ?? this.showBack,
      mastered: mastered ?? this.mastered,
    );
  }
}

class FlashcardReviewSessionViewModel
    extends StateNotifier<FlashcardReviewSessionState> {
  FlashcardReviewSessionViewModel(this._feature)
      : super(const FlashcardReviewSessionState());

  final FlashcardFeatureViewModel _feature;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    await loadDueCards();
  }

  Future<void> loadDueCards() async {
    state = state.copyWith(isLoading: true);
    final result = await _feature.dueReviewCards();
    switch (result) {
      case Success(:final value):
        state = state.copyWith(
          isLoading: false,
          cards: value,
          index: 0,
          isFinished: false,
          mastered: 0,
          showBack: false,
        );
      case Failure():
        state = state.copyWith(isLoading: false);
    }
  }

  void toggleCard() {
    state = state.copyWith(showBack: !state.showBack);
  }

  Future<void> review(int quality) async {
    if (state.isSubmitting || state.index >= state.cards.length) return;
    final card = state.cards[state.index];
    final cardId = (card['flashCardId'] ?? card['id'] ?? '').toString();
    if (cardId.isEmpty) return;
    state = state.copyWith(isSubmitting: true);
    await _feature.reviewCard(flashCardId: cardId, quality: quality);
    final mastered = quality >= 4 ? state.mastered + 1 : state.mastered;
    if (state.index < state.cards.length - 1) {
      state = state.copyWith(
        index: state.index + 1,
        isSubmitting: false,
        showBack: false,
        mastered: mastered,
      );
    } else {
      state = state.copyWith(
        isFinished: true,
        isSubmitting: false,
        mastered: mastered,
      );
    }
  }
}
