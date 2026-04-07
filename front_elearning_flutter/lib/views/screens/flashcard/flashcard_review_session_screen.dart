import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router/route_paths.dart';

class FlashCardReviewSession extends ConsumerStatefulWidget {
  const FlashCardReviewSession({super.key});

  @override
  ConsumerState<FlashCardReviewSession> createState() => _FlashCardReviewSessionState();
}

class _FlashCardReviewSessionState extends ConsumerState<FlashCardReviewSession> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(flashcardReviewSessionViewModelProvider);
    final notifier = ref.read(flashcardReviewSessionViewModelProvider.notifier);
    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (state.cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Flashcard Review')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, size: 72, color: Colors.green),
              const SizedBox(height: 12),
              const Text('Ban da hoan thanh bai on tap hom nay'),
              const SizedBox(height: 12),
              FilledButton(onPressed: () => context.pop(), child: const Text('Quay lai')),
            ],
          ),
        ),
      );
    }
    if (state.isFinished) {
      return Scaffold(
        appBar: AppBar(title: const Text('Flashcard Review')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, size: 72, color: Colors.amber),
              const SizedBox(height: 8),
              const Text('Hoan thanh xuat sac!'),
              const SizedBox(height: 8),
              Text('Tong so tu vua on: ${state.cards.length}'),
              Text(
                'Da thuoc: ${state.mastered} • Can on lai: ${state.cards.length - state.mastered}',
              ),
              const SizedBox(height: 16),
              FilledButton(onPressed: () => context.go(RoutePaths.mainApp), child: const Text('Ve trang chu')),
            ],
          ),
        ),
      );
    }
    final card = state.cards[state.index];
    final front = (card['word'] ?? card['frontText'] ?? card['Word'] ?? '').toString();
    final back = (card['meaning'] ?? card['backText'] ?? card['Meaning'] ?? '').toString();
    return Scaffold(
      appBar: AppBar(title: Text('On tap ${state.index + 1}/${state.cards.length}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LinearProgressIndicator(value: (state.index + 1) / state.cards.length),
            const SizedBox(height: 24),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: notifier.toggleCard,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          state.showBack ? back : front,
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(state.showBack ? 'An de xem mat truoc' : 'An de lat the'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [1, 2, 3, 4, 5]
                  .map((q) => FilledButton(
                        onPressed: state.isSubmitting ? null : () => notifier.review(q),
                        child: Text('$q'),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
