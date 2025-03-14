// lib/features/splash/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guvvy/config/theme.dart';
import 'package:guvvy/features/auth/domain/bloc/auth_bloc.dart';
import 'package:guvvy/features/onboarding/data/services/onboarding_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndOnboardingStatus();
  }

  Future<void> _checkAuthAndOnboardingStatus() async {
    // Wait a brief moment to display splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Get the current auth state
    final authState = context.read<AuthBloc>().state;
    
    // If user is not authenticated, navigate to login
    if (authState is! AuthAuthenticated) {
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    // Check onboarding status and navigate accordingly for authenticated users
    final status = await OnboardingManager.getStatus();
    
    switch (status) {
      case OnboardingStatus.needsOnboarding:
        Navigator.of(context).pushReplacementNamed('/onboarding');
        break;
      case OnboardingStatus.needsAddress:
        Navigator.of(context).pushReplacementNamed('/address-input');
        break;
      case OnboardingStatus.complete:
        Navigator.of(context).pushReplacementNamed('/home');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GuvvyTheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo placeholder - replace with your app's logo
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  'G',
                  style: TextStyle(
                    color: GuvvyTheme.primary,
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Guvvy',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your Civic Engagement Companion',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}