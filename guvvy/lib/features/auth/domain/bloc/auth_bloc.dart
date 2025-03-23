import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:guvvy/features/auth/data/repositories/auth_repository.dart';
import 'package:guvvy/features/users/domain/repositories/user_repository.dart';

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

// Auth Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  AuthBloc({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  })  : _authRepository = authRepository,
        _userRepository = userRepository,
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
      // Step 1: Create user in Firebase Auth
      final userCredential = await _authRepository.signUp(
        email: event.email,
        password: event.password,
      );

      if (userCredential.user != null) {
        try {
          // Step 2: Create user in database
          await _userRepository
              .createUserFromFirebaseUser(userCredential.user!);
          print(
              "User created successfully in database: ${userCredential.user!.uid}");

          // Step 3: Verify the user was created properly in the database
          final userDoc =
              await _userRepository.getUserById(userCredential.user!.uid);
          if (userDoc == null) {
            throw Exception("User document not found after creation");
          }

          // No need to emit authenticated state here as the authStateChanges stream will trigger
        } catch (dbError) {
          // If database creation fails, delete the Firebase Auth user and throw
          print("Database creation failed: $dbError");
          try {
            await userCredential.user?.delete();
          } catch (deleteError) {
            print(
                "Failed to clean up auth user after database failure: $deleteError");
          }

          // Force sign out
          await _authRepository.signOut();

          throw Exception(
              "Account created but profile setup failed. Please try again. Error: $dbError");
        }
      }
    } catch (e) {
      print("Error in signup process: $e");
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    print("Login requested for: ${event.email}");
    emit(AuthLoading());
    try {
      final userCredential = await _authRepository
          .signIn(
            email: event.email,
            password: event.password,
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () =>
                throw Exception("Login timed out. Please try again."),
          );
      print("Firebase login successful, user: ${userCredential.user?.uid}");

      // Explicitly emit authenticated state
      if (userCredential.user != null) {
        emit(AuthAuthenticated(user: userCredential.user!));
      } else {
        emit(AuthError(message: "Login successful but no user returned"));
      }

      // Update last login timestamp if needed
      try {
        if (userCredential.user != null) {
          await _userRepository.getUserById(userCredential.user!.uid);
        }
      } catch (e) {
        print("Warning: Failed to update login timestamp: $e");
        // Don't fail the login just because of this
      }
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
