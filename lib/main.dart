import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:camera/camera.dart';
import 'l10n/app_localizations.dart';
import 'firebase_options.dart';
import 'config/env_config.dart';
import 'config/app_theme.dart';
import 'auth/screens/login_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth/screens/register_screen.dart';
import 'authed/authed_layout.dart';
import 'providers/auth_provider.dart';
import 'providers/language_provider.dart';
import 'providers/user_provider.dart';
import 'pages/profile_setup_page.dart';
import 'authed/onboarding/onboarding_flow.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Global cameras variable
late List<CameraDescription> cameras;

// Custom page transition builder with no animation
class NoAnimationPageTransitionsBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T extends Object?>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

// เพิ่มฟังก์ชันตรวจ onboarding
Future<bool> _isOnboardingDone() async {
  final sp = await SharedPreferences.getInstance();
  return sp.getBool('onboarding_done') ?? false;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // Load environment variables
  await EnvConfig.load();

  // Initialize cameras
  try {
    cameras = await availableCameras();
  } catch (e) {
    cameras = [];
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
  // Use stable auth state provider per project conventions (no artificial delay)
  final authState = ref.watch(authStateChangesProvider);
    final locale = ref.watch(languageProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wellness Tracker',

      // Localization support
      locale: locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('th')],

      // Use custom themes with dark as default
      theme: AppTheme.lightTheme.copyWith(
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: NoAnimationPageTransitionsBuilder(),
            TargetPlatform.iOS: NoAnimationPageTransitionsBuilder(),
            TargetPlatform.windows: NoAnimationPageTransitionsBuilder(),
            TargetPlatform.macOS: NoAnimationPageTransitionsBuilder(),
            TargetPlatform.linux: NoAnimationPageTransitionsBuilder(),
          },
        ),
      ),
      darkTheme: AppTheme.darkTheme.copyWith(
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: NoAnimationPageTransitionsBuilder(),
            TargetPlatform.iOS: NoAnimationPageTransitionsBuilder(),
            TargetPlatform.windows: NoAnimationPageTransitionsBuilder(),
            TargetPlatform.macOS: NoAnimationPageTransitionsBuilder(),
            TargetPlatform.linux: NoAnimationPageTransitionsBuilder(),
          },
        ),
      ),
      themeMode: ThemeMode.dark, // Default to dark theme
      routes: {
        '/register': (c) => const RegisterScreen(),
        '/authed': (c) => const AuthedLayout(),
        '/onboarding': (c) => const OnboardingFlow(),
      },
      // Debug: force onboarding every launch for QA
      home: FutureBuilder<bool>(
        future: _isOnboardingDone(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const SizedBox.shrink();
          }
          final onboardingDone = EnvConfig.forceOnboardingEveryLaunch ? false : (snap.data ?? false);

          // 1) Onboarding first (once)
          if (!onboardingDone) {
            return const OnboardingFlow();
          }

          // 2) Auth: Login/Register
          return authState.when(
            data: (user) {
              if (user == null) return const LoginScreen();

              // 3) After auth, check profile setup flag from user doc
              return Consumer(
                builder: (context, ref, _) {
                  final userDoc = ref.watch(currentUserProvider);
                  return userDoc.when(
                    data: (u) {
                      final isComplete = u?.isProfileSetupComplete ?? false;
                      if (!isComplete) {
                        return const ProfileSetupPage();
                      }
                      // 4) Home (AuthedLayout)
                      return const AuthedLayout();
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const AuthedLayout(), // fallback to home; AuthedLayout will handle
                  );
                },
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const Center(child: Text('Error loading app')),
          );
        },
      ),
    );
  }
}
