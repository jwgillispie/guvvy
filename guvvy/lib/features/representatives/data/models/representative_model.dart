// lib/features/representatives/data/models/representative_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/representative.dart';

part 'representative_model.g.dart';

@JsonSerializable(explicitToJson: true)
class RepresentativeModel extends Representative {
  @JsonKey(defaultValue: '')
  @override
  final String id;

  @JsonKey(defaultValue: '')
  @override
  final String name;

  @JsonKey(defaultValue: '')
  @override
  final String party;

  @JsonKey(defaultValue: '')
  @override
  final String role;

  @JsonKey(defaultValue: 'federal')
  @override
  final String level;

  @JsonKey(defaultValue: '')
  @override
  final String district;

  @JsonKey(required: true)
  @override
  final ContactModel contact;

  @JsonKey(defaultValue: [])
  @override
  final List<String> committees;

  const RepresentativeModel({
    required this.id,
    required this.name,
    required this.party,
    required this.role,
    required this.level,
    required this.district,
    required this.contact,
    required this.committees,
  }) : super(
          id: id,
          name: name,
          party: party,
          role: role,
          level: level,
          district: district,
          contact: contact,
          committees: committees,
        );

  factory RepresentativeModel.fromJson(Map<String, dynamic> json) =>
      _$RepresentativeModelFromJson(json);

  Map<String, dynamic> toJson() => _$RepresentativeModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ContactModel extends Contact {
  @JsonKey(defaultValue: '')
  @override
  final String office;

  @JsonKey(defaultValue: '')
  @override
  final String phone;

  @override
  final String? email;

  @JsonKey(defaultValue: '')
  @override
  final String website;

  @JsonKey(required: true)
  @override
  final SocialMediaModel socialMedia;

  const ContactModel({
    required this.office,
    required this.phone,
    this.email,
    required this.website,
    required this.socialMedia,
  }) : super(
          office: office,
          phone: phone,
          email: email,
          website: website,
          socialMedia: socialMedia,
        );

  factory ContactModel.fromJson(Map<String, dynamic> json) =>
      _$ContactModelFromJson(json);

  Map<String, dynamic> toJson() => _$ContactModelToJson(this);
}

@JsonSerializable()
class SocialMediaModel extends SocialMedia {
  @override
  final String? twitter;

  @override
  final String? facebook;

  const SocialMediaModel({
    this.twitter,
    this.facebook,
  }) : super(
          twitter: twitter,
          facebook: facebook,
        );

  factory SocialMediaModel.fromJson(Map<String, dynamic> json) =>
      _$SocialMediaModelFromJson(json);

  Map<String, dynamic> toJson() => _$SocialMediaModelToJson(this);
}