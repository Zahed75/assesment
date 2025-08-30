// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart'; // Add this import
import 'package:assesment/core/theme/theme.dart';
import 'package:assesment/core/theme/theme_notifier.dart';
import 'package:assesment/core/storage/storage_service.dart';
import 'package:assesment/app/router/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:assesment/utils/helpers/update_checker.dart'; // Add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage
  final sharedPrefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPrefsProvider.overrideWithValue(sharedPrefs)],
      child: const MyApp(),
    ),
  );
}

// Add AppLifecycleManager class here
class AppLifecycleManager extends ConsumerStatefulWidget {
  final Widget child;

  const AppLifecycleManager({super.key, required this.child});

  @override
  ConsumerState<AppLifecycleManager> createState() =>
      _AppLifecycleManagerState();
}

class _AppLifecycleManagerState extends ConsumerState<AppLifecycleManager>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Check for updates when app comes to foreground
      UpdateChecker.checkForUpdates(context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// Update MyApp to use AppLifecycleManager
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);

    return AppLifecycleManager(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: UAppTheme.lightTheme,
        darkTheme: UAppTheme.darkTheme,
        themeMode: themeMode,
        routerConfig: router,
      ),
    );
  }
}
