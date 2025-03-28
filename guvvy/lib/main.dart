// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:guvvy/features/onboarding/screens/address_input_screen.dart';
import 'package:guvvy/features/profile/presentation/screens/profile_screen.dart';
import 'package:guvvy/features/representatives/data/datasources/mock_representative_datasource.dart';
import 'package:guvvy/features/representatives/data/datasources/representatives_remote_datasource.dart';
import 'package:guvvy/features/representatives/screens/representative_detail_with_map.dart';
import 'package:guvvy/features/search/screens/address_search_test_screen.dart';
import 'package:guvvy/features/search/screens/map_search_screen.dart';
import 'package:http/http.dart' as http;
import 'package:guvvy/features/auth/data/repositories/auth_repository.dart';
import 'package:guvvy/features/auth/domain/bloc/auth_bloc.dart';
import 'package:guvvy/features/auth/presentation/screens/login_screen.dart';
import 'package:guvvy/features/auth/presentation/screens/password_reset_screen.dart';
import 'package:guvvy/features/auth/presentation/screens/signup_screen.dart';
import 'package:guvvy/features/representatives/screens/onboarding_screen.dart';
import 'package:guvvy/features/users/data/repositories/user_repository_factory.dart';
import 'package:guvvy/features/users/domain/bloc/user_bloc.dart';
import 'package:guvvy/features/users/domain/repositories/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guvvy/config/custom_page_routes.dart';
import 'package:guvvy/config/theme.dart';
import 'package:guvvy/features/onboarding/data/services/onboarding_manager.dart';
import 'package:guvvy/firebase_options.dart';
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

// Updated AppRouter class for main.dart
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return FadeScaleRoute(
          page: const SplashScreen(),
        );
      case '/login':
        return FadeScaleRoute(
          page: const LoginScreen(),
        );
      case '/signup':
        return FadeScaleRoute(
          page: const SignUpScreen(),
        );
      case '/reset-password':
        return FadeScaleRoute(
          page: const PasswordResetScreen(),
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
      case '/map-search':
        return FadeScaleRoute(
          page: const MapSearchScreen(),
        );
      case '/representatives':
        return FadeScaleRoute(
          page: const RepresentativesListScreen(),
        );
      case '/representative-details':
        final String representativeId = settings.arguments as String;
        return SlideUpRoute(
          page: RepresentativeDetailWithMap(
            representativeId: representativeId,
          ),
        );
      case '/test-address-search':
        return MaterialPageRoute(
          builder: (_) => const AddressSearchTestScreen(),
        );
      case '/profile':
        return FadeScaleRoute(
          page: const UserProfileScreen(),
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

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase before any other services
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Create Auth Repository
  final authRepository = AuthRepository();

  // Create API data sources
  final representativesLocalDataSource = RepresentativesLocalDataSourceImpl(
    sharedPreferences: sharedPreferences,
  );
  
  // Use the real API data source with fallback to mock data
  final apiDataSource = RepresentativesApiDataSource(
    client: http.Client(),
    civicInfoApiKey: dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '',
  );
  
  final mockDataSource = MockRepresentativeDataSource();
  
  final representativesRemoteDataSource = HybridRepresentativesDataSource(
    apiDataSource: apiDataSource, 
    mockDataSource: mockDataSource,
  );

  runApp(MyApp(
    sharedPreferences: sharedPreferences,
    authRepository: authRepository,
    representativesLocalDataSource: representativesLocalDataSource,
    representativesRemoteDataSource: representativesRemoteDataSource,
  ));
}

class MyApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;
  final AuthRepository authRepository;
  final RepresentativesRemoteDataSource representativesRemoteDataSource;
  final RepresentativesLocalDataSource representativesLocalDataSource;

  const MyApp({
    Key? key,
    required this.sharedPreferences,
    required this.authRepository,
    required this.representativesLocalDataSource,
    required this.representativesRemoteDataSource,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // Auth Repository
        RepositoryProvider<AuthRepository>.value(
          value: authRepository,
        ),

        // User Repository - Use the factory instead of direct implementation
        RepositoryProvider<UserRepository>(
          create: (context) => UserRepositoryFactory.getRepository(),
        ),

        // Representatives Repository
        RepositoryProvider<RepresentativesRepository>(
          create: (context) => RepresentativesRepositoryImpl(
            remoteDataSource: representativesRemoteDataSource,
            localDataSource: representativesLocalDataSource,
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
          // Auth BLoC - Update this to include UserRepository
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
              userRepository: context.read<UserRepository>(),
            ),
          ),

          // User BLoC
          BlocProvider<UserBloc>(
            create: (context) => UserBloc(
              userRepository: context.read<UserRepository>(),
            ),
          ),

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
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            return MaterialApp(
              title: 'Civic Engagement App',
              theme: GuvvyTheme.light(),
              onGenerateRoute: AppRouter.generateRoute,
              initialRoute: '/',
              debugShowCheckedModeBanner: false,
            );
          },
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
    // For testing auth, we'll always go to login
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