import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'data/local/hive_service.dart';
import 'providers/daily_log_provider.dart';
import 'providers/focus_timer_provider.dart';
import 'providers/reflection_provider.dart';
import 'providers/preferences_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/security_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/github_provider.dart';
import 'providers/leetcode_provider.dart';
import 'providers/srs_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/security/pin_lock_screen.dart';

/// Root application widget
class DisciplineApp extends StatelessWidget {
  const DisciplineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeApp(),
      builder: (context, snapshot) {
        // Show loading screen while initializing
        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            home: const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        // Show error screen if initialization failed
        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to initialize app',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // App initialized successfully, create providers
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => SecurityProvider()),
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => ProfileProvider()),
            ChangeNotifierProvider(create: (_) => DailyLogProvider()),
            ChangeNotifierProvider(create: (_) => FocusTimerProvider()),
            ChangeNotifierProvider(create: (_) => ReflectionProvider()),
            ChangeNotifierProvider(create: (_) => PreferencesProvider()),
            ChangeNotifierProvider(create: (_) => GithubProvider()),
            ChangeNotifierProvider(create: (_) => LeetCodeProvider()),
            ChangeNotifierProvider(create: (_) => SrsProvider()),
          ],
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                title: AppStrings.appName,
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light(seedColor: themeProvider.seedColor),
                darkTheme: AppTheme.dark(seedColor: themeProvider.seedColor),
                themeMode: themeProvider.themeMode,
                home: const _SecurityGate(child: HomeScreen()),
              );
            },
          ),
        );
      },
    );
  }

  /// Initialize Hive and other async dependencies
  Future<void> _initializeApp() async {
    await HiveService.init();
  }
}

class _SecurityGate extends StatelessWidget {
  final Widget child;

  const _SecurityGate({required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<SecurityProvider>(
      builder: (context, security, _) {
        if (security.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (security.locked) {
          return const PinLockScreen();
        }
        return child;
      },
    );
  }
}
