import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router/route_paths.dart';

class FlashCardLearningScreen extends ConsumerStatefulWidget {
  const FlashCardLearningScreen({required this.lessonId, super.key});
  final String lessonId;

  @override
  ConsumerState<FlashCardLearningScreen> createState() => _FlashCardLearningScreenState();
}

class _FlashCardLearningScreenState extends ConsumerState<FlashCardLearningScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(flashcardLearningViewModelProvider(widget.lessonId));
    final notifier =
        ref.read(flashcardLearningViewModelProvider(widget.lessonId).notifier);
    if (state.isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (state.cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Flashcard Learning')),
        body: const Center(child: Text('Chua co flashcard')),
      );
    }
    final c = state.cards[state.index];
    final word = (c['term'] ?? c['Term'] ?? c['frontText'] ?? c['word'] ?? c['Word'] ?? '').toString();
    final definition = (c['definition'] ?? c['Definition'] ?? c['backText'] ?? c['meaning'] ?? c['Meaning'] ?? '').toString();
    final pronunciation = (c['pronunciation'] ?? c['Pronunciation'] ?? '').toString();
    final example = (c['exampleSentence'] ?? c['ExampleSentence'] ?? '').toString();
    final audioUrl = (c['audioUrl'] ?? c['AudioUrl'] ?? '').toString();
    final imageUrl = (c['imageUrl'] ?? c['ImageUrl'] ?? '').toString();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcard Learning'),
        actions: [
          IconButton(
            tooltip: 'Pronunciation',
            onPressed: () => context.push(RoutePaths.flashcardReview),
            icon: const Icon(Icons.mic),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LinearProgressIndicator(value: (state.index + 1) / state.cards.length),
            const SizedBox(height: 8),
            Text('${state.index + 1} / ${state.cards.length}'),
            const SizedBox(height: 16),
            Expanded(
              child: GestureDetector(
                onTap: notifier.toggleCard,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Card(
                    key: ValueKey(state.flipped),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (imageUrl.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Image.network(imageUrl, height: 140, fit: BoxFit.contain),
                            ),
                          Text(
                            state.flipped ? (example.isEmpty ? definition : example) : word,
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
                            Text('Nghia: $definition', textAlign: TextAlign.center),
                          ],
                          const SizedBox(height: 16),
                          Text(state.flipped ? 'An de lat lai' : 'An de xem mat sau'),
                          if (audioUrl.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            SelectableText('Audio: $audioUrl', textAlign: TextAlign.center),
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
                    child: const Text('Truoc'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      final done = notifier.next();
                      if (done) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ban da hoc xong tat ca flashcards')),
                        );
                        context.pop();
                      }
                    },
                    child: Text(
                      state.index == state.cards.length - 1 ? 'Hoan thanh' : 'Tiep theo',
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
