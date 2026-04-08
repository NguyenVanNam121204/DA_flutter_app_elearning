import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/result/result.dart';
import '../../models/quiz/quiz_models.dart';
import '../../repositories/quiz/quiz_repository.dart';

class QuizAnswerModel {
  const QuizAnswerModel({
    this.textAnswer,
    this.singleOptionId,
    this.multiOptionIds = const <String>{},
  });

  final String? textAnswer;
  final String? singleOptionId;
  final Set<String> multiOptionIds;

  Object? toRequestValue() {
    if (multiOptionIds.isNotEmpty) return multiOptionIds.toList();
    if ((singleOptionId ?? '').isNotEmpty) return singleOptionId;
    if ((textAnswer ?? '').isNotEmpty) return textAnswer;
    return null;
  }
}

class QuizScreenState {
  const QuizScreenState({
    this.isLoading = false,
    this.errorMessage,
    this.quiz = const QuizDetailModel.empty(),
    this.questions = const [],
    this.attemptId,
    this.isStarting = false,
    this.isSubmitting = false,
    this.answers = const {},
    this.currentIndex = 0,
    this.remainingSeconds,
    this.submittedAttemptId,
  });

  final bool isLoading;
  final String? errorMessage;
  final QuizDetailModel quiz;
  final List<QuizQuestionModel> questions;
  final String? attemptId;
  final bool isStarting;
  final bool isSubmitting;
  final Map<String, QuizAnswerModel> answers;
  final int currentIndex;
  final int? remainingSeconds;
  final String? submittedAttemptId;

  bool get hasAttempt => (attemptId ?? '').isNotEmpty;

  QuizScreenState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    QuizDetailModel? quiz,
    List<QuizQuestionModel>? questions,
    String? attemptId,
    bool clearAttemptId = false,
    bool? isStarting,
    bool? isSubmitting,
    Map<String, QuizAnswerModel>? answers,
    int? currentIndex,
    int? remainingSeconds,
    bool clearRemainingSeconds = false,
    String? submittedAttemptId,
    bool clearSubmittedAttemptId = false,
  }) {
    return QuizScreenState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      quiz: quiz ?? this.quiz,
      questions: questions ?? this.questions,
      attemptId: clearAttemptId ? null : attemptId ?? this.attemptId,
      isStarting: isStarting ?? this.isStarting,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      answers: answers ?? this.answers,
      currentIndex: currentIndex ?? this.currentIndex,
      remainingSeconds: clearRemainingSeconds
          ? null
          : remainingSeconds ?? this.remainingSeconds,
      submittedAttemptId: clearSubmittedAttemptId
          ? null
          : submittedAttemptId ?? this.submittedAttemptId,
    );
  }
}

class QuizScreenViewModel extends StateNotifier<QuizScreenState> {
  QuizScreenViewModel(this._repository) : super(const QuizScreenState());

  final QuizRepository _repository;
  Timer? _timer;
  String? _quizId;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> initialize(String quizId) async {
    if (_quizId == quizId && state.questions.isNotEmpty) return;
    _quizId = quizId;
    _timer?.cancel();
    state = const QuizScreenState(isLoading: true);
    final result = await _repository.quizById(quizId);
    switch (result) {
      case Success(:final value):
        final quiz = value;
        state = state.copyWith(
          isLoading: false,
          quiz: quiz,
          questions: quiz.questions,
          currentIndex: 0,
          answers: const {},
          clearError: true,
          clearAttemptId: true,
          clearRemainingSeconds: true,
          clearSubmittedAttemptId: true,
        );
      case Failure(:final error):
        state = state.copyWith(isLoading: false, errorMessage: error.message);
    }
  }

  Future<void> startAttempt() async {
    if ((_quizId ?? '').isEmpty || state.isStarting) return;
    state = state.copyWith(isStarting: true, clearError: true);
    final result = await _repository.startAttempt(_quizId);
    switch (result) {
      case Success(:final value):
        final startAttempt = value;
        state = state.copyWith(
          isStarting: false,
          attemptId: startAttempt.attemptId,
          remainingSeconds:
              (startAttempt.durationMinutes != null &&
                  startAttempt.durationMinutes! > 0)
              ? startAttempt.durationMinutes! * 60
              : null,
        );
        _startTimerIfNeeded();
      case Failure(:final error):
        state = state.copyWith(isStarting: false, errorMessage: error.message);
    }
  }

  Future<String?> submitAttempt() async {
    if (!state.hasAttempt || state.isSubmitting) return null;
    state = state.copyWith(isSubmitting: true, clearError: true);
    final attemptId = state.attemptId!;
    final result = await _repository.submitAttempt(
      attemptId: attemptId,
      answers: state.answers.entries.map((entry) {
        return {
          'questionId': entry.key,
          'selectedAnswer': entry.value.toRequestValue(),
        };
      }).toList(),
    );
    switch (result) {
      case Success():
        _timer?.cancel();
        state = state.copyWith(
          isSubmitting: false,
          submittedAttemptId: attemptId,
        );
        return attemptId;
      case Failure(:final error):
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: error.message,
        );
        return null;
    }
  }

  void nextQuestion() {
    final clamped = state.currentIndex.clamp(0, state.questions.length - 1);
    if (clamped >= state.questions.length - 1) return;
    state = state.copyWith(currentIndex: clamped + 1);
  }

  void previousQuestion() {
    final clamped = state.currentIndex.clamp(0, state.questions.length - 1);
    if (clamped <= 0) return;
    state = state.copyWith(currentIndex: clamped - 1);
  }

  void setTextAnswer(String questionId, String value) {
    final next = Map<String, QuizAnswerModel>.from(state.answers);
    next[questionId] = QuizAnswerModel(textAnswer: value);
    state = state.copyWith(answers: next);
  }

  void toggleMultiAnswer(String questionId, String optionId, bool checked) {
    final next = Map<String, QuizAnswerModel>.from(state.answers);
    final selected = Set<String>.from(
      next[questionId]?.multiOptionIds ?? const <String>{},
    );
    if (checked) {
      selected.add(optionId);
    } else {
      selected.remove(optionId);
    }
    next[questionId] = QuizAnswerModel(multiOptionIds: selected);
    state = state.copyWith(answers: next);
  }

  void setSingleAnswer(String questionId, String optionId) {
    final next = Map<String, QuizAnswerModel>.from(state.answers);
    next[questionId] = QuizAnswerModel(singleOptionId: optionId);
    state = state.copyWith(answers: next);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void clearSubmittedAttempt() {
    state = state.copyWith(clearSubmittedAttemptId: true);
  }

  void _startTimerIfNeeded() {
    _timer?.cancel();
    if (!state.hasAttempt || (state.remainingSeconds ?? 0) <= 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (state.isSubmitting) return;
      final remaining = state.remainingSeconds;
      if (remaining == null) {
        _timer?.cancel();
        return;
      }
      if (remaining <= 0) {
        _timer?.cancel();
        await submitAttempt();
        return;
      }
      state = state.copyWith(remainingSeconds: remaining - 1);
    });
  }
}
