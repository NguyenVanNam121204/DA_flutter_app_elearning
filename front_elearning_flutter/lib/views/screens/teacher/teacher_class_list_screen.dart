import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/result/result.dart';

class TeacherClassListScreen extends ConsumerWidget {
  const TeacherClassListScreen({required this.courseId, super.key});
  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Result<List<Map<String, dynamic>>>>(
      future: ref.read(teacherFeatureViewModelProvider).classStudents(courseId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final result = snapshot.data!;
        if (result case Failure(:final error)) {
          return Scaffold(body: Center(child: Text(error.message)));
        }
        final list = (result as Success<List<Map<String, dynamic>>>).value;
        return Scaffold(
          appBar: AppBar(title: const Text('Danh sach hoc vien')),
          body: list.isEmpty
              ? const Center(child: Text('Chua co hoc vien nao'))
              : ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final s = list[index];
                    final name = (s['fullName'] ?? s['FullName'] ?? 'Hoc vien').toString();
                    final email = (s['email'] ?? s['Email'] ?? '').toString();
                    return ListTile(
                      leading: CircleAvatar(child: Text(name.isEmpty ? '?' : name[0].toUpperCase())),
                      title: Text(name),
                      subtitle: Text(email),
                    );
                  },
                ),
        );
      },
    );
  }
}
