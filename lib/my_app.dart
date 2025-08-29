// // lib/app/my_app.dart (Simpler version using authStateProvider)
// import 'dart:io';
// import 'package:assesment/core/storage/storage_keys.dart';
// import 'package:assesment/core/storage/storage_service.dart';
// import 'package:assesment/core/theme/theme.dart';
// import 'package:assesment/core/theme/theme_notifier.dart';
// import 'package:assesment/features/onBoarding/onBoarding.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'package:assesment/navigation_menu.dart';

// import 'package:assesment/features/auth/provider/auth_state_provider.dart'; // Add this
// import 'package:assesment/features/signin/signin.dart';

// // Onboarding flag
// final seenOnboardingProvider = Provider<bool>((ref) {
//   final prefs = ref.read(sharedPrefsProvider);
//   return prefs.getBool(StorageKeys.onboardingSeen) ?? false;
// });

// class MyApp extends ConsumerWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final themeMode = ref.watch(themeModeProvider);

//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: UAppTheme.lightTheme,
//       darkTheme: UAppTheme.darkTheme,
//       themeMode: themeMode,
//       home: const _AppRoot(),
//     );
//   }
// }

// class _AppRoot extends ConsumerStatefulWidget {
//   const _AppRoot();
//   @override
//   ConsumerState<_AppRoot> createState() => _AppRootState();
// }

// class _AppRoot extends ConsumerWidget {
//   const _AppRoot({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final seenOnboarding = ref.watch(seenOnboardingProvider);
//     if (!seenOnboarding) {
//       return const OnboardingScreen();
//     }

//     final isLoggedIn = ref.watch(authProvider);
//     return isLoggedIn ? const NavigationMenu() : const LoginScreen();
//   }
// }
