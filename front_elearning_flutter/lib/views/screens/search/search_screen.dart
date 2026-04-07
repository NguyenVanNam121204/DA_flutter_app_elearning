import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router/route_paths.dart';
import '../../../core/result/result.dart';

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

  Future<List<Map<String, dynamic>>> _search() async {
    if (_keyword.trim().isEmpty) return const [];
    final result = await ref.read(lessonFeatureViewModelProvider).searchCourses(_keyword.trim());
    return switch (result) {
      Success(:final value) => value,
      Failure(:final error) => throw Exception(error.message),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Nhap ten khoa hoc...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) => setState(() => _keyword = value),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => setState(() => _keyword = _controller.text),
                  child: const Text('Tim'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _search(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    if (snapshot.hasError) return Center(child: Text('${snapshot.error}'));
                    return const Center(child: CircularProgressIndicator());
                  }
                  final items = snapshot.data!;
                  if (items.isEmpty) return const Center(child: Text('Khong co ket qua'));
                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final title = (item['title'] ?? item['Title'] ?? 'Course').toString();
                      final id = (item['courseId'] ?? item['CourseId'] ?? '').toString();
                      return ListTile(
                        title: Text(title),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('${RoutePaths.courseDetail}?courseId=$id'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
