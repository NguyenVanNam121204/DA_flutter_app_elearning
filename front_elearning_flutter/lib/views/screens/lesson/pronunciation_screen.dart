import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router/route_paths.dart';
import '../../widgets/common/catalunya_nav_tile.dart';
import '../../widgets/common/catalunya_scaffold.dart';
import '../../widgets/common/empty_state_view.dart';
import '../../widgets/common/state_views.dart';

class PronunciationScreen extends ConsumerWidget {
  const PronunciationScreen({required this.moduleId, super.key});

  final String moduleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncList = ref.watch(pronunciationListProvider(moduleId));

    return CatalunyaScaffold(
      appBar: AppBar(title: const Text('Luyện phát âm')),
      body: asyncList.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: EmptyStateView(
                message: 'Không có dữ liệu phát âm',
                icon: Icons.graphic_eq_rounded,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final p = list[index];
              final audio = p.audioUrl;
              return CatalunyaNavTile(
                title: p.word,
                subtitle: p.ipa.isEmpty ? 'Không có phiên âm' : '/${p.ipa}/',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (audio.isNotEmpty)
                      IconButton(
                        tooltip: 'Sao chép link audio',
                        icon: const Icon(Icons.volume_up_outlined),
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: audio));
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã sao chép link audio'),
                            ),
                          );
                        },
                      ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
                onTap: () => context.push(
                  '${RoutePaths.pronunciationDetail}?pronunciationId=${p.pronunciationId}',
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
