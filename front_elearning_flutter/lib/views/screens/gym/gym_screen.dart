import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/result/result.dart';

class GymScreen extends ConsumerWidget {
  const GymScreen({super.key});

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
    }
    return const [];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gym')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _load(ref),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.hasError) return Center(child: Text('${snapshot.error}'));
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!;
          if (items.isEmpty) return const Center(child: Text('Khong co tu de luyen'));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final word = (item['word'] ?? item['Word'] ?? '').toString();
              final meaning = (item['meaning'] ?? item['Meaning'] ?? '').toString();
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.fitness_center),
                  title: Text(word),
                  subtitle: Text(meaning),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
