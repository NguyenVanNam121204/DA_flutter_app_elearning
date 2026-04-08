import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router/route_paths.dart';
import '../../widgets/common/catalunya_scaffold.dart';
import '../../widgets/common/state_views.dart';
import '../../widgets/quiz/quiz_question_card.dart';
import '../../widgets/quiz/quiz_step_controls.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({required this.quizId, super.key});
  final String quizId;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quizScreenViewModelProvider(widget.quizId));
    final notifier = ref.read(
      quizScreenViewModelProvider(widget.quizId).notifier,
    );

    ref.listen(quizScreenViewModelProvider(widget.quizId), (prev, next) {
      if ((prev?.errorMessage != next.errorMessage) &&
          (next.errorMessage?.isNotEmpty ?? false)) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
        notifier.clearError();
      }
      if ((prev?.submittedAttemptId != next.submittedAttemptId) &&
          (next.submittedAttemptId?.isNotEmpty ?? false)) {
        context.push(
          '${RoutePaths.lessonResult}?attemptId=${next.submittedAttemptId}',
        );
        notifier.clearSubmittedAttempt();
      }
    });

    return CatalunyaScaffold(
      appBar: AppBar(title: const Text('Bài kiểm tra')),
      body: Builder(
        builder: (context) {
          if (state.isLoading) {
            return const LoadingStateView();
          }
          if (state.questions.isEmpty) {
            return const Center(child: Text('Bài kiểm tra chưa có câu hỏi'));
          }
          final clampedIndex = state.currentIndex.clamp(
            0,
            state.questions.length - 1,
          );
          final q = state.questions[clampedIndex];
          final qid = q.questionId;
          final answer = state.answers[qid];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                state.quiz.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (state.remainingSeconds != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Thời gian còn lại: ${(state.remainingSeconds! ~/ 60).toString().padLeft(2, '0')}:${(state.remainingSeconds! % 60).toString().padLeft(2, '0')}',
                ),
              ],
              const SizedBox(height: 12),
              if (!state.hasAttempt)
                FilledButton(
                  onPressed: state.isStarting ? null : notifier.startAttempt,
                  child: Text(
                    state.isStarting ? 'Đang bắt đầu...' : 'Bắt đầu làm bài',
                  ),
                ),
              const SizedBox(height: 12),
              Text(
                'Câu ${clampedIndex + 1}/${state.questions.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              QuizQuestionCard(
                question: q,
                answer: answer,
                hasAttempt: state.hasAttempt,
                onTextChanged: (v) => notifier.setTextAnswer(qid, v),
                onToggleMulti: (optionId, checked) =>
                    notifier.toggleMultiAnswer(qid, optionId, checked),
                onSelectSingle: (optionId) =>
                    notifier.setSingleAnswer(qid, optionId),
              ),
              QuizStepControls(
                canGoBack: clampedIndex > 0,
                canGoNext: clampedIndex < state.questions.length - 1,
                onBack: notifier.previousQuestion,
                onNext: notifier.nextQuestion,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: (!state.hasAttempt || state.isSubmitting)
                    ? null
                    : notifier.submitAttempt,
                child: Text(state.isSubmitting ? 'Đang nộp bài...' : 'Nộp bài'),
              ),
            ],
          );
        },
      ),
    );
  }
}

