import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router/route_paths.dart';
import '../../../core/result/result.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<Map<String, dynamic>> _load(WidgetRef ref) async {
    final result = await ref.read(apiDataViewModelProvider).get('/api/auth/profile');
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
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _load(ref),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.hasError) return Center(child: Text('${snapshot.error}'));
            return const Center(child: CircularProgressIndicator());
          }
          final p = snapshot.data!;
          final fullName = (p['fullName'] ?? p['FullName'] ?? '-').toString();
          final email = (p['email'] ?? p['Email'] ?? '-').toString();
          final role = (p['role'] ?? p['Role'] ?? '-').toString();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(title: const Text('Ho ten'), subtitle: Text(fullName)),
              ListTile(title: const Text('Email'), subtitle: Text(email)),
              ListTile(title: const Text('Role'), subtitle: Text(role)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => context.push(RoutePaths.pro),
        child: const Icon(Icons.workspace_premium_outlined),
      ),
    );
  }
}
