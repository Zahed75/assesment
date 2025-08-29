// lib/app/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:assesment/core/storage/storage_service.dart';
import 'package:assesment/features/auth/provider/auth_state_provider.dart';
import 'package:assesment/app/router/routes.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    final storageService = ref.read(storageServiceProvider);

    // Add a small delay for splash screen
    await Future.delayed(const Duration(seconds: 2));

    try {
      // Get the auth state provider and await its result properly
      final authState = ref.read(authStateProvider);

      // Use when() to handle the AsyncValue
      authState.when(
        data: (isLoggedIn) {
          final seenOnboarding = storageService.onboardingSeen;

          if (!context.mounted) return;

          if (!seenOnboarding) {
            context.go(Routes.onboarding);
          } else if (isLoggedIn) {
            context.go(Routes.home);
          } else {
            context.go(Routes.signIn);
          }
        },
        loading: () {
          // If still loading, wait a bit more and check again
          Future.delayed(const Duration(seconds: 1), _checkAuthAndNavigate);
        },
        error: (error, stackTrace) {
          if (!context.mounted) return;
          context.go(Routes.signIn);
        },
      );
    } catch (error) {
      if (!context.mounted) return;
      context.go(Routes.signIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your custom logo
            Image.asset(
              'assets/icons/circleIcon.png',
              width: 100, // Adjust size as needed
              height: 100, // Adjust size as needed
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
