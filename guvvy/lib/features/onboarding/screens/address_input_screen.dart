// lib/features/onboarding/screens/address_input_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guvvy/config/theme.dart';
import 'package:guvvy/features/onboarding/data/services/onboarding_manager.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_bloc.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_event.dart';
import 'package:guvvy/features/representatives/screens/main_navigation_screen.dart';
import 'package:guvvy/features/search/domain/entities/location.dart';
import 'package:guvvy/features/search/widgets/enhanced_address_search.dart';
import 'package:guvvy/features/users/domain/bloc/user_bloc.dart';
import 'package:guvvy/features/users/domain/entities/user.dart';

class AddressInputScreen extends StatefulWidget {
  final bool isOnboarding;

  const AddressInputScreen({
    Key? key,
    this.isOnboarding = true,
  }) : super(key: key);

  @override
  State<AddressInputScreen> createState() => _AddressInputScreenState();
}

class _AddressInputScreenState extends State<AddressInputScreen> {
  bool _isLoading = false;
  Location? _selectedLocation;

  void _onAddressSelected(Location location) {
    setState(() {
      _selectedLocation = location;
    });
  }

  Future<void> _saveAddressAndContinue() async {
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an address')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Create Address object from location
      final address = Address(
        street: _selectedLocation!.formattedAddress?.split(',').first ?? '',
        city: _extractCity(_selectedLocation!.formattedAddress ?? ''),
        state: _extractState(_selectedLocation!.formattedAddress ?? ''),
        zipCode: _extractZipCode(_selectedLocation!.formattedAddress ?? ''),
        coordinates: Coordinates(
          latitude: _selectedLocation!.latitude,
          longitude: _selectedLocation!.longitude,
        ),
      );

      // 2. Update user's address in the database
      context.read<UserBloc>().add(UserAddressUpdated(address: address));

      // 3. Load representatives for this address
      context.read<RepresentativesBloc>().add(
            LoadRepresentatives(
              latitude: _selectedLocation!.latitude,
              longitude: _selectedLocation!.longitude,
            ),
          );

      // 4. If this is part of onboarding, mark address as saved
      if (widget.isOnboarding) {
        await OnboardingManager.setAddressSaved();
      }

      // 5. Navigate to main screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainNavigationScreen(),
          ),
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

  // Helper methods to parse address components
  String _extractCity(String address) {
    final parts = address.split(',');
    return parts.length > 1 ? parts[1].trim() : '';
  }

  String _extractState(String address) {
    final parts = address.split(',');
    if (parts.length > 2) {
      final stateParts = parts[2].trim().split(' ');
      return stateParts.isNotEmpty ? stateParts.first : '';
    }
    return '';
  }

  String _extractZipCode(String address) {
    final parts = address.split(',');
    if (parts.length > 2) {
      final stateParts = parts[2].trim().split(' ');
      return stateParts.length > 1 ? stateParts.last : '';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isOnboarding ? 'Get Started' : 'Update Address'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isOnboarding
                    ? 'Find Your Representatives'
                    : 'Update Your Address',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'Enter your address to discover who represents you in government.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: GuvvyTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 32),

              EnhancedAddressSearchField(
                onAddressSelected: _onAddressSelected,
                hintText: 'Enter your address',
                autofocus: true,
              ),
              const SizedBox(height: 16),

              if (_selectedLocation != null)
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.check_circle, color: GuvvyTheme.success),
                            SizedBox(width: 8),
                            Text(
                              'Address Selected',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(_selectedLocation!.formattedAddress ?? ''),
                        const SizedBox(height: 8),
                        Text(
                          'Coordinates: ${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Information about privacy
              const SizedBox(height: 24),
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

              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading || _selectedLocation == null
                      ? null
                      : _saveAddressAndContinue,
                  style: ElevatedButton.styleFrom(
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
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          widget.isOnboarding
                              ? 'Find My Representatives'
                              : 'Update Address',
                          style: const TextStyle(
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