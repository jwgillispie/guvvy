// lib/features/user/user_module.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guvvy/features/users/data/repositories/user_repository.dart';
import 'package:guvvy/features/users/data/repositories/user_repository_factory.dart';
import 'package:guvvy/features/users/domain/bloc/user_bloc.dart';

/// This class shows how to use the UserRepository in your module
class UserModule {
  /// Provide the repository to your app
  static RepositoryProvider<UserRepository> getRepositoryProvider() {
    return RepositoryProvider<UserRepository>(
      create: (context) => UserRepositoryFactory.getRepository(),
    );
  }
  
  /// Provide the user bloc to your app
  static BlocProvider<UserBloc> getBlocProvider() {
    return BlocProvider<UserBloc>(
      create: (context) => UserBloc(
        userRepository: context.read<UserRepository>(),
      ),
    );
  }
  
  /// Example of how to use the repository in a widget
  static Widget buildUserProfileWidget() {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoadSuccess) {
          final user = state.user;
          return Column(
            children: [
              Text('Welcome, ${user.firstName ?? "User"}!'),
              if (user.address != null)
                Text('Your address: ${user.address?.street}, ${user.address?.city}'),
              ElevatedButton(
                onPressed: () {
                  // Example of updating profile info
                  context.read<UserBloc>().add(
                    UserProfileUpdated(
                      firstName: 'New Name',
                    ),
                  );
                },
                child: Text('Update Profile'),
              ),
            ],
          );
        } else if (state is UserLoading) {
          return CircularProgressIndicator();
        } else if (state is UserLoadFailure) {
          return Text('Error: ${state.message}');
        } else {
          return Text('No user data available');
        }
      },
    );
  }
}