// lib/features/representatives/screens/main_navigation_screen.dart
import 'package:flutter/material.dart';
import 'package:guvvy/features/profile/presentation/screens/profile_screen.dart';
import 'package:guvvy/features/representatives/screens/home_screen.dart';
import 'package:guvvy/features/representatives/screens/representatives_list_screen.dart';
import 'package:guvvy/features/representatives/screens/saved_representative_screen.dart';
import 'package:guvvy/features/search/screens/map_search_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const MapSearchScreen(), // Replace HomeScreen with MapSearchScreen
    const RepresentativesListScreen(),
    const SavedRepresentativesScreen(),
    const UserProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Find',
          ),
          NavigationDestination(
            icon: Icon(Icons.people),
            label: 'Reps',
          ),
          NavigationDestination(
            icon: Icon(Icons.star),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}