// lib/app/my_app.dart
import 'dart:async';
import 'dart:io';
import 'package:assesment/core/theme/theme.dart';
import 'package:assesment/core/theme/theme_notifier.dart';
import 'package:assesment/features/onBoarding/onBoarding.dart';
import 'package:assesment/features/sigin/signin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:assesment/navigation_menu.dart';

import '../core/storage/storage_keys.dart';
import '../core/storage/storage_service.dart';

// === Auth status from token in storage ===
final isLoggedInProvider = FutureProvider<bool>((ref) async {
  final prefs = ref.read(sharedPrefsProvider);
  final token = prefs.getString(StorageKeys.token);
  return token != null && token.isNotEmpty;
});

// Onboarding flag
final seenOnboardingProvider = Provider<bool>((ref) {
  final prefs = ref.read(sharedPrefsProvider);
  return prefs.getBool(StorageKeys.onboardingSeen) ?? false;
});

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme mode from Riverpod
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: UAppTheme.lightTheme,
      darkTheme: UAppTheme.darkTheme,
      themeMode: themeMode, // Use the theme mode directly from Riverpod
      home: const _AppRoot(),
    );
  }
}

class _AppRoot extends ConsumerStatefulWidget {
  const _AppRoot();
  @override
  ConsumerState<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends ConsumerState<_AppRoot> {
  Future<void> _requestStartupPermissions() async {
    final toRequest = <Permission>[
      if (Platform.isAndroid) Permission.notification,
      // Ask other permissions just-in-time on the screen that needs them
      // Permission.camera,
      // Permission.location,
    ];
    for (final p in toRequest) {
      await p.request();
      await Future.delayed(const Duration(milliseconds: 80));
    }
  }

  @override
  void initState() {
    super.initState();

    // Show first frame asap, then do async stuff
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      FlutterNativeSplash.remove();

      // fire-and-forget tasks
      unawaited(_requestStartupPermissions());
    });
  }

  @override
  Widget build(BuildContext context) {
    final seenOnboarding = ref.watch(seenOnboardingProvider);
    if (!seenOnboarding) {
      return const OnboardingScreen();
    }

    final isLoggedInAsync = ref.watch(isLoggedInProvider);
    return isLoggedInAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => const LoginScreen(),
      data: (isLoggedIn) =>
          isLoggedIn ? const NavigationMenu() : const LoginScreen(),
    );
  }
}
