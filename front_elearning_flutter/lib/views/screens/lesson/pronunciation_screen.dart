import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router/route_paths.dart';
import '../../../core/result/result.dart';

class PronunciationScreen extends ConsumerWidget {
  const PronunciationScreen({required this.moduleId, super.key});
  final String moduleId;

  Future<List<Map<String, dynamic>>> _load(WidgetRef ref) async {
    final result = await ref.read(lessonFeatureViewModelProvider).pronunciationList(moduleId);
    return switch (result) {
      Success(:final value) => value,
      Failure(:final error) => throw Exception(error.message),
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pronunciation')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _load(ref),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.hasError) return Center(child: Text('${snapshot.error}'));
            return const Center(child: CircularProgressIndicator());
          }
          final list = snapshot.data!;
          if (list.isEmpty) return const Center(child: Text('Khong co du lieu phat am'));
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final p = list[index];
              final id = (p['pronunciationId'] ?? p['PronunciationId'] ?? '').toString();
              final word = (p['word'] ?? p['Word'] ?? 'Word').toString();
              final ipa = (p['ipa'] ?? p['Ipa'] ?? '').toString();
              final audio = (p['audioUrl'] ?? p['AudioUrl'] ?? '').toString();
              return Card(
                child: ListTile(
                  title: Text(word),
                  subtitle: Text(ipa.isEmpty ? 'Khong co phien am' : '/$ipa/'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (audio.isNotEmpty)
                        IconButton(
                          tooltip: 'Copy audio',
                          icon: const Icon(Icons.volume_up_outlined),
                          onPressed: () async {
                            await Clipboard.setData(ClipboardData(text: audio));
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Da copy link audio')),
                            );
                          },
                        ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () => context.push('${RoutePaths.pronunciationDetail}?pronunciationId=$id'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
