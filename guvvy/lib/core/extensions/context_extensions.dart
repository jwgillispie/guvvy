// lib/core/extensions/context_extensions.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guvvy/features/auth/domain/bloc/auth_bloc.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_bloc.dart';
import 'package:guvvy/features/search/domain/bloc/search_bloc.dart';
import 'package:guvvy/features/users/domain/bloc/user_bloc.dart';

extension BuildContextExtensions on BuildContext {
  // Blocs
  AuthBloc get authBloc => read<AuthBloc>();
  RepresentativesBloc get representativesBloc => read<RepresentativesBloc>();
  SearchBloc get searchBloc => read<SearchBloc>();
  UserBloc get userBloc => read<UserBloc>();
  
  // Theme
  ThemeData get theme => Theme.of(this);
  
  // Screen dimensions
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  
  // Navigation
  void pop<T>([T? result]) => Navigator.of(this).pop(result);
  void pushNamed(String route, {Object? arguments}) => 
      Navigator.of(this).pushNamed(route, arguments: arguments);
}