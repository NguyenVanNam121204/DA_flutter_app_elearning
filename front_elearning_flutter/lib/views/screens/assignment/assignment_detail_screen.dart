import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router/route_paths.dart';
import '../../../core/result/result.dart';

class AssignmentDetailScreen extends ConsumerStatefulWidget {
  const AssignmentDetailScreen({
    required this.assessmentId,
    required this.moduleId,
    super.key,
  });
  final String assessmentId;
  final String moduleId;

  @override
  ConsumerState<AssignmentDetailScreen> createState() => _AssignmentDetailScreenState();
}

class _AssignmentDetailScreenState extends ConsumerState<AssignmentDetailScreen> {
  Future<Map<String, dynamic>> _load() async {
    final path = widget.assessmentId.isNotEmpty
        ? '/api/user/assessments/${widget.assessmentId}'
        : '/api/user/assessments/module/${widget.moduleId}';
    final result = await ref.read(apiDataViewModelProvider).get(path);
    return switch (result) {
      Success(:final value) => _asMap(value),
      Failure(:final error) => throw Exception(error.message),
    };
  }

  Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final data = raw['data'] ?? raw['Data'] ?? raw;
      if (data is Map<String, dynamic>) return data;
      return raw;
    }
    return const {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assignment Detail')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _load(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.hasError) return Center(child: Text('${snapshot.error}'));
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          final quizzes = ((data['quizzes'] ?? data['Quizzes']) as List?)
                  ?.whereType<Map<String, dynamic>>()
                  .toList() ??
              const <Map<String, dynamic>>[];
          final essays = ((data['essays'] ?? data['Essays']) as List?)
                  ?.whereType<Map<String, dynamic>>()
                  .toList() ??
              const <Map<String, dynamic>>[];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Quiz', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...quizzes.map((q) {
                final quizId = (q['quizId'] ?? q['QuizId'] ?? '').toString();
                final title = (q['title'] ?? q['Title'] ?? 'Quiz').toString();
                return ListTile(
                  title: Text(title),
                  onTap: () => context.push('${RoutePaths.quiz}?quizId=$quizId'),
                );
              }),
              const SizedBox(height: 16),
              Text('Essay', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...essays.map((e) {
                final essayId = (e['essayId'] ?? e['EssayId'] ?? '').toString();
                final title = (e['title'] ?? e['Title'] ?? 'Essay').toString();
                return ListTile(
                  title: Text(title),
                  onTap: () => context.push('${RoutePaths.essay}?essayId=$essayId'),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
