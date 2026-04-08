import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router/route_paths.dart';
import '../../widgets/common/catalunya_card.dart';
import '../../widgets/common/catalunya_scaffold.dart';
import '../../widgets/common/empty_state_view.dart';
import '../../widgets/common/state_views.dart';

class FlashCardLearningScreen extends ConsumerStatefulWidget {
  const FlashCardLearningScreen({required this.lessonId, super.key});
  final String lessonId;

  @override
  ConsumerState<FlashCardLearningScreen> createState() =>
      _FlashCardLearningScreenState();
}

class _FlashCardLearningScreenState
    extends ConsumerState<FlashCardLearningScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      flashcardLearningViewModelProvider(widget.lessonId),
    );
    final notifier = ref.read(
      flashcardLearningViewModelProvider(widget.lessonId).notifier,
    );
    if (state.isLoading) {
      return const CatalunyaScaffold(body: LoadingStateView());
    }
    if (state.cards.isEmpty) {
      return CatalunyaScaffold(
        appBar: AppBar(title: Text('Học flashcard')),
        body: Center(
          child: EmptyStateView(
            message: 'Chưa có flashcard',
            icon: Icons.style_outlined,
          ),
        ),
      );
    }
    final c = state.cards[state.index];
    final word = c.term;
    final definition = c.definition;
    final pronunciation = c.pronunciation;
    final example = c.exampleSentence;
    final audioUrl = c.audioUrl;
    final imageUrl = c.imageUrl;
    return CatalunyaScaffold(
      appBar: AppBar(
        title: const Text('Học flashcard'),
        actions: [
          IconButton(
            tooltip: 'Ôn phát âm',
            onPressed: () => context.push(RoutePaths.flashcardReview),
            icon: const Icon(Icons.mic),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (state.index + 1) / state.cards.length,
            ),
            const SizedBox(height: 8),
            Text('${state.index + 1} / ${state.cards.length}'),
            const SizedBox(height: 16),
            Expanded(
              child: GestureDetector(
                onTap: notifier.toggleCard,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: CatalunyaCard(
                    key: ValueKey(state.flipped),
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (imageUrl.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Image.network(
                                imageUrl,
                                height: 140,
                                fit: BoxFit.contain,
                              ),
                            ),
                          Text(
                            state.flipped
                                ? (example.isEmpty ? definition : example)
                                : word,
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          if (!state.flipped && pronunciation.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text('/$pronunciation/'),
                          ],
                          if (!state.flipped && definition.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(definition, textAlign: TextAlign.center),
                          ],
                          if (state.flipped && example.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Nghĩa: $definition',
                              textAlign: TextAlign.center,
                            ),
                          ],
                          const SizedBox(height: 16),
                          Text(
                            state.flipped
                                ? 'Ấn để lật lại'
                                : 'Ấn để xem mặt sau',
                          ),
                          if (audioUrl.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            SelectableText(
                              'Audio: $audioUrl',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: state.index == 0 ? null : notifier.previous,
                    child: const Text('Trước'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      final done = notifier.next();
                      if (done) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Bạn đã học xong tất cả flashcard'),
                          ),
                        );
                        context.pop();
                      }
                    },
                    child: Text(
                      state.index == state.cards.length - 1
                          ? 'Hoàn thành'
                          : 'Tiếp theo',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
