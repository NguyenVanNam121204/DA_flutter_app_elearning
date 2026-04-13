import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router/route_paths.dart';
import '../gym/gym_screen.dart';
import '../home/home_screen.dart';
import '../onion/onion_screen.dart';
import '../profile/profile_screen.dart';
import '../vocabulary/vocabulary_screen.dart';

class MainTabsScreen extends ConsumerWidget {
  const MainTabsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(mainTabIndexProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pages = <Widget>[
      const HomeScreen(),
      const OnionScreen(),
      const VocabularyScreen(),
      const GymScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        height: 74,
        elevation: 6,
        backgroundColor: isDark
            ? const Color(0xFF111827)
            : Theme.of(context).colorScheme.surface,
        indicatorColor: isDark
            ? const Color(0xFF93C5FD)
            : const Color(0xFFD6ECFF),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final base = Theme.of(context).textTheme.labelMedium;
          return base?.copyWith(
            fontWeight: FontWeight.w700,
            color: states.contains(WidgetState.selected)
                ? (isDark ? const Color(0xFFE2E8F0) : const Color(0xFF14213D))
                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
          );
        }),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        selectedIndex: index,
        onDestinationSelected: (value) {
          ref.read(mainTabIndexProvider.notifier).state = value;
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_books_outlined),
            selectedIcon: Icon(Icons.library_books_rounded),
            label: 'Khóa học',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Ôn tập từ vựng',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book_rounded),
            label: 'Sổ tay từ vựng',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Tài khoản',
          ),
        ],
      ),
      floatingActionButton: index == 0
          ? FloatingActionButton.small(
              onPressed: () => context.push(RoutePaths.search),
              child: const Icon(Icons.search),
            )
          : null,
    );
  }
}
