import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:guvvy/features/auth/data/repositories/auth_repository.dart';
import 'package:guvvy/features/users/data/repositories/user_repository.dart';

// Auth Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignUpRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthStateChanged extends AuthEvent {
  final User? user;

  const AuthStateChanged({this.user});

  @override
  List<Object?> get props => [user];
}

// Auth States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Auth Bloc// Auth Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final UserRepository _userRepository; // Add this line

  AuthBloc({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  })  : _authRepository = authRepository,
        _userRepository = userRepository, // Add this line
        super(AuthInitial()) {
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthStateChanged>(_onAuthStateChanged);

    // Listen to auth state changes
    _authRepository.authStateChanges.listen((user) {
      add(AuthStateChanged(user: user));
    });
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // Create user in Firebase Auth
      final userCredential = await _authRepository.signUp(
        email: event.email,
        password: event.password,
      );

      if (userCredential.user != null) {
        // Create user in database
        await _userRepository.createUserFromFirebaseUser(userCredential.user!);
        print("User created in database successfully"); // Add logging
      }

      // No need to emit authenticated state here as the authStateChanges stream will trigger
    } catch (e) {
      print("Error creating user: $e"); // Add error logging
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      // No need to emit authenticated state here as the authStateChanges stream will trigger
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.signOut();
      // No need to emit unauthenticated state here as the authStateChanges stream will trigger
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  void _onAuthStateChanged(
    AuthStateChanged event,
    Emitter<AuthState> emit,
  ) {
    if (event.user != null) {
      emit(AuthAuthenticated(user: event.user!));
    } else {
      emit(AuthUnauthenticated());
    }
  }
}
