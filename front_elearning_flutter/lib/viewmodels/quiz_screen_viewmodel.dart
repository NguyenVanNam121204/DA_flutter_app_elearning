import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/result/result.dart';
import 'api_data_viewmodel.dart';

class QuizScreenState {
  const QuizScreenState({
    this.isLoading = false,
    this.errorMessage,
    this.quiz = const {},
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
  final Map<String, dynamic> quiz;
  final List<Map<String, dynamic>> questions;
  final String? attemptId;
  final bool isStarting;
  final bool isSubmitting;
  final Map<String, dynamic> answers;
  final int currentIndex;
  final int? remainingSeconds;
  final String? submittedAttemptId;

  bool get hasAttempt => (attemptId ?? '').isNotEmpty;

  QuizScreenState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    Map<String, dynamic>? quiz,
    List<Map<String, dynamic>>? questions,
    String? attemptId,
    bool clearAttemptId = false,
    bool? isStarting,
    bool? isSubmitting,
    Map<String, dynamic>? answers,
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
      remainingSeconds:
          clearRemainingSeconds ? null : remainingSeconds ?? this.remainingSeconds,
      submittedAttemptId: clearSubmittedAttemptId
          ? null
          : submittedAttemptId ?? this.submittedAttemptId,
    );
  }
}

class QuizScreenViewModel extends StateNotifier<QuizScreenState> {
  QuizScreenViewModel(this._api) : super(const QuizScreenState());

  final ApiDataViewModel _api;
  Timer? _timer;
  String? _quizId;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> initialize(String quizId) async {
    if (_quizId == quizId && state.quiz.isNotEmpty) return;
    _quizId = quizId;
    _timer?.cancel();
    state = const QuizScreenState(isLoading: true);
    final result = await _api.get('/api/user/quizzes/quiz/$quizId');
    switch (result) {
      case Success(:final value):
        final quiz = _asMap(value);
        final questions = _extractQuestions(quiz);
        state = state.copyWith(
          isLoading: false,
          quiz: quiz,
          questions: questions,
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
    var result = await _api.post('/api/user/quiz-attempts/start/$_quizId');
    if (result case Failure()) {
      result = await _api.post(
        '/api/user/quiz-attempts/start',
        body: {'quizId': _quizId},
      );
    }
    switch (result) {
      case Success(:final value):
        final map = _asMap(value);
        final durationRaw = map['duration'] ??
            map['Duration'] ??
            map['timeLimit'] ??
            map['TimeLimit'];
        final duration = durationRaw is int
            ? durationRaw
            : int.tryParse(durationRaw?.toString() ?? '');
        final attemptId = (map['quizAttemptId'] ??
                map['QuizAttemptId'] ??
                map['attemptId'] ??
                map['AttemptId'] ??
                '')
            .toString();
        state = state.copyWith(
          isStarting: false,
          attemptId: attemptId,
          remainingSeconds: duration != null && duration > 0 ? duration * 60 : null,
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
    final result = await _api.post(
      '/api/user/quiz-attempts/$attemptId/submit',
      body: {
        'answers': state.answers.entries
            .map(
              (e) => {'questionId': e.key, 'selectedAnswer': e.value},
            )
            .toList(),
      },
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
        state = state.copyWith(isSubmitting: false, errorMessage: error.message);
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
    final next = Map<String, dynamic>.from(state.answers);
    next[questionId] = value;
    state = state.copyWith(answers: next);
  }

  void toggleMultiAnswer(String questionId, String optionId, bool checked) {
    final next = Map<String, dynamic>.from(state.answers);
    final list = List<String>.from((next[questionId] as List?) ?? const []);
    if (checked) {
      if (!list.contains(optionId)) list.add(optionId);
    } else {
      list.remove(optionId);
    }
    next[questionId] = list;
    state = state.copyWith(answers: next);
  }

  void setSingleAnswer(String questionId, String optionId) {
    final next = Map<String, dynamic>.from(state.answers);
    next[questionId] = optionId;
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

  Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final data = raw['data'] ?? raw['Data'] ?? raw;
      if (data is Map<String, dynamic>) return data;
      return raw;
    }
    return const {};
  }

  List<Map<String, dynamic>> _extractQuestions(Map<String, dynamic> quiz) {
    final direct = ((quiz['questions'] ?? quiz['Questions']) as List?)
            ?.whereType<Map<String, dynamic>>()
            .toList() ??
        const <Map<String, dynamic>>[];
    if (direct.isNotEmpty) return direct;
    final sections = ((quiz['quizSections'] ?? quiz['QuizSections']) as List?)
            ?.whereType<Map<String, dynamic>>()
            .toList() ??
        const <Map<String, dynamic>>[];
    final out = <Map<String, dynamic>>[];
    for (final s in sections) {
      final items = ((s['items'] ?? s['Items']) as List?)
              ?.whereType<Map<String, dynamic>>()
              .toList() ??
          const <Map<String, dynamic>>[];
      for (final it in items) {
        if (it['questionId'] != null || it['QuestionId'] != null) {
          out.add(it);
        } else {
          final qs = ((it['questions'] ?? it['Questions']) as List?)
                  ?.whereType<Map<String, dynamic>>()
                  .toList() ??
              const <Map<String, dynamic>>[];
          out.addAll(qs);
        }
      }
    }
    return out;
  }
}
