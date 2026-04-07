import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/result/result.dart';

class VocabularyScreen extends ConsumerWidget {
  const VocabularyScreen({super.key});

  Future<List<Map<String, dynamic>>> _load(WidgetRef ref) async {
    final result = await ref.read(apiDataViewModelProvider).get('/api/user/vocabulary/notebook');
    return switch (result) {
      Success(:final value) => _extract(value),
      Failure(:final error) => throw Exception(error.message),
    };
  }

  List<Map<String, dynamic>> _extract(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final data = raw['data'] ?? raw['Data'];
      if (data is List) return data.whereType<Map<String, dynamic>>().toList();
    } else if (raw is List) {
      return raw.whereType<Map<String, dynamic>>().toList();
    }
    return const [];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vocabulary')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _load(ref),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.hasError) return Center(child: Text('${snapshot.error}'));
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!;
          if (items.isEmpty) return const Center(child: Text('Notebook trong'));
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              final word = (item['word'] ?? item['Word'] ?? '').toString();
              final meaning = (item['meaning'] ?? item['Meaning'] ?? '').toString();
              return ListTile(title: Text(word), subtitle: Text(meaning));
            },
          );
        },
      ),
    );
  }
}
