import 'package:cloud_firestore/cloud_firestore.dart';

/// Independent model representing a user.
class UserModel {
  UserModel({
    required this.id,
    required this.username,
    this.profileImageUrl,
    required this.dateCreated,
    required this.isPublic,
    required this.publicTests,
  });

  String id;
  String username;
  String? profileImageUrl;
  Timestamp dateCreated;
  bool isPublic;
  List<String> publicTests;

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
      isPublic: data['isPublic'],
      publicTests: (data['publicTests'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'profileImageUrl': profileImageUrl,
    'dateCreated': dateCreated,
    'isPublic': isPublic,
    'publicTests': publicTests,
  };
}
