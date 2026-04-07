import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/result/result.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  late Future<List<Map<String, dynamic>>> _future;
  List<Map<String, dynamic>> _items = const [];

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final result = await ref.read(apiDataViewModelProvider).get('/api/user/notifications');
    if (result case Failure(:final error)) throw Exception(error.message);
    final value = (result as Success<dynamic>).value;
    final data = value is Map<String, dynamic> ? (value['data'] ?? value['Data'] ?? const []) : const [];
    final list = data is List ? data.whereType<Map<String, dynamic>>().toList() : <Map<String, dynamic>>[];
    _items = list;
    return list;
  }

  Future<void> _markAsRead(Map<String, dynamic> item) async {
    final id = (item['id'] ?? item['Id'] ?? '').toString();
    if (id.isEmpty) return;
    await ref.read(apiDataViewModelProvider).put('/api/user/notifications/$id/mark-as-read');
    if (!mounted) return;
    setState(() {
      _items = _items
          .map((n) => (n['id'] ?? n['Id']).toString() == id ? {...n, 'isRead': true, 'IsRead': true} : n)
          .toList();
    });
  }

  Future<void> _markAllRead() async {
    await ref.read(apiDataViewModelProvider).put('/api/user/notifications/mark-all-read');
    if (!mounted) return;
    setState(() {
      _items = _items.map((n) => {...n, 'isRead': true, 'IsRead': true}).toList();
    });
  }

  String _formatTime(dynamic value) {
    final raw = value?.toString();
    if (raw == null || raw.isEmpty) return '';
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
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          if (snapshot.hasError) return Scaffold(body: Center(child: Text('${snapshot.error}')));
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final items = _items;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Thong bao'),
            actions: [
              TextButton(onPressed: _markAllRead, child: const Text('Doc het')),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              final list = await _load();
              if (mounted) setState(() => _items = list);
            },
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final title = (item['title'] ?? item['Title'] ?? 'Notification').toString();
                final body = (item['message'] ?? item['Message'] ?? '').toString();
                final createdAt = item['createdAt'] ?? item['CreatedAt'];
                final typeRaw = item['type'] ?? item['Type'] ?? 0;
                final isRead = (item['isRead'] ?? item['IsRead'] ?? false) == true;
                final type = typeRaw is int ? typeRaw : int.tryParse(typeRaw.toString()) ?? 0;
                return InkWell(
                  onTap: () => _markAsRead(item),
                  child: Container(
                    color: isRead ? null : const Color(0xFFF0F7FF),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFFEFF2FF),
                          child: Icon(_iconOf(type), color: Theme.of(context).colorScheme.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: TextStyle(fontWeight: isRead ? FontWeight.w500 : FontWeight.w700),
                                    ),
                                  ),
                                  if (!isRead)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(body),
                              const SizedBox(height: 4),
                              Text(_formatTime(createdAt), style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
