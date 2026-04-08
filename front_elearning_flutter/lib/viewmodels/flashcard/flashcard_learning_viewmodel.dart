import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/result/result.dart';
import '../../models/flashcard/flashcard_models.dart';
import 'flashcard_feature_viewmodel.dart';

class FlashcardLearningState {
  const FlashcardLearningState({
    this.isLoading = true,
    this.cards = const [],
    this.index = 0,
    this.flipped = false,
  });

  final bool isLoading;
  final List<FlashcardModel> cards;
  final int index;
  final bool flipped;

  FlashcardLearningState copyWith({
    bool? isLoading,
    List<FlashcardModel>? cards,
    int? index,
    bool? flipped,
  }) {
    return FlashcardLearningState(
      isLoading: isLoading ?? this.isLoading,
      cards: cards ?? this.cards,
      index: index ?? this.index,
      flipped: flipped ?? this.flipped,
    );
  }
}

class FlashcardLearningViewModel extends StateNotifier<FlashcardLearningState> {
  FlashcardLearningViewModel(this._feature)
    : super(const FlashcardLearningState());

  final FlashcardFeatureViewModel _feature;
  String? _lessonId;

  Future<void> initialize(String lessonId) async {
    if (_lessonId == lessonId && !state.isLoading) return;
    _lessonId = lessonId;
    state = const FlashcardLearningState(isLoading: true);
    final result = await _feature.lessonFlashcards(lessonId);
    switch (result) {
      case Success(:final value):
        state = state.copyWith(
          isLoading: false,
          cards: value,
          index: 0,
          flipped: false,
        );
      case Failure():
        state = state.copyWith(isLoading: false, cards: const []);
    }
  }

  void toggleCard() {
    state = state.copyWith(flipped: !state.flipped);
  }

  bool next() {
    if (state.index < state.cards.length - 1) {
      state = state.copyWith(index: state.index + 1, flipped: false);
      return false;
    }
    return true;
  }

  void previous() {
    if (state.index > 0) {
      state = state.copyWith(index: state.index - 1, flipped: false);
    }
  }
}
