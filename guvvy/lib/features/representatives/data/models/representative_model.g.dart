// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'representative_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RepresentativeModel _$RepresentativeModelFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['contact'],
  );
  return RepresentativeModel(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    party: json['party'] as String? ?? '',
    role: json['role'] as String? ?? '',
    level: json['level'] as String? ?? 'federal',
    district: json['district'] as String? ?? '',
    contact: ContactModel.fromJson(json['contact'] as Map<String, dynamic>),
    committees: (json['committees'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
  );
}

Map<String, dynamic> _$RepresentativeModelToJson(
        RepresentativeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'party': instance.party,
      'role': instance.role,
      'level': instance.level,
      'district': instance.district,
      'contact': instance.contact.toJson(),
      'committees': instance.committees,
    };

ContactModel _$ContactModelFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['socialMedia'],
  );
  return ContactModel(
    office: json['office'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    email: json['email'] as String?,
    website: json['website'] as String? ?? '',
    socialMedia:
        SocialMediaModel.fromJson(json['socialMedia'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$ContactModelToJson(ContactModel instance) =>
    <String, dynamic>{
      'office': instance.office,
      'phone': instance.phone,
      'email': instance.email,
      'website': instance.website,
      'socialMedia': instance.socialMedia.toJson(),
    };

SocialMediaModel _$SocialMediaModelFromJson(Map<String, dynamic> json) =>
    SocialMediaModel(
      twitter: json['twitter'] as String?,
      facebook: json['facebook'] as String?,
    );

Map<String, dynamic> _$SocialMediaModelToJson(SocialMediaModel instance) =>
    <String, dynamic>{
      'twitter': instance.twitter,
      'facebook': instance.facebook,
    };
