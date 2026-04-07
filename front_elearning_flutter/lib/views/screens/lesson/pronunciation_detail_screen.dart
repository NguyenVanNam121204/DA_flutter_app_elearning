import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/result/result.dart';

class PronunciationDetailScreen extends ConsumerWidget {
  const PronunciationDetailScreen({required this.pronunciationId, super.key});
  final String pronunciationId;

  Future<Map<String, dynamic>> _load(WidgetRef ref) async {
    final result = await ref
        .read(lessonFeatureViewModelProvider)
        .pronunciationDetail(pronunciationId);
    return switch (result) {
      Success(:final value) => value,
      Failure(:final error) => throw Exception(error.message),
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pronunciation Detail')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _load(ref),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.hasError) return Center(child: Text('${snapshot.error}'));
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          final word = (data['word'] ?? data['Word'] ?? '').toString();
          final ipa = (data['ipa'] ?? data['Ipa'] ?? '').toString();
          final meaning = (data['meaning'] ?? data['Meaning'] ?? '').toString();
          final audio = (data['audioUrl'] ?? data['AudioUrl'] ?? '').toString();
          final example = (data['exampleSentence'] ?? data['ExampleSentence'] ?? '').toString();
          final imageUrl = (data['imageUrl'] ?? data['ImageUrl'] ?? '').toString();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(imageUrl, height: 180, fit: BoxFit.cover),
                ),
              if (imageUrl.isNotEmpty) const SizedBox(height: 12),
              Text(word.isEmpty ? 'Pronunciation' : word,
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              if (ipa.isNotEmpty) Text('/$ipa/', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (meaning.isNotEmpty) Text(meaning),
              if (example.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text('Vi du: $example'),
              ],
              if (audio.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: SelectableText('Audio: $audio')),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: audio));
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Da copy audio url')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
