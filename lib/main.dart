import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/about_us_screen.dart';
import 'screens/tutorial_screen.dart';
import 'screens/home_page.dart';
import 'screens/scan_history_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'services/auth_service.dart';

class AppRoutes {
  static const String authGate = '/auth-gate';
  static const String tutorial = '/tutorial';
  static const String login = '/login';
  static const String about = '/about';
  static const String home = '/home';
  static const String scanHistory = '/scan_history';
  static const String profile = '/profile';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NutriScan',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF34C759),
        scaffoldBackgroundColor: const Color(0xFFF2F2F7),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF34C759),
          secondary: const Color(0xFF34C759),
          surface: Colors.white,
          surfaceContainerHighest: const Color(0xFFF2F2F7),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: Colors.black,
          displayColor: Colors.black,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF34C759),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            textStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
          margin: EdgeInsets.zero,
        ),
      ),
      home: const AppLaunchScreen(),
      routes: {
        AppRoutes.authGate: (context) => const AuthWrapper(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.about: (context) => const AboutUsScreen(),
        AppRoutes.tutorial: (context) => const TutorialScreen(),
        AppRoutes.home: (context) => const HomePage(),
        AppRoutes.scanHistory: (context) => const ScanHistoryScreen(),
        AppRoutes.profile: (context) => const ProfileScreen(),
      },
    );
  }
}

class AppLaunchScreen extends StatefulWidget {
  const AppLaunchScreen({super.key});

  @override
  State<AppLaunchScreen> createState() => _AppLaunchScreenState();
}

class _AppLaunchScreenState extends State<AppLaunchScreen> {
  static const String _tutorialDoneKey = 'tutorial_completed_v1';

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final hasCompletedTutorial = prefs.getBool(_tutorialDoneKey) ?? false;

    // Keep splash visible briefly for a polished startup experience.
    await Future.delayed(const Duration(milliseconds: 1400));

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(
      hasCompletedTutorial ? AppRoutes.authGate : AppRoutes.tutorial,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          return user == null ? const LoginScreen() : const HomePage();
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Animation Controller
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      body: Center(
        child: FadeTransition(
          opacity: _fadeInAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.health_and_safety,
                  size: 100,
                  color: Colors.green,
                ),
                const SizedBox(height: 20),
                Text(
                  'NutriScan',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Scan smarter. Eat better.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.green[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
