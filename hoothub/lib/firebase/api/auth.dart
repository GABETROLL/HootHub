import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// models
import 'package:hoothub/firebase/models/user.dart';

final _auth = FirebaseAuth.instance;
final _collection = FirebaseFirestore.instance.collection('users');

/// Returns 'Ok' if successful.
///
/// If there was an error,
/// returns the FirebaseException error's `code`,
/// or the error's `toString()`.
/// 
/// If the `UserCredential` returned by `FirebaseAuth.instance.createUserWithEmailAndPassword`
/// doesn't have a `user`, this function returns 'Failed to create and login user'.
Future<String> signUpUser({
  required String email,
  required String password,
  required String username
}) async {
  try {
    final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password
    );

    if (userCredential.user == null) {
      throw 'Failed to create and login user';
    }

    final String userId = userCredential.user!.uid;

    final UserModel userModel = UserModel(
      id: userId,
      username: username,
      dateCreated: Timestamp.now(),
      tests: <String>[],
      likedTests: <String>[],
      savedTests: <String>[],
    );

    await _collection.doc(userId).set(userModel.toJson());
  } on FirebaseException catch (error) {
    return error.code;
  } catch (error) {
    return error.toString();
  }

  return 'Ok';
}

/// Returns 'Ok' if successful.
///
/// If there was an error,
/// returns the FirebaseException error's `code`,
/// or the error's `toString()`.
///
/// If the `UserCredential` returned by `FirebaseAuth.instance.signInWithEmailAndPassword`
/// doesn't have a `user`, this function throws 'Failed to login user'.
Future<String> logInUser({required String email, required String password}) async {
  try {
    final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password
    );

    if (userCredential.user == null) {
      return 'Failed to login user';
    }
  } on FirebaseException catch (error) {
    return error.code;
  } catch (error) {
    error.toString();
  }

  return 'Ok';
}

/// Return the `UserModel` representation of the currently logged-in user (`_auth.currentUser`).
/// The user, if they are logged in, should have their `uid` in `_auth.currentUser!.uid`
Future<UserModel?> loggedInUser() async {
  if (_auth.currentUser == null) return null;

  try {
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await _collection
      .doc(_auth.currentUser!.uid)
      .get();
    return UserModel.fromSnapshot(snapshot);
  } catch (error) {
    return null;
  }
}

/// Returns the `userModel` representation of the `FirebaseFirestore` user with `id` as its id.
///
/// This function THROWS if receiving the user document from the Firestore
/// failed, or if parsing the document into a `UserModel`,
/// using `UserModel.fromSnapshot`, also failed.
Future<UserModel?> userWithId(String id) async {
  return UserModel.fromSnapshot(await _collection.doc(id).get());
}
