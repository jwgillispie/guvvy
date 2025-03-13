// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guvvy/features/representatives/screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guvvy/config/custom_page_routes.dart';
import 'package:guvvy/config/theme.dart';
import 'package:guvvy/features/onboarding/data/services/onboarding_manager.dart';
import 'package:guvvy/features/representatives/data/datasources/mock_representative_datasource.dart';
import 'package:guvvy/features/representatives/data/datasources/representatives_local_datasource.dart';
import 'package:guvvy/features/representatives/data/repositories/representatives_repository_impl.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_bloc.dart';
import 'package:guvvy/features/representatives/domain/repositories/representatives_repository.dart';
import 'package:guvvy/features/representatives/domain/usecases/get_representative_details.dart';
import 'package:guvvy/features/representatives/domain/usecases/get_representatives.dart';
import 'package:guvvy/features/representatives/domain/usecases/get_saved_representatives.dart';
import 'package:guvvy/features/representatives/domain/usecases/remove_saved_representative.dart';
import 'package:guvvy/features/representatives/domain/usecases/save_representative.dart';
import 'package:guvvy/features/representatives/screens/representatives_details_screen.dart';
import 'package:guvvy/features/representatives/screens/representatives_list_screen.dart';
import 'package:guvvy/features/representatives/screens/main_navigation_screen.dart';
import 'package:guvvy/features/search/data/repositories/search_repository_impl.dart';
import 'package:guvvy/features/search/domain/bloc/search_bloc.dart';
import 'package:guvvy/features/search/domain/search_repository.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return FadeScaleRoute(
          page: const SplashScreen(),
        );
      case '/onboarding':
        return FadeScaleRoute(
          page: const OnboardingScreen(),
        );
      case '/address-input':
        return SlideUpRoute(
          page: const AddressInputScreen(),
        );
      case '/home':
        return FadeScaleRoute(
          page: const MainNavigationScreen(),
        );
      case '/representatives':
        return FadeScaleRoute(
          page: const RepresentativesListScreen(),
        );
      case '/representative-details':
        final String representativeId = settings.arguments as String;
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(MyApp(sharedPreferences: sharedPreferences));
}

class MyApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;

  const MyApp({Key? key, required this.sharedPreferences}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // Representatives Repository
        RepositoryProvider<RepresentativesRepository>(
          create: (context) => RepresentativesRepositoryImpl(
            remoteDataSource:
                MockRepresentativeDataSource(), // Replace with real API when ready
            localDataSource: RepresentativesLocalDataSourceImpl(
              sharedPreferences: sharedPreferences,
            ),
          ),
        ),

        // Search Repository
        RepositoryProvider<SearchRepository>(
          create: (context) => SearchRepositoryImpl(
            sharedPreferences: sharedPreferences,
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // Representatives BLoC
          BlocProvider<RepresentativesBloc>(
            create: (context) => RepresentativesBloc(
              getRepresentativesByLocation: GetRepresentativesByLocation(
                context.read<RepresentativesRepository>(),
              ),
              getRepresentativeDetails: GetRepresentativeDetails(
                context.read<RepresentativesRepository>(),
              ),
              saveRepresentative: SaveRepresentative(
                context.read<RepresentativesRepository>(),
              ),
              getSavedRepresentatives: GetSavedRepresentatives(
                context.read<RepresentativesRepository>(),
              ),
              removeSavedRepresentative: RemoveSavedRepresentative(
                context.read<RepresentativesRepository>(),
              ),
            ),
          ),

          // Search BLoC
          BlocProvider<SearchBloc>(
            create: (context) => SearchBloc(
              searchRepository: context.read<SearchRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Civic Engagement App',
          theme: GuvvyTheme.light(),
          onGenerateRoute: AppRouter.generateRoute,
          initialRoute: '/',
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    // Wait a brief moment to display splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check onboarding status and navigate accordingly
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
              decoration: BoxDecoration(
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