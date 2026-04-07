import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router/route_paths.dart';

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
    final notifier = ref.read(quizScreenViewModelProvider(widget.quizId).notifier);

    ref.listen(quizScreenViewModelProvider(widget.quizId), (prev, next) {
      if ((prev?.errorMessage != next.errorMessage) && (next.errorMessage?.isNotEmpty ?? false)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
        notifier.clearError();
      }
      if ((prev?.submittedAttemptId != next.submittedAttemptId) &&
          (next.submittedAttemptId?.isNotEmpty ?? false)) {
        context.push('${RoutePaths.lessonResult}?attemptId=${next.submittedAttemptId}');
        notifier.clearSubmittedAttempt();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: Builder(
        builder: (context) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.questions.isEmpty) {
            return const Center(child: Text('Quiz chua co cau hoi'));
          }
          final clampedIndex = state.currentIndex.clamp(0, state.questions.length - 1);
          final q = state.questions[clampedIndex];
          final qid = (q['questionId'] ?? q['QuestionId'] ?? '').toString();
          final content = (q['content'] ?? q['Content'] ?? q['questionText'] ?? q['QuestionText'] ?? '').toString();
          final typeRaw = q['type'] ?? q['Type'] ?? 1;
          final type = typeRaw is int ? typeRaw : int.tryParse(typeRaw.toString()) ?? 1;
          final optionsRaw = ((q['options'] ?? q['Options'] ?? q['answers'] ?? q['Answers']) as List?) ?? const [];
          final options = optionsRaw.whereType<dynamic>().map((e) {
            if (e is Map<String, dynamic>) {
              return {
                'id': (e['answerId'] ?? e['AnswerId'] ?? e['optionId'] ?? e['OptionId'] ?? e.toString()).toString(),
                'text': (e['answerText'] ?? e['AnswerText'] ?? e['optionText'] ?? e['OptionText'] ?? e.toString()).toString(),
              };
            }
            return {'id': e.toString(), 'text': e.toString()};
          }).toList();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text((state.quiz['title'] ?? state.quiz['Title'] ?? 'Quiz').toString(),
                  style: Theme.of(context).textTheme.headlineSmall),
              if (state.remainingSeconds != null) ...[
                const SizedBox(height: 8),
                Text('Thoi gian con lai: ${(state.remainingSeconds! ~/ 60).toString().padLeft(2, '0')}:${(state.remainingSeconds! % 60).toString().padLeft(2, '0')}'),
              ],
              const SizedBox(height: 12),
              if (!state.hasAttempt)
                FilledButton(
                  onPressed: state.isStarting ? null : notifier.startAttempt,
                  child: Text(state.isStarting ? 'Dang bat dau...' : 'Bat dau lam bai'),
                ),
              const SizedBox(height: 12),
              Text('Cau ${clampedIndex + 1}/${state.questions.length}', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(content),
                      const SizedBox(height: 8),
                      if (type == 4)
                        TextField(
                          enabled: state.hasAttempt,
                          decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Nhap dap an'),
                          onChanged: (v) => notifier.setTextAnswer(qid, v),
                        )
                      else if (type == 2)
                        ...options.map((o) {
                          final selected = ((state.answers[qid] as List?) ?? const []).contains(o['id']);
                          return CheckboxListTile(
                            value: selected,
                            title: Text(o['text']!),
                            onChanged: !state.hasAttempt
                                ? null
                                : (v) {
                                    notifier.toggleMultiAnswer(qid, o['id']!, v == true);
                                  },
                          );
                        })
                      else
                        ...options.map((o) {
                          final selected = state.answers[qid] == o['id'];
                          return InkWell(
                            onTap: !state.hasAttempt ? null : () => notifier.setSingleAnswer(qid, o['id']!),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: selected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                                ),
                                color: selected ? const Color(0xFFEFF6FF) : null,
                              ),
                              child: Text(o['text']!),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: clampedIndex == 0 ? null : notifier.previousQuestion,
                    child: const Text('Truoc'),
                  ),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: clampedIndex >= state.questions.length - 1
                        ? null
                        : notifier.nextQuestion,
                    child: const Text('Tiep'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: (!state.hasAttempt || state.isSubmitting) ? null : notifier.submitAttempt,
                child: Text(state.isSubmitting ? 'Dang nop bai...' : 'Nop bai'),
              ),
            ],
          );
        },
      ),
    );
  }
}
