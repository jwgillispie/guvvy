// lib/features/user/domain/bloc/user_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:guvvy/features/users/data/models/user_model.dart';
import 'package:guvvy/features/users/data/repositories/user_repository.dart';
import 'package:guvvy/features/users/domain/entities/user.dart';

// User Events
abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class UserLoaded extends UserEvent {}

class UserAddressUpdated extends UserEvent {
  final Address address;

  const UserAddressUpdated({required this.address});

  @override
  List<Object?> get props => [address];
}

class UserProfileUpdated extends UserEvent {
  final String? firstName;
  final String? lastName;

  const UserProfileUpdated({
    this.firstName,
    this.lastName,
  });

  @override
  List<Object?> get props => [firstName, lastName];
}

// User States
abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoadSuccess extends UserState {
  final UserModel user;

  const UserLoadSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}

class UserLoadFailure extends UserState {
  final String message;

  const UserLoadFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

// User Bloc
class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository;
  final firebase_auth.FirebaseAuth _firebaseAuth;

  UserBloc({
    required UserRepository userRepository,
    firebase_auth.FirebaseAuth? firebaseAuth,
  }) : 
    _userRepository = userRepository,
    _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
    super(UserInitial()) {
    on<UserLoaded>(_onUserLoaded);
    on<UserAddressUpdated>(_onUserAddressUpdated);
    on<UserProfileUpdated>(_onUserProfileUpdated);
  }

  Future<void> _onUserLoaded(
    UserLoaded event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        emit(const UserLoadFailure(message: 'User not authenticated'));
        return;
      }

      final userModel = await _userRepository.getUserById(currentUser.uid);
      if (userModel == null) {
        // If user doesn't exist in Firestore but exists in Firebase Auth,
        // create a new user document
        final newUserModel = await _userRepository.createUserFromFirebaseUser(currentUser);
        emit(UserLoadSuccess(user: newUserModel));
      } else {
        emit(UserLoadSuccess(user: userModel));
      }
    } catch (e) {
      emit(UserLoadFailure(message: e.toString()));
    }
  }

  Future<void> _onUserAddressUpdated(
    UserAddressUpdated event,
    Emitter<UserState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is UserLoadSuccess) {
        // Get current user
        final currentUser = _firebaseAuth.currentUser;
        if (currentUser == null) {
          emit(const UserLoadFailure(message: 'User not authenticated'));
          return;
        }

        // Update user with new address
        final updatedUser = currentState.user.copyWith(
          address: event.address,
          updatedAt: DateTime.now(),
        );

        // Update in repository
        await _userRepository.updateUser(updatedUser);

        // Convert input Address to AddressModel if needed
        final addressModel = event.address is AddressModel 
            ? event.address as AddressModel
            : AddressModel(
                street: event.address.street,
                city: event.address.city,
                state: event.address.state,
                zipCode: event.address.zipCode,
                coordinates: event.address.coordinates != null 
                    ? CoordinatesModel(
                        latitude: event.address.coordinates!.latitude,
                        longitude: event.address.coordinates!.longitude,
                      )
                    : null,
              );
        
        // Update address specifically
        await _userRepository.updateUserAddress(currentUser.uid, addressModel);

        // Update state with new user data
        emit(UserLoadSuccess(user: updatedUser));
      }
    } catch (e) {
      emit(UserLoadFailure(message: e.toString()));
    }
  }

  Future<void> _onUserProfileUpdated(
    UserProfileUpdated event,
    Emitter<UserState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is UserLoadSuccess) {
        // Get current user
        final currentUser = _firebaseAuth.currentUser;
        if (currentUser == null) {
          emit(const UserLoadFailure(message: 'User not authenticated'));
          return;
        }

        // Update user with new profile data
        final updatedUser = currentState.user.copyWith(
          firstName: event.firstName ?? currentState.user.firstName,
          lastName: event.lastName ?? currentState.user.lastName,
          updatedAt: DateTime.now(),
        );

        // Update in repository
        await _userRepository.updateUser(updatedUser);

        // Update state with new user data
        emit(UserLoadSuccess(user: updatedUser));
      }
    } catch (e) {
      emit(UserLoadFailure(message: e.toString()));
    }
  }
}