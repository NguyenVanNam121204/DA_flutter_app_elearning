import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../widgets/common/catalunya_scaffold.dart';
import '../../widgets/common/empty_state_view.dart';
import '../../widgets/common/state_views.dart';
import '../../widgets/teacher/teacher_info_list_tile.dart';

class TeacherClassListScreen extends ConsumerWidget {
  const TeacherClassListScreen({required this.courseId, super.key});
  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncStudents = ref.watch(teacherClassStudentsDataProvider(courseId));
    return asyncStudents.when(
      data: (list) => CatalunyaScaffold(
        appBar: AppBar(title: const Text('Danh sách học viên')),
        body: list.isEmpty
            ? const Center(
                child: EmptyStateView(
                  message: 'Chưa có học viên nào',
                  icon: Icons.groups_outlined,
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final s = list[index];
                  final name = s.fullName;
                  final email = s.email;
                  return TeacherInfoListTile(
                    title: name,
                    subtitle: email,
                    leading: CircleAvatar(
                      child: Text(name.isEmpty ? '?' : name[0].toUpperCase()),
                    ),
                    trailing: const Icon(Icons.mail_outline_rounded),
                  );
                },
              ),
      ),
      loading: () => const CatalunyaScaffold(body: LoadingStateView()),
      error: (error, _) =>
          CatalunyaScaffold(body: ErrorStateView(message: '$error')),
    );
  }
}
