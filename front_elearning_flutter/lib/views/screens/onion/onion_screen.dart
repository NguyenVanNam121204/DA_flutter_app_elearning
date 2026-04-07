import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router/route_paths.dart';
import '../../../core/result/result.dart';

class OnionScreen extends ConsumerWidget {
  const OnionScreen({super.key});

  Future<List<Map<String, dynamic>>> _load(WidgetRef ref) async {
    final result = await ref.read(apiDataViewModelProvider).get(
          '/api/user/enrollments/my-courses',
          query: {'pageNumber': 1, 'pageSize': 20},
        );
    return switch (result) {
      Success(:final value) => _extract(value),
      Failure(:final error) => throw Exception(error.message),
    };
  }

  List<Map<String, dynamic>> _extract(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final data = raw['data'] ?? raw['Data'] ?? raw['items'] ?? raw['Items'];
      if (data is List) return data.whereType<Map<String, dynamic>>().toList();
    }
    return const [];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Courses')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _load(ref),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.hasError) return Center(child: Text('${snapshot.error}'));
            return const Center(child: CircularProgressIndicator());
          }
          final courses = snapshot.data!;
          if (courses.isEmpty) return const Center(child: Text('Ban chua dang ky khoa hoc nao'));
          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final c = courses[index];
              final id = (c['courseId'] ?? c['CourseId'] ?? '').toString();
              final title = (c['title'] ?? c['Title'] ?? 'Course').toString();
              return ListTile(
                title: Text(title),
                onTap: () => context.push('${RoutePaths.courseDetail}?courseId=$id'),
              );
            },
          );
        },
      ),
    );
  }
}
