import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router/route_paths.dart';
import '../../widgets/common/catalunya_nav_tile.dart';
import '../../widgets/common/catalunya_scaffold.dart';
import '../../widgets/common/empty_state_view.dart';
import '../../widgets/common/state_views.dart';

class ModuleLearningScreen extends ConsumerStatefulWidget {
  const ModuleLearningScreen({required this.moduleId, super.key});
  final String moduleId;

  @override
  ConsumerState<ModuleLearningScreen> createState() =>
      _ModuleLearningScreenState();
}

class _ModuleLearningScreenState extends ConsumerState<ModuleLearningScreen> {
  @override
  Widget build(BuildContext context) {
    final asyncLectures = ref.watch(moduleLecturesProvider(widget.moduleId));
    return CatalunyaScaffold(
      appBar: AppBar(title: const Text('Học theo module')),
      body: asyncLectures.when(
        data: (lectures) {
          if (lectures.isEmpty) {
            return const Center(
              child: EmptyStateView(
                message: 'Không có bài giảng hoặc module đang được cập nhật',
                icon: Icons.menu_book_outlined,
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lectures.length,
            itemBuilder: (context, index) {
              final item = lectures[index];
              return CatalunyaNavTile(
                title: item.title,
                subtitle: 'Mở bài giảng',
                onTap: () => context.push(
                  '${RoutePaths.lectureDetail}?lectureId=${item.lectureId}',
                ),
              );
            },
          );
        },
        loading: () => const LoadingStateView(),
        error: (error, _) => ErrorStateView(message: '$error'),
      ),
    );
  }
}
