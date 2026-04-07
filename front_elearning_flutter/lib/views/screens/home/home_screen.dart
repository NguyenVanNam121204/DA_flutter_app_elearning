import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router/route_paths.dart';
import '../../widgets/home/home_header_card.dart';
import '../../widgets/home/my_courses_section.dart';
import '../../widgets/home/streak_section.dart';
import '../../widgets/home/suggested_courses_section.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(homeViewModelProvider.notifier).loadHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authViewModelProvider).user;
    final homeState = ref.watch(homeViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalunya English'),
        actions: [
          IconButton(
            tooltip: 'Dang xuat',
            onPressed: () async {
              await ref.read(authViewModelProvider.notifier).logout();
              if (context.mounted) context.go(RoutePaths.login);
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(homeViewModelProvider.notifier).loadHomeData(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            HomeHeaderCard(displayName: user?.fullName ?? 'ban'),
            const SizedBox(height: 14),
            StreakSection(
              streak: homeState.streak,
              errorMessage: homeState.errorMessage,
            ),
            const SizedBox(height: 18),
            MyCoursesSection(
              isLoading: homeState.isLoading,
              courses: homeState.myCourses,
            ),
            const SizedBox(height: 12),
            SuggestedCoursesSection(courses: homeState.suggestedCourses),
          ],
        ),
      ),
    );
  }
}
