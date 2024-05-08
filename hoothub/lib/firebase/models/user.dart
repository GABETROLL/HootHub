import 'package:cloud_firestore/cloud_firestore.dart';

/// Front-end representation for a user document,
/// in the `users` collection, in Firestore.
///
/// The `List` arguments are meant to be lists of test ID's:
/// the paths of the tests in the Firestore `tests` collection.
class UserModel {
  UserModel({
    required this.id,
    required this.username,
    this.profileImageUrl,
    required this.dateCreated,
    required this.tests,
    required this.upvotedTests,
    required this.downvotedTests,
  });

  String id;
  String username;
  String? profileImageUrl;
  Timestamp dateCreated;
  List<String> tests;
  List<String> upvotedTests;
  List<String> downvotedTests;

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
      tests: (data['tests'] as List<dynamic>).cast<String>(),
      upvotedTests: (data['upvotedTests'] as List<dynamic>).cast<String>(),
      downvotedTests: (data['downvotedTests'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'profileImageUrl': profileImageUrl,
    'dateCreated': dateCreated,
    'tests': tests,
    'upvotedTests': upvotedTests,
    'downvotedTests': downvotedTests,
  };
}
