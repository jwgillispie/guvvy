import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guvvy/config/theme.dart';
import 'package:guvvy/core/services/api_keys.dart';
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
    // For testing auth, we'll always go to login
      _verifyApiKeys();

    _navigateToLogin();
  }

  Future<void> _navigateToLogin() async {
    // Small delay to show splash screen
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    // Always navigate to login for testing auth
    Navigator.of(context).pushReplacementNamed('/login');
  }

  // Original function for reference (not used for testing)
  Future<void> _checkAuthAndOnboardingStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final authState = context.read<AuthBloc>().state;

    if (authState is! AuthAuthenticated) {
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

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

  Future<void> _verifyApiKeys() async {
    final hasGoogleMapsKey = ApiKeys.googleMapsKey.isNotEmpty;
    final hasOpenStatesKey = ApiKeys.openStatesKey.isNotEmpty;

    if (!hasGoogleMapsKey || !hasOpenStatesKey) {
      // Show a dialog if API keys are missing
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('API Keys Missing'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Some API keys are missing from your .env file:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (!hasGoogleMapsKey)
                  const Text(
                      '• Google Maps API Key (required for address search)'),
                if (!hasOpenStatesKey)
                  const Text(
                      '• Open States API Key (used for state legislature data)'),
                const SizedBox(height: 16),
                const Text(
                  'The app will fall back to mock data, but real data lookups will not work.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('CONTINUE WITH MOCK DATA'),
              ),
            ],
          ),
        );
      }
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
            // Logo placeholder
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

            // Add test buttons
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/test-address-search');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: GuvvyTheme.primary,
              ),
              child: const Text('Test Address Search'),
            ),

            const SizedBox(height: 16),
            TextButton(
              onPressed: _navigateToLogin,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
              child: const Text('Continue to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
