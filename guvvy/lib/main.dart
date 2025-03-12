// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guvvy/core/routes/custom_page_routes.dart';
import 'package:guvvy/features/representatives/screens/representative_details_screen.dart';
import 'package:guvvy/features/representatives/screens/representatives_list_screen.dart';
import 'package:guvvy/features/search/presentation/screens/search_screen.dart';

// ... existing imports

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return FadeScaleRoute(
          page: const MainNavigationScreen(),
        );
      case '/search':
        return SlideUpRoute(
          page: const SearchScreen(),
        );
      case '/representatives':
        return FadeScaleRoute(
          page: const RepresentativesListScreen(),
        );
      case '/representative-details':
        final String representativeId = 
          settings.arguments as String;
        return SlideUpRoute(
          page: RepresentativeDetailsScreen(
            representativeId: representativeId,
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Repositories and BLoCs setup...
    
    return MultiRepositoryProvider(
      providers: [
        // Your repository providers...
      ],
      child: MultiBlocProvider(
        providers: [
          // Your BLoC providers...
        ],
        child: MaterialApp(
          title: 'Civic Engagement App',
          theme: GuvvyTheme.light(),
          onGenerateRoute: AppRouter.generateRoute,
          initialRoute: '/',
        ),
      ),
    );
  }
}