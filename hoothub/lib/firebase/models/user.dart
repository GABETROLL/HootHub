import 'package:cloud_firestore/cloud_firestore.dart';
import 'model.dart';

/// Independent model representing a user.
class UserModel implements Model {
  UserModel({
    required this.id,
    required this.username,
    required this.dateCreated,
  });

  final String id;
  final String username;
  final Timestamp dateCreated;

  /// Always returns true, for now.
  @override
  bool isValid() => true;

  /// Returns DEEP COPY of `this`.
  ///
  /// Immutable and deep fields are not copied.
  UserModel copy() => UserModel(
    id: id,
    username: username,
    dateCreated: dateCreated,
  );

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
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'dateCreated': dateCreated,
  };
}
