// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guvvy/config/custom_page_routes.dart'
    show FadeScaleRoute, SlideUpRoute;
import 'package:guvvy/features/representatives/data/datasources/mock_representative_datasource.dart';
import 'package:guvvy/features/representatives/screens/search_screen.dart';
import 'package:guvvy/features/representatives/screens/voting_history_screen.dart';
import 'package:guvvy/features/search/domain/search_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guvvy/config/theme.dart';
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
import 'package:guvvy/features/representatives/screens/representatives_details_screen.dart';
import 'package:guvvy/features/representatives/screens/representatives_list_screen.dart';
import 'package:guvvy/features/representatives/screens/main_navigation_screen.dart';
import 'package:guvvy/features/search/data/repositories/search_repository_impl.dart';
import 'package:guvvy/features/search/domain/bloc/search_bloc.dart';

import 'package:http/http.dart' as http;

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
        final String representativeId = settings.arguments as String;
        return SlideUpRoute(
          page: RepresentativeDetailsScreen(
            representativeId: representativeId,
          ),
        );
      case '/voting-history':
        final String? representativeId = settings.arguments as String?;
        return FadeScaleRoute(
          page: VotingHistoryScreen(representativeId: representativeId),
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

  const MyApp({super.key, required this.sharedPreferences});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // Representatives Repository
        RepositoryProvider<RepresentativesRepository>(
          create: (context) => RepresentativesRepositoryImpl(
            remoteDataSource:
                MockRepresentativeDataSource(), // Use mock data source
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
