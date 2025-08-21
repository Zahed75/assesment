// lib/navigation_menu.dart
import 'package:assesment/features/dashboard/coming_soon.dart';
import 'package:assesment/features/dashboard/dashboard.dart';
import 'package:assesment/features/home/home.dart';
import 'package:assesment/features/result/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

final selectedIndexProvider = StateProvider<int>((ref) => 0);

class NavigationMenu extends ConsumerWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final index = ref.watch(selectedIndexProvider);

    Widget body;
    switch (index) {
      case 0:
        body = const HomeScreen();
        break;
      case 1:
        body = const ResultScreen(responseId: 0); // ⬅️ pass dummy id for now
        break;
      case 2:
        body = const DashboardScreen();
        break;
      case 3:
        body = const ComingSoon();
        break;
      default:
        body = const HomeScreen();
    }

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: body,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                color: dark ? Colors.black12 : Colors.grey[100],
                border: Border.all(
                  color: dark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.05),
                ),
              ),
              child: NavigationBar(
                height: 64,
                elevation: 0,
                backgroundColor: dark ? Colors.black12 : Colors.grey[100],
                indicatorColor: dark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.08),
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                selectedIndex: index,
                onDestinationSelected: (i) =>
                ref.read(selectedIndexProvider.notifier).state = i,
                destinations: const [
                  NavigationDestination(icon: Icon(Iconsax.home), label: 'Home'),
                  NavigationDestination(icon: Icon(Iconsax.shop), label: 'History'),
                  NavigationDestination(icon: Icon(Iconsax.menu_board), label: 'Dashboard'),
                  NavigationDestination(icon: Icon(Iconsax.user), label: 'Profile'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
