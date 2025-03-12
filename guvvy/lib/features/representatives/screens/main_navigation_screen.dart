// lib/features/navigation/presentation/screens/main_navigation_screen.dart
import 'package:flutter/material.dart';
import 'package:guvvy/features/representatives/screens/home_screen.dart';
import 'package:guvvy/features/representatives/screens/representatives_list_screen.dart';
import 'package:guvvy/features/representatives/screens/saved_representative_screen.dart';
import 'package:guvvy/features/representatives/screens/voting_history_screen.dart';


class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const RepresentativesListScreen(),
    const SavedRepresentativesScreen(),
    const VotingHistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    
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
            icon: Icon(Icons.how_to_vote),
            label: 'Voting',
          ),
        ],
      ),
    );
  }
}