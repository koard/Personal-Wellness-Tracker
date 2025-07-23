import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'config/env_config.dart';
import 'auth/screens/login_screen.dart'; // ชั่วคราว ใช้ login เป็น home ก่อน
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth/screens/register_screen.dart';
import 'dashboard/screens/dashboard_screen.dart'; // สมมุติหน้าหลักหลังล็อกอิน
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await EnvConfig.load();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wellness Tracker',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        // '/onboarding': (context) => const OnboardingScreen(), // ภายหลัง
      },
      home: authState.when(
        data: (user) {
          if (user != null) {
            return const DashboardScreen();
          } else {
            return const LoginScreen();
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error loading user')),
      ),
    );
      
  }
}
