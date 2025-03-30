// lib/features/representatives/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_bloc.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_event.dart';
import 'package:guvvy/features/representatives/presentation/widgets/address_search_field.dart';
import 'package:guvvy/features/representatives/presentation/widgets/filter_chips.dart';
import 'package:guvvy/features/representatives/presentation/widgets/recent_searches.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Representatives'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AddressSearchField(
                onAddressSelected: (latitude, longitude) {
                  context.read<RepresentativesBloc>().add(
                    LoadRepresentatives(
                      latitude: latitude,
                      longitude: longitude,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              const FilterChips(),
              const SizedBox(height: 24),
              const Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Expanded(
                child: RecentSearches(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
