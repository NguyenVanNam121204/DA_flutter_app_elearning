import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router/route_paths.dart';
import '../../widgets/common/catalunya_nav_tile.dart';
import '../../widgets/common/catalunya_scaffold.dart';
import '../../widgets/common/state_views.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProfile = ref.watch(profileDataProvider);
    return CatalunyaScaffold(
      appBar: AppBar(title: const Text('Hồ sơ cá nhân')),
      body: asyncProfile.when(
        data: (p) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [
              CatalunyaNavTile(
                title: 'Họ tên',
                subtitle: p.fullName,
                leading: const Icon(Icons.person_rounded),
                trailing: const SizedBox.shrink(),
              ),
              CatalunyaNavTile(
                title: 'Email',
                subtitle: p.email,
                leading: const Icon(Icons.email_rounded),
                trailing: const SizedBox.shrink(),
              ),
              CatalunyaNavTile(
                title: 'Vai trò',
                subtitle: p.role,
                leading: const Icon(Icons.badge_rounded),
                trailing: const SizedBox.shrink(),
              ),
            ],
          );
        },
        loading: () => const LoadingStateView(),
        error: (error, _) => ErrorStateView(message: '$error'),
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => context.push(RoutePaths.pro),
        child: const Icon(Icons.workspace_premium_outlined),
      ),
    );
  }
}
