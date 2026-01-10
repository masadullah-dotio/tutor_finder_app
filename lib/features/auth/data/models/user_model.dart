import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_role.dart';
export 'user_role.dart';

class UserModel {
  final String uid;
  final String email;
  final String username;
  final String? firstName;
  final String? lastName;
  final String mobilePhone;
  final UserRole role;
  final String? bio;
  final List<String>? subjects;
  final double? hourlyRate;
  final List<String> children; // IDs of children (if parent)
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final bool isMobilePhoneVerified;
  final bool isEmailVerified;
  final double? latitude;
  final double? longitude;
  final bool isOnline;
  final DateTime? lastActive;
  final double? averageRating;
  final int? reviewCount;
  final String? gender;
  final bool notifyPush;
  final bool notifyEmail;
  final bool notifyInApp;
  final String? profileImageUrl;

  // New fields for Home Tuition
  final List<String> teachingModes; // ['online', 'home']
  final double? travelRadiusKm;
  final double? homeRateDifferential;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    this.firstName,
    this.lastName,
    required this.mobilePhone,
    required this.role,
    this.children = const [],
    this.bio,
    this.subjects,
    this.hourlyRate,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.isMobilePhoneVerified = false,
    this.isEmailVerified = false,
    this.latitude,
    this.longitude,
    this.isOnline = false,
    this.lastActive,
    this.averageRating,
    this.reviewCount,
    this.profileImageUrl,
    this.gender,
    this.notifyPush = true,
    this.notifyEmail = true,
    this.notifyInApp = true,
    this.teachingModes = const [],
    this.travelRadiusKm,
    this.homeRateDifferential,
  }) : assert(
          role == UserRole.parent || children.isEmpty,
          'Only parents can have children (Current role: $role, Children count: ${children.length})',
        );

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'mobilePhone': mobilePhone,
      'role': role.toStringValue,
      if (role == UserRole.parent) 'children': children,
      if (bio != null) 'bio': bio,
      if (subjects != null) 'subjects': subjects,
      if (hourlyRate != null) 'hourlyRate': hourlyRate,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'isMobilePhoneVerified': isMobilePhoneVerified,
      'isEmailVerified': isEmailVerified,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'isOnline': isOnline,
      if (lastActive != null) 'lastActive': Timestamp.fromDate(lastActive!),
      if (averageRating != null) 'averageRating': averageRating,
      if (reviewCount != null) 'reviewCount': reviewCount,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      if (gender != null) 'gender': gender,
      'notifyPush': notifyPush,
      'notifyEmail': notifyEmail,
      'notifyInApp': notifyInApp,
      'teachingModes': teachingModes,
      if (travelRadiusKm != null) 'travelRadiusKm': travelRadiusKm,
      if (homeRateDifferential != null) 'homeRateDifferential': homeRateDifferential,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String? ?? '',
      email: map['email'] as String? ?? '',
      username: map['username'] as String? ?? '',
      firstName: map['firstName'] as String?,
      lastName: map['lastName'] as String?,
      mobilePhone: map['mobilePhone'] as String? ?? '',
      role: UserRole.fromString(map['role'] as String? ?? 'student'),
      children: List<String>.from(map['children'] ?? []),
      bio: map['bio'] as String?,
      subjects: map['subjects'] != null ? List<String>.from(map['subjects']) : null,
      hourlyRate: map['hourlyRate'] != null ? (map['hourlyRate'] as num).toDouble() : null,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : DateTime.now(),
      isActive: map['isActive'] as bool? ?? true,
      isMobilePhoneVerified: map['isMobilePhoneVerified'] as bool? ?? false,
      isEmailVerified: map['isEmailVerified'] as bool? ?? false,
      latitude: map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
      longitude: map['longitude'] != null ? (map['longitude'] as num).toDouble() : null,
      isOnline: map['isOnline'] as bool? ?? false,
      lastActive: map['lastActive'] != null ? (map['lastActive'] as Timestamp).toDate() : null,
      averageRating: map['averageRating'] != null ? (map['averageRating'] as num).toDouble() : null,
      reviewCount: map['reviewCount'] != null ? (map['reviewCount'] as num).toInt() : null,
      profileImageUrl: map['profileImageUrl'] as String?,
      gender: map['gender'] as String?,
      notifyPush: map['notifyPush'] as bool? ?? true,
      notifyEmail: map['notifyEmail'] as bool? ?? true,
      notifyInApp: map['notifyInApp'] as bool? ?? true,
      teachingModes: List<String>.from(map['teachingModes'] ?? []),
      travelRadiusKm: map['travelRadiusKm'] != null ? (map['travelRadiusKm'] as num).toDouble() : null,
      homeRateDifferential: map['homeRateDifferential'] != null ? (map['homeRateDifferential'] as num).toDouble() : null,
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? username,
    String? firstName,
    String? lastName,
    String? mobilePhone,
    UserRole? role,
    List<String>? children,
    String? bio,
    List<String>? subjects,
    double? hourlyRate,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? isMobilePhoneVerified,
    bool? isEmailVerified,
    double? latitude,
    double? longitude,
    bool? isOnline,
    DateTime? lastActive,
    double? averageRating,
    int? reviewCount,
    String? profileImageUrl,
    String? gender,
    bool? notifyPush,
    bool? notifyEmail,
    bool? notifyInApp,
    List<String>? teachingModes,
    double? travelRadiusKm,
    double? homeRateDifferential,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      mobilePhone: mobilePhone ?? this.mobilePhone,
      role: role ?? this.role,
      children: children ?? this.children,
      bio: bio ?? this.bio,
      subjects: subjects ?? this.subjects,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      isMobilePhoneVerified: isMobilePhoneVerified ?? this.isMobilePhoneVerified,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isOnline: isOnline ?? this.isOnline,
      lastActive: lastActive ?? this.lastActive,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      gender: gender ?? this.gender,
      notifyPush: notifyPush ?? this.notifyPush,
      notifyEmail: notifyEmail ?? this.notifyEmail,
      notifyInApp: notifyInApp ?? this.notifyInApp,
      teachingModes: teachingModes ?? this.teachingModes,
      travelRadiusKm: travelRadiusKm ?? this.travelRadiusKm,
      homeRateDifferential: homeRateDifferential ?? this.homeRateDifferential,
    );
  }
}
