import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router/route_paths.dart';
import '../../widgets/common/catalunya_card.dart';
import '../../widgets/common/catalunya_nav_tile.dart';
import '../../widgets/common/catalunya_scaffold.dart';
import '../../widgets/common/state_views.dart';

class LessonDetailScreen extends ConsumerStatefulWidget {
  const LessonDetailScreen({required this.lessonId, super.key});
  final String lessonId;

  @override
  ConsumerState<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends ConsumerState<LessonDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(lessonDetailBundleProvider(widget.lessonId));
    return CatalunyaScaffold(
      appBar: AppBar(title: const Text('Chi tiết bài học')),
      body: asyncData.when(
        data: (data) {
          final lesson = data.lesson;
          final modules = data.modules;
          final title = lesson.title;
          final description = lesson.description;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CatalunyaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    if (description.isNotEmpty) Text(description),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const SizedBox(height: 16),
              Text(
                'Nội dung bài học',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...modules.map((m) {
                final moduleId = m.moduleId;
                final name = m.name;
                final type = m.contentType;
                return CatalunyaNavTile(
                  title: name,
                  subtitle: 'Loại nội dung: $type',
                  onTap: () {
                    if (type == 3) {
                      context.push(
                        '${RoutePaths.assignmentDetail}?moduleId=$moduleId',
                      );
                    } else {
                      context.push(
                        '${RoutePaths.moduleLearning}?moduleId=$moduleId',
                      );
                    }
                  },
                );
              }),
            ],
          );
        },
        loading: () => const LoadingStateView(),
        error: (error, _) => ErrorStateView(message: '$error'),
      ),
    );
  }
}
