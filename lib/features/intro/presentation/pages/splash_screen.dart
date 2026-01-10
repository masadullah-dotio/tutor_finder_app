import 'package:flutter/material.dart';
import 'package:tutor_finder_app/core/routes/app_routes.dart';
import 'package:tutor_finder_app/core/services/auth_service.dart';
import 'package:tutor_finder_app/features/auth/data/models/user_role.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tutor_finder_app/core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> _checkAuthStatus() async {
    // Removed artificial delay for faster startup
    // await Future.delayed(const Duration(seconds: 2));
    
    // Wait for Firebase to restore auth state (critical for Web)
    // .first will wait until the first event is emitted.
    // If no user is logged in, it usually emits null immediately.
    // However, on web refresh, it might need a split second to pull from indexedDB.
    final firebaseUser = await FirebaseAuth.instance.authStateChanges().first;

    if (!mounted) return;

    if (firebaseUser != null) {
      // User is authenticated, now fetch their role from Firestore
      final authService = AuthService();
      final user = await authService.getCurrentUser();

      if (mounted) {
        if (user != null) {
          switch (user.role) {
            case UserRole.student:
              Navigator.pushReplacementNamed(context, AppRoutes.studentDashboard);
              break;
            case UserRole.tutor:
              Navigator.pushReplacementNamed(context, AppRoutes.tutorDashboard);
              break;
            case UserRole.admin:
              Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
              break;
            default:
              Navigator.pushReplacementNamed(context, AppRoutes.studentDashboard);
          }
        } else {
          // Metadata mismatch or user deleted, force login
          Navigator.pushReplacementNamed(context, AppRoutes.signIn);
        }
      }
    } else {
      // No active session
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.gradientStart,
              AppColors.gradientEnd,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/splash_dark.png', // Using white logo for contrast on gradient
                    height: 150, // Increased height slightly
                    fit: BoxFit.contain, // Respect aspect ratio (height > width)
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Tutor Finder',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Find your perfect match',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
