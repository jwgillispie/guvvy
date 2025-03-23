// lib/features/search/screens/address_search_test_screen.dart
import 'package:flutter/material.dart';
import 'package:guvvy/core/widgets/debug_location_panel.dart';
import 'package:guvvy/features/search/domain/entities/location.dart';
import 'package:guvvy/features/search/widgets/enhanced_address_search.dart';

class AddressSearchTestScreen extends StatefulWidget {
  const AddressSearchTestScreen({Key? key}) : super(key: key);

  @override
  State<AddressSearchTestScreen> createState() => _AddressSearchTestScreenState();
}

class _AddressSearchTestScreenState extends State<AddressSearchTestScreen> {
  Location? _selectedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Address Search Test'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Search for an address:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              EnhancedAddressSearchField(
                onAddressSelected: (location) {
                  setState(() {
                    _selectedLocation = location;
                  });
                },
                hintText: 'Enter an address to test search',
              ),
              
              const SizedBox(height: 24),
              
              if (_selectedLocation != null) ...[
                const Text(
                  'Selected Location:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DebugLocationPanel(
                  location: _selectedLocation,
                  onRefresh: () {
                    setState(() {
                      _selectedLocation = null;
                    });
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}