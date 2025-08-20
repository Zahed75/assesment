// lib/navigation_menu.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

class NavigationMenu extends ConsumerWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: ref.watch(selectedIndexProvider) == 0
            ? const HomeScreen()
            : const ComingSoon(), // Placeholder for other screens
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(dark ? 0.35 : 0.08),
                  blurRadius: 24,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  color: dark ? Colors.black12 : Colors.grey[100],
                  border: Border.all(
                    color: dark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.05),
                  ).withOpacity(0.08),
                ),
                child: NavigationBar(
                  height: 64,
                  elevation: 0,
                  backgroundColor: dark ? Colors.black12 : Colors.grey[100],
                  indicatorColor: dark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.08),
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  selectedIndex: ref.watch(selectedIndexProvider),
                  onDestinationSelected: (index) {
                    ref.read(selectedIndexProvider.notifier).state = index;
                    switch (index) {
                      case 0:
                        context.go(Routes.home);
                        break;
                      case 1:
                        context.go(Routes.result);
                        break;
                      case 2:
                        context.go(Routes.dashboard);
                        break;
                      case 3:
                        context.go(Routes.profile);
                        break;
                    }
                  },
                  destinations: [
                    const NavigationDestination(
                      icon: Icon(Iconsax.home),
                      label: 'Home',
                    ),
                    const NavigationDestination(
                      icon: Icon(Iconsax.shop),
                      label: 'History',
                    ),
                    const NavigationDestination(
                      icon: Icon(Iconsax.menu_board),
                      label: 'Dashboard',
                    ),
                    const NavigationDestination(
                      icon: Icon(Iconsax.user),
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// For Riverpod navigation state management
final selectedIndexProvider = StateProvider<int>((ref) => 0);
