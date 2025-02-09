// lib/features/representatives/domain/entities/representative.dart
import 'package:equatable/equatable.dart';

class Representative extends Equatable {
  final String id;
  final String name;
  final String party;
  final String role;
  final String level;
  final String district;
  final Contact contact;
  final List<String> committees;

  const Representative({
    required this.id,
    required this.name,
    required this.party,
    required this.role,
    required this.level,
    required this.district,
    required this.contact,
    required this.committees,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        party,
        role,
        level,
        district,
        contact,
        committees,
      ];
}

class Contact extends Equatable {
  final String office;
  final String phone;
  final String? email;
  final String website;
  final SocialMedia socialMedia;

  const Contact({
    required this.office,
    required this.phone,
    this.email,
    required this.website,
    required this.socialMedia,
  });

  @override
  List<Object?> get props => [
        office,
        phone,
        email,
        website,
        socialMedia,
      ];
}

class SocialMedia extends Equatable {
  final String? twitter;
  final String? facebook;

  const SocialMedia({
    this.twitter,
    this.facebook,
  });

  @override
  List<Object?> get props => [twitter, facebook];
}