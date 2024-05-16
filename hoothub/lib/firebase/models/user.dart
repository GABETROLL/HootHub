import 'package:cloud_firestore/cloud_firestore.dart';

/// Independent model representing a user.
class UserModel {
  UserModel({
    required this.id,
    required this.username,
    required this.dateCreated,
    required this.tests,
  });

  String id;
  String username;
  Timestamp dateCreated;
  List<String> tests;

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
      dateCreated: data['dateCreated'],
      tests: (data['tests'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'dateCreated': dateCreated,
    'tests': tests,
  };
}
