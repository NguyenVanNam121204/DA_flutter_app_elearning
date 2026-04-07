import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/result/result.dart';

class EssayScreen extends ConsumerStatefulWidget {
  const EssayScreen({required this.essayId, super.key});
  final String essayId;

  @override
  ConsumerState<EssayScreen> createState() => _EssayScreenState();
}

class _EssayScreenState extends ConsumerState<EssayScreen> {
  final _controller = TextEditingController();
  bool _submitting = false;

  Future<Map<String, dynamic>> _loadEssay() async {
    final result = await ref.read(apiDataViewModelProvider).get('/api/user/essays/${widget.essayId}');
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

  Future<void> _submit() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _submitting = true);
    final result = await ref.read(apiDataViewModelProvider).post(
      '/api/user/essay-submissions',
      body: {'essayId': widget.essayId, 'content': _controller.text.trim()},
    );
    setState(() => _submitting = false);
    if (!mounted) return;
    final msg = switch (result) {
      Success() => 'Nop bai thanh cong',
      Failure(:final error) => error.message,
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Essay')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadEssay(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.hasError) return Center(child: Text('${snapshot.error}'));
            return const Center(child: CircularProgressIndicator());
          }
          final essay = snapshot.data!;
          final title = (essay['title'] ?? essay['Title'] ?? 'Essay').toString();
          final instruction = (essay['instruction'] ?? essay['Instruction'] ?? '').toString();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(instruction),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Noi dung bai lam',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _submitting ? null : _submit,
                child: Text(_submitting ? 'Dang nop...' : 'Nop bai'),
              ),
            ],
          );
        },
      ),
    );
  }
}
