import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  UserModel({
    required this.id,
    required this.username,
    this.profileImageUrl,
    required this.dateCreated,
    required this.tests,
    required this.likedTests,
    required this.savedTests,
    this.likedTestsPublic = false,
    this.savedTestsPublic = false,
  });

  String id;
  String username;
  String? profileImageUrl;
  Timestamp dateCreated;
  List<String> tests;
  List<String> likedTests;
  List<String> savedTests;
  bool likedTestsPublic;
  bool savedTestsPublic;

  /// Returns the `UserModel` representation of `snapshot.data()`.
  /// If the data is null, this method returns null.
  /// If any of the fields are wrong, the constructor call inside this method
  /// takes care of those errors, and throws them up the stack.
  static UserModel? fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic>? data = snapshot.data();

    if (data == null) return null;

    return UserModel(
      id: data['id'],
      username: data['username'],
      profileImageUrl: data['profileImageUrl'],
      dateCreated: data['dateCreated'],
      tests: data['tests'],
      likedTests: data['likedTests'],
      savedTests: data['savedTests'],
      likedTestsPublic: data['likedTestsPublic'],
      savedTestsPublic: data['savedTestsPublic'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'profileImageUrl': profileImageUrl,
    'dateCreated': dateCreated,
    'tests': tests,
    'likedTests': likedTests,
    'savedTests': savedTests,
    'likedTestsPublic': likedTestsPublic,
    'savedTestsPublic': savedTestsPublic,
  };
}
