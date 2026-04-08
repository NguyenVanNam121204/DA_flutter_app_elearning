import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';

class TeacherLessonDetailScreen extends ConsumerWidget {
  const TeacherLessonDetailScreen({required this.lessonId, super.key});
  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDetail = ref.watch(teacherLessonDetailDataProvider(lessonId));
    return asyncDetail.when(
      data: (lesson) {
        final title = lesson.title;
        final desc = lesson.description;
        final order = lesson.orderIndex;
        return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                if (order.isNotEmpty) Text('Thu tu bai: $order'),
                const SizedBox(height: 8),
                Text(desc.isEmpty ? 'Chua co mo ta bai hoc' : desc),
              ],
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(body: Center(child: Text('$error'))),
    );
  }
}
