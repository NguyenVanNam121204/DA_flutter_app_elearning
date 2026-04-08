import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router/route_paths.dart';
import '../../widgets/common/catalunya_card.dart';
import '../../widgets/common/catalunya_scaffold.dart';
import '../../widgets/common/empty_state_view.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({required this.keyword, super.key});

  final String keyword;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller;
  String _keyword = '';

  @override
  void initState() {
    super.initState();
    _keyword = widget.keyword;
    _controller = TextEditingController(text: widget.keyword);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncItems = ref.watch(searchCoursesProvider(_keyword));

    return CatalunyaScaffold(
      appBar: AppBar(title: const Text('TÃ¬m khÃ³a há»c')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CatalunyaCard(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Nháº­p tÃªn khÃ³a há»c...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                      onSubmitted: (value) => setState(() => _keyword = value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () {
                      setState(() => _keyword = _controller.text.trim());
                    },
                    icon: const Icon(Icons.tune_rounded, size: 18),
                    label: const Text('TÃ¬m'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: asyncItems.when(
                data: (items) {
                  if (items.isEmpty) {
                    return const Center(
                      child: EmptyStateView(
                        message: 'KhÃ´ng cÃ³ káº¿t quáº£ phÃ¹ há»£p',
                        icon: Icons.search_off_rounded,
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return CatalunyaCard(
                        child: ListTile(
                          title: Text(item.title),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () {
                            context.push(
                              '${RoutePaths.courseDetail}?courseId=${item.courseId}',
                            );
                          },
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('$error')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

