import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../models/notification/notification_model.dart';
import '../../widgets/common/catalunya_scaffold.dart';
import '../../widgets/common/empty_state_view.dart';
import '../../widgets/notification/notification_list_item.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(notificationScreenViewModelProvider.notifier).initialize(),
    );
  }

  Future<void> _markAsRead(NotificationItemModel item) async {
    await ref
        .read(notificationScreenViewModelProvider.notifier)
        .markAsRead(item);
  }

  Future<void> _markAllRead() async {
    await ref.read(notificationScreenViewModelProvider.notifier).markAllRead();
  }

  String _formatTime(String value) {
    final raw = value;
    if (raw.isEmpty) return '';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return '';
    final local = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(local.hour)}:${two(local.minute)} • ${two(local.day)}/${two(local.month)}/${local.year}';
  }

  IconData _iconOf(int type) {
    switch (type) {
      case 1:
        return Icons.settings;
      case 2:
        return Icons.menu_book;
      case 3:
        return Icons.payments;
      case 4:
        return Icons.alarm;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationScreenViewModelProvider);
    Widget buildStaticBody(Widget child) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(child: child),
          ),
        ],
      );
    }

    return CatalunyaScaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          TextButton(
            onPressed: state.isActing ? null : _markAllRead,
            child: const Text('Đọc hết'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(notificationScreenViewModelProvider.notifier)
              .refresh();
        },
        child: switch ((
          state.isLoading,
          state.errorMessage.isNotEmpty,
          state.items.isEmpty,
        )) {
          (true, _, _) => buildStaticBody(const CircularProgressIndicator()),
          (_, true, true) => buildStaticBody(
            EmptyStateView(
              message: state.errorMessage,
              icon: Icons.error_outline_rounded,
            ),
          ),
          (_, _, true) => buildStaticBody(
            const EmptyStateView(
              message: 'Không có thông báo nào',
              icon: Icons.notifications_off_rounded,
            ),
          ),
          _ => ListView.builder(
            padding: const EdgeInsets.only(top: 6, bottom: 12),
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final item = state.items[index];
              return NotificationListItem(
                item: item,
                formatTime: _formatTime,
                iconOf: _iconOf,
                onTap: () => _markAsRead(item),
              );
            },
          ),
        },
      ),
    );
  }
}

