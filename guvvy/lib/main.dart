// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guvvy/features/representatives/screens/home_screen.dart';
import 'package:guvvy/features/representatives/screens/main_navigation_screen.dart';
import 'package:guvvy/features/representatives/screens/representatives_details_screen.dart';
import 'package:guvvy/features/representatives/screens/representatives_list_screen.dart';
import 'package:http/http.dart' as http;

// Feature imports
import 'features/representatives/domain/bloc/representatives_bloc.dart';
import 'features/representatives/domain/repositories/representatives_repository.dart';
import 'features/representatives/domain/usecases/get_representatives.dart';
import 'features/representatives/domain/usecases/get_representative_details.dart';
import 'features/representatives/domain/usecases/save_representative.dart';
import 'features/representatives/domain/usecases/get_saved_representatives.dart';
import 'features/representatives/domain/usecases/remove_saved_representative.dart';
import 'features/representatives/data/repositories/representatives_repository_impl.dart';
import 'features/representatives/data/datasources/representatives_remote_datasource.dart';

import 'config/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final remoteDataSource = RepresentativesRemoteDataSourceImpl(
      client: http.Client(),
      baseUrl: 'https://your-api-url.com',
    );
    
    final repository = RepresentativesRepositoryImpl(remoteDataSource);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<RepresentativesRepository>(
          create: (context) => repository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<RepresentativesBloc>(
            create: (context) => RepresentativesBloc(
              getRepresentativesByLocation: GetRepresentativesByLocation(repository),
              getRepresentativeDetails: GetRepresentativeDetails(repository),
              saveRepresentative: SaveRepresentative(repository),
              getSavedRepresentatives: GetSavedRepresentatives(repository),
              removeSavedRepresentative: RemoveSavedRepresentative(repository),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Civic Engagement App',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          home: const MainNavigationScreen(),
          routes: {
            '/representative-details': (context) {
              final String representativeId = 
                ModalRoute.of(context)!.settings.arguments as String;
              return RepresentativeDetailsScreen(
                representativeId: representativeId,
              );
            },
          },
        ),
      ),
    );
  }
}