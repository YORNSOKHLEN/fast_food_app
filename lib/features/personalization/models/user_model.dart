// lib/features/personalization/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/formatters/formatter.dart';

class UserModel {
  final String id;
  String? firstName;
  String? lastName;
  String? username;
  String? email;
  String? phoneNumber;
  String? profilePicture;
  String? gender;
  String? dateOfBirth;
  String? role;
  // final Timestamp? createdAt;
  // final Timestamp? updatedAt;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.profilePicture,
    this.gender,
    this.dateOfBirth,
    this.role = 'customer',
    // this.createdAt,
    // this.updatedAt,
  });

  /// Helper function to get the full name.
  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();

  /// Helper function to format phone number.
  String get formattedPhoneNo => YFormatter.formatPhoneNumber(phoneNumber ?? '');

  /// Static function to split full name into first and last name.
  static List<String> nameParts(fullName) => fullName.split(" ");

  /// Static function to generate a username from the full name.
  static String generateUsername(fullName) {
    List<String> nameParts = fullName.split(" ");
    String firstName = nameParts[0].toLowerCase();
    String lastName = nameParts.length > 1 ? nameParts[1].toLowerCase() : "";

    String camelCaseUsername =
        "$firstName$lastName"; // Combine first and last name
    String usernameWithPrefix = "cwt_$camelCaseUsername"; // Add "cwt_" prefix
    return usernameWithPrefix;
  }

  /// Static function to create an empty user model.
  static UserModel empty() => UserModel(
    id: '',
    firstName: '',
    lastName: '',
    username: '',
    email: '',
    phoneNumber: '',
    profilePicture: '',
    gender: '',
    dateOfBirth: '',
    role: 'customer',
  );

  Map<String, dynamic> toJson() {
    return {
      'FirstName': firstName,
      'LastName': lastName,
      'Username': username,
      'Email': email,
      'PhoneNumber': phoneNumber,
      'ProfilePicture': profilePicture,
      'Gender': gender,
      'DateOfBirth': dateOfBirth,
      'Role': role ?? 'customer',
    };
  }

  /// Factory method to create a UserModel from a Firebase document snapshot.
  factory UserModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    // Ensure we always return a UserModel instance. If snapshot has no data,
    // fall back to an empty model instead of exiting the function without
    // returning (which causes a compile-time error: "Not all code paths return a value").
    final data = document.data();
    if (data != null) {
      return UserModel(
        id: document.id,
        firstName: data['FirstName'] ?? '',
        lastName: data['LastName'] ?? '',
        username: data['Username'] ?? '',
        email: data['Email'] ?? '',
        phoneNumber: data['PhoneNumber'] ?? '',
        profilePicture: data['ProfilePicture'] ?? '',
        gender: data['Gender'] ?? '',
        dateOfBirth: data['DateOfBirth'] ?? '',
        role: data['Role'] ?? 'customer',
      );
    }

    // Fallback when snapshot has no data
    return UserModel.empty();
  }
} // TODO Implement this library.
