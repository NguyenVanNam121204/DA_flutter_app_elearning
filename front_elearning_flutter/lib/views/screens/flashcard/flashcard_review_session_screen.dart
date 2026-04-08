import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router/route_paths.dart';
import '../../widgets/common/catalunya_card.dart';
import '../../widgets/common/catalunya_scaffold.dart';
import '../../widgets/common/empty_state_view.dart';
import '../../widgets/common/state_views.dart';

class FlashCardReviewSession extends ConsumerStatefulWidget {
  const FlashCardReviewSession({super.key});

  @override
  ConsumerState<FlashCardReviewSession> createState() =>
      _FlashCardReviewSessionState();
}

class _FlashCardReviewSessionState
    extends ConsumerState<FlashCardReviewSession> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(flashcardReviewSessionViewModelProvider);
    final notifier = ref.read(flashcardReviewSessionViewModelProvider.notifier);
    if (state.isLoading) {
      return const CatalunyaScaffold(body: LoadingStateView());
    }
    if (state.cards.isEmpty) {
      return CatalunyaScaffold(
        appBar: AppBar(title: const Text('Ôn tập flashcard')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const EmptyStateView(
                message: 'Bạn đã hoàn thành bài ôn tập hôm nay',
                icon: Icons.check_circle_outline,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => context.pop(),
                child: const Text('Quay lại'),
              ),
            ],
          ),
        ),
      );
    }
    if (state.isFinished) {
      return CatalunyaScaffold(
        appBar: AppBar(title: const Text('Ôn tập flashcard')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, size: 72, color: Colors.amber),
              const SizedBox(height: 8),
              const Text('Hoàn thành xuất sắc!'),
              const SizedBox(height: 8),
              Text('Tổng số từ vừa ôn: ${state.cards.length}'),
              Text(
                'Đã thuộc: ${state.mastered} • Cần ôn lại: ${state.cards.length - state.mastered}',
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go(RoutePaths.mainApp),
                child: const Text('Về trang chủ'),
              ),
            ],
          ),
        ),
      );
    }
    final card = state.cards[state.index];
    final front = card.reviewFront;
    final back = card.reviewBack;
    return CatalunyaScaffold(
      appBar: AppBar(
        title: Text('Ôn tập ${state.index + 1}/${state.cards.length}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (state.index + 1) / state.cards.length,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: notifier.toggleCard,
                child: CatalunyaCard(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          state.showBack ? back : front,
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          state.showBack
                              ? 'Ấn để xem mặt trước'
                              : 'Ấn để lật thẻ',
                        ),
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
                  .map(
                    (q) => FilledButton(
                      onPressed: state.isSubmitting
                          ? null
                          : () => notifier.review(q),
                      child: Text('$q'),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
