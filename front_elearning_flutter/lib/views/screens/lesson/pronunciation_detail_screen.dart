import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../widgets/common/catalunya_card.dart';
import '../../widgets/common/catalunya_scaffold.dart';
import '../../widgets/common/state_views.dart';

class PronunciationDetailScreen extends ConsumerWidget {
  const PronunciationDetailScreen({required this.pronunciationId, super.key});
  final String pronunciationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(pronunciationDetailProvider(pronunciationId));
    return CatalunyaScaffold(
      appBar: AppBar(title: const Text('Chi tiết phát âm')),
      body: asyncData.when(
        data: (data) {
          final word = data.word;
          final ipa = data.ipa;
          final meaning = data.meaning;
          final audio = data.audioUrl;
          final example = data.exampleSentence;
          final imageUrl = data.imageUrl;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
              if (imageUrl.isNotEmpty) const SizedBox(height: 12),
              CatalunyaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      word.isEmpty ? 'Phát âm' : word,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    if (ipa.isNotEmpty)
                      Text(
                        '/$ipa/',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    const SizedBox(height: 8),
                    if (meaning.isNotEmpty) Text(meaning),
                    if (example.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text('Ví dụ: $example'),
                    ],
                    if (audio.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: SelectableText('Audio: $audio')),
                          IconButton(
                            icon: const Icon(Icons.copy_rounded),
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(text: audio),
                              );
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã sao chép audio URL'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingStateView(),
        error: (error, _) => ErrorStateView(message: '$error'),
      ),
    );
  }
}
