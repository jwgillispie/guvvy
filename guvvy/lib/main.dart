// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:guvvy/config/custom_page_routes.dart';
import 'package:guvvy/config/theme.dart';
import 'package:guvvy/core/services/api_keys.dart';
import 'package:guvvy/features/auth/data/repositories/auth_repository.dart';
import 'package:guvvy/features/auth/domain/bloc/auth_bloc.dart';
import 'package:guvvy/features/auth/presentation/screens/login_screen.dart';
import 'package:guvvy/features/auth/presentation/screens/password_reset_screen.dart';
import 'package:guvvy/features/auth/presentation/screens/signup_screen.dart';
import 'package:guvvy/features/landing/landing_page.dart';
import 'package:guvvy/features/onboarding/screens/address_input_screen.dart';
import 'package:guvvy/features/representatives/data/datasources/mock_representative_datasource.dart';
import 'package:guvvy/features/representatives/data/datasources/representatives_local_datasource.dart';
import 'package:guvvy/features/representatives/data/datasources/representatives_remote_datasource.dart';
import 'package:guvvy/features/representatives/data/repositories/representatives_repository_impl.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_bloc.dart';
import 'package:guvvy/features/representatives/domain/repositories/representatives_repository.dart';
import 'package:guvvy/features/representatives/domain/usecases/get_representative_details.dart';
import 'package:guvvy/features/representatives/domain/usecases/get_representatives.dart';
import 'package:guvvy/features/representatives/domain/usecases/get_saved_representatives.dart';
import 'package:guvvy/features/representatives/domain/usecases/remove_saved_representative.dart';
import 'package:guvvy/features/representatives/domain/usecases/save_representative.dart';
import 'package:guvvy/features/representatives/screens/main_navigation_screen.dart';
import 'package:guvvy/features/representatives/screens/onboarding_screen.dart';
import 'package:guvvy/features/representatives/screens/representative_detail_with_map.dart';
import 'package:guvvy/features/search/data/repositories/search_repository_impl.dart';
import 'package:guvvy/features/search/domain/bloc/search_bloc.dart';
import 'package:guvvy/features/search/domain/search_repository.dart';
import 'package:guvvy/features/splash/splash_screen.dart';
import 'package:guvvy/features/users/data/repositories/user_repository_factory.dart';
import 'package:guvvy/features/users/domain/bloc/user_bloc.dart';
import 'package:guvvy/features/users/domain/repositories/user_repository.dart';
import 'package:guvvy/firebase_options.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  // Get the API key from .env file
  final googleMapsApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  
  // Use the real API data source with fallback to mock data
  final apiDataSource = RepresentativesApiDataSource(
    client: http.Client(),
    civicInfoApiKey: googleMapsApiKey,
  );
  
  final mockDataSource = MockRepresentativeDataSource();
  
  final representativesRemoteDataSource = HybridRepresentativesDataSource(
    apiDataSource: apiDataSource, 
    mockDataSource: mockDataSource,
  );

  // Create API data sources
  final representativesLocalDataSource = RepresentativesLocalDataSourceImpl(
    sharedPreferences: sharedPreferences,
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
    // Check if we're running on the web
    if (kIsWeb) {
      return MaterialApp(
        title: 'Guvvy - Know Your Representatives',
        theme: GuvvyTheme.light(),
        home: const LandingPage(),
        debugShowCheckedModeBanner: false,
      );
    }

    // If not on web, show the regular mobile app with all dependencies
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
              title: 'Guvvy',
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

// AppRouter class from original main.dart
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
      case '/representative-details':
        final String representativeId = settings.arguments as String;
        return SlideUpRoute(
          page: RepresentativeDetailWithMap(
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