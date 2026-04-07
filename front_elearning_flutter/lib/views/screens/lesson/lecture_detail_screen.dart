import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/result/result.dart';

class LectureDetailScreen extends ConsumerWidget {
  const LectureDetailScreen({required this.lectureId, super.key});
  final String lectureId;

  Future<Map<String, dynamic>> _load(WidgetRef ref) async {
    final result = await ref.read(lessonFeatureViewModelProvider).lectureDetail(lectureId);
    return switch (result) {
      Success(:final value) => value,
      Failure(:final error) => throw Exception(error.message),
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lecture Detail')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _load(ref),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.hasError) return Center(child: Text('${snapshot.error}'));
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          final title = (data['title'] ?? data['Title'] ?? 'Lecture').toString();
          final content = (data['content'] ?? data['Content'] ?? '').toString();
          final videoUrl = (data['videoUrl'] ?? data['VideoUrl'] ?? '').toString();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              if (videoUrl.isNotEmpty)
                SelectableText('Video: $videoUrl', style: Theme.of(context).textTheme.bodySmall),
              if (videoUrl.isNotEmpty) const SizedBox(height: 12),
              Text(content.isEmpty ? 'Noi dung dang cap nhat.' : content),
            ],
          );
        },
      ),
    );
  }
}
