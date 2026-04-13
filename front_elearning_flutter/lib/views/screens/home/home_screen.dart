import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../widgets/common/catalunya_reveal.dart';
import '../../widgets/common/catalunya_scaffold.dart';
import '../../widgets/home/home_header_card.dart';
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
    final displayName = (user?.displayName ?? '').trim().isEmpty
        ? 'bạn'
        : user!.displayName.trim();
    final initials = displayName
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .take(2)
        .map((e) => e[0].toUpperCase())
        .join();

    return CatalunyaScaffold(
      appBar: AppBar(
        title: const Text('Catalunya English'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () {
                ref.read(mainTabIndexProvider.notifier).state = 4;
              },
              child: CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFDFF1FF),
                backgroundImage: (user?.avatarUrl ?? '').trim().isNotEmpty
                    ? NetworkImage(user!.avatarUrl!.trim())
                    : null,
                child: (user?.avatarUrl ?? '').trim().isEmpty
                    ? Text(
                        initials.isEmpty ? 'U' : initials,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0A84FF),
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(homeViewModelProvider.notifier).loadHomeData(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            CatalunyaReveal(child: HomeHeaderCard(displayName: displayName)),
            const SizedBox(height: 14),
            CatalunyaReveal(
              delay: const Duration(milliseconds: 90),
              child: StreakSection(
                streak: homeState.streak,
                errorMessage: homeState.errorMessage,
              ),
            ),
            const SizedBox(height: 18),
            CatalunyaReveal(
              delay: const Duration(milliseconds: 160),
              child: SuggestedCoursesSection(
                courses: homeState.suggestedCourses,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
