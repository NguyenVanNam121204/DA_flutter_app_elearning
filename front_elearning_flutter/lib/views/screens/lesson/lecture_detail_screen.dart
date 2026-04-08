import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';

class LectureDetailScreen extends ConsumerWidget {
  const LectureDetailScreen({required this.lectureId, super.key});
  final String lectureId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(lectureDetailProvider(lectureId));
    return Scaffold(
      appBar: AppBar(title: const Text('Lecture Detail')),
      body: asyncData.when(
        data: (data) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                data.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              if (data.videoUrl.isNotEmpty)
                SelectableText(
                  'Video: ${data.videoUrl}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              if (data.videoUrl.isNotEmpty) const SizedBox(height: 12),
              Text(
                data.content.isEmpty ? 'Nội dung đang cập nhật.' : data.content,
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
      ),
    );
  }
}
