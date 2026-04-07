import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router/route_paths.dart';
import '../../../core/result/result.dart';

class TeacherCourseSubmissionsScreen extends ConsumerWidget {
  const TeacherCourseSubmissionsScreen({required this.essayId, super.key});
  final String essayId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Result<List<Map<String, dynamic>>>>(
      future: ref.read(teacherFeatureViewModelProvider).essaySubmissions(essayId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final result = snapshot.data!;
        if (result case Failure(:final error)) {
          return Scaffold(body: Center(child: Text(error.message)));
        }
        final items = (result as Success<List<Map<String, dynamic>>>).value;
        return Scaffold(
          appBar: AppBar(title: const Text('Essay Submissions')),
          body: items.isEmpty
              ? const Center(child: Text('Chua co bai nop nao'))
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final s = items[index];
                    final id = (s['submissionId'] ?? s['SubmissionId'] ?? '').toString();
                    final student = (s['studentName'] ?? s['StudentName'] ?? 'Hoc vien').toString();
                    final status = (s['status'] ?? s['Status'] ?? 'N/A').toString();
                    final score = (s['teacherScore'] ?? s['TeacherScore'] ?? s['score'] ?? s['Score'] ?? '-').toString();
                    return Card(
                      child: ListTile(
                        title: Text(student),
                        subtitle: Text('Status: $status • Score: $score'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('${RoutePaths.teacherSubmissionDetail}?submissionId=$id'),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
