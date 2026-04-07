import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/result/result.dart';

class TeacherLessonDetailScreen extends ConsumerWidget {
  const TeacherLessonDetailScreen({required this.lessonId, super.key});
  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Result<dynamic>>(
      future: ref.read(apiDataViewModelProvider).get('/api/teacher/lessons/$lessonId'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final result = snapshot.data!;
        if (result is Failure<dynamic>) {
          return Scaffold(body: Center(child: Text(result.error.message)));
        }
        final value = (result as Success<dynamic>).value;
        final map = value is Map<String, dynamic>
            ? ((value['data'] ?? value['Data'] ?? value) as Map<String, dynamic>)
            : <String, dynamic>{};
        final title = (map['title'] ?? map['Title'] ?? 'Lesson').toString();
        final desc = (map['description'] ?? map['Description'] ?? '').toString();
        final order = (map['orderIndex'] ?? map['OrderIndex'] ?? '').toString();
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
    );
  }
}
