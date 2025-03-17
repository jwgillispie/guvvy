// lib/features/representatives/screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:guvvy/config/theme.dart';
import 'package:guvvy/features/representatives/screens/main_navigation_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLastPage = false;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to Guvvy',
      description: 'Your personal guide to staying informed and connected with your government representatives.',
      image: 'assets/images/onboarding_welcome.png',
      backgroundColor: GuvvyTheme.primary,
    ),
    OnboardingPage(
      title: 'Discover Your Representatives',
      description: 'Find out who represents you at all levels of government, from local officials to federal senators.',
      image: 'assets/images/onboarding_discover.png',
      backgroundColor: GuvvyTheme.democrat,
    ),
    OnboardingPage(
      title: 'Track Voting History',
      description: 'See how your representatives vote on issues that matter to you and understand their policy positions.',
      image: 'assets/images/onboarding_track.png',
      backgroundColor: GuvvyTheme.independent,
    ),
    OnboardingPage(
      title: 'Civic Education',
      description: 'Learn about the roles, responsibilities, and powers of different government positions.',
      image: 'assets/images/onboarding_education.png',
      backgroundColor: GuvvyTheme.accent,
    ),
    OnboardingPage(
      title: 'Stay Engaged',
      description: 'Save your representatives, track important votes, and receive updates on key civic activities.',
      image: 'assets/images/onboarding_engage.png',
      backgroundColor: GuvvyTheme.success,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int page = _pageController.page?.round() ?? 0;
      if (page != _currentPage) {
        setState(() {
          _currentPage = page;
          _isLastPage = page == _pages.length - 1;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _completeOnboarding() async {
    // Save that onboarding is complete
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);

    // Navigate to the address input screen
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AddressInputScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: const Text('Skip'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                  ),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Page indicator and next button
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page indicator
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => _buildDotIndicator(index),
                    ),
                  ),

                  // Next/Get Started button
                  ElevatedButton(
                    onPressed: _isLastPage
                        ? _completeOnboarding
                        : () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _pages[_currentPage].backgroundColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      _isLastPage ? 'Get Started' : 'Next',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image placeholder (replace with actual images)
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              color: page.backgroundColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.image,
              size: 100,
              color: page.backgroundColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 40),

          // Title
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: GuvvyTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            page.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDotIndicator(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPage == index
            ? _pages[_currentPage].backgroundColor
            : Colors.grey.shade300,
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String image;
  final Color backgroundColor;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.image,
    required this.backgroundColor,
  });
}

// Address Input Screen after onboarding
class AddressInputScreen extends StatefulWidget {
  const AddressInputScreen({Key? key}) : super(key: key);

  @override
  State<AddressInputScreen> createState() => _AddressInputScreenState();
}

class _AddressInputScreenState extends State<AddressInputScreen> {
  final TextEditingController _addressController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _submitAddress() async {
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your address')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // In a real app, you would geocode the address and save it
      // For now, we'll just simulate a delay
      await Future.delayed(const Duration(seconds: 1));

      // Navigate to the main app
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Helper method to parse an address string into components
  Map<String, String?> _parseAddress(String fullAddress) {
    // This is a basic implementation
    // In a production app, you'd want to use a more sophisticated address parser
    // or integrate with a geocoding service that returns structured addresses
    
    try {
      // Basic parsing for US addresses in format:
      // Street, City, State ZIP
      
      final parts = fullAddress.split(',');
      if (parts.length < 2) {
        return {
          'street': fullAddress,
          'city': null,
          'state': null,
          'zipCode': null,
        };
      }
      
      final street = parts[0].trim();
      
      // Try to parse city, state, and zip
      String? city;
      String? state;
      String? zipCode;
      
      if (parts.length >= 2) {
        city = parts[1].trim();
      }
      
      if (parts.length >= 3) {
        // The last part might contain state and ZIP
        final stateZip = parts[2].trim().split(' ');
        
        if (stateZip.length >= 1) {
          state = stateZip[0].trim();
        }
        
        if (stateZip.length >= 2) {
          zipCode = stateZip[1].trim();
        }
      }
      
      return {
        'street': street,
        'city': city,
        'state': state,
        'zipCode': zipCode,
      };
    } catch (e) {
      print('Error parsing address: $e');
      // If parsing fails, just return the full address as the street
      return {
        'street': fullAddress,
        'city': null,
        'state': null,
        'zipCode': null,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const OnboardingScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              const Text(
                'Find Your Representatives',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: GuvvyTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Enter your address to discover who represents you in government.',
                style: TextStyle(
                  fontSize: 16,
                  color: GuvvyTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // Address input field
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Your Address',
                  hintText: '123 Main St, City, State, ZIP',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSubmitted: (_) => _submitAddress(),
              ),
              const SizedBox(height: 16),

              // Permission explanation
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'We only use your address to find your representatives. Your privacy is important to us.',
                        style: TextStyle(color: Colors.blue.shade700),
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GuvvyTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Find My Representatives',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}