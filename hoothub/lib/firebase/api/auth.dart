// models
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hoothub/firebase/models/test_result.dart';
import 'package:hoothub/firebase/models/user_scores.dart';
import 'clients.dart';
import 'package:hoothub/firebase/models/user.dart';

/// Signs up and logs in user with a private account.
///
/// Attempts to login+signup user into `FirebaseAuth`.
/// Attempts to add the user's `UserModel` and `UserScores` documents into `FirebaseFirestore`,
/// in their corresponding collections, found in `clients.dart`.
///
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
  final UserCredential userCredential;

  try {
    userCredential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  } on FirebaseException catch (error) {
    return 'Error signing up and logging in user into FirebaseAuth: ${error.message ?? error.code}';
  } catch (error) {
    return 'Error signing up and logging in user into FirebaseAuth: $error';
  }

  final String userId;

  try {
    userId = userCredential.user!.uid;
  } catch (error) {
    return 'Error reading user credential: $error';
  }

  final UserScores userScoresModel;

  try {
    userScoresModel = UserScores(
      userId: userId,
      questionsAnswered: 0,
      questionsAnsweredCorrect: 0,
    );
  } catch (error) {
    return "Error creating user's scores model: $error";
  }

  final UserModel userModel;

  try {
    userModel = UserModel(
      id: userId,
      username: username,
      dateCreated: Timestamp.now(),
    );
  } catch (error) {
    return "Error creating user's model: $error";
  }

  try {
    await usersScoresCollection.doc(userId).set(userScoresModel.toJson());
  } on FirebaseException catch (error) {
    return "Error uploading new user's scores model: ${error.message ?? error.code}";
  } catch (error) {
    "Error uploading new user's scores model: $error";
  }

  try {
    await usersCollection.doc(userId).set(userModel.toJson());
  } on FirebaseException catch (error) {
    return "Error uploading new user's model: ${error.message ?? error.code}";
  } catch (error) {
    "Error uploading new user's model: $error";
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
/// doesn't have a `user`, this function returns 'Failed to login user'.
Future<String> logInUser({required String email, required String password}) async {
  try {
    final UserCredential userCredential = await auth.signInWithEmailAndPassword(
      email: email,
      password: password
    );

    if (userCredential.user == null) {
      return 'Failed to login user';
    }
  } on FirebaseException catch (error) {
    return error.code;
  } catch (error) {
    return error.toString();
  }

  return 'Ok';
}

/// Returns the `UserModel` representation of the currently logged-in user (`auth.currentUser`),
/// which should be in the `usersCollection`, defined in `clients.dart`.
///
/// The user, if they are logged in, should have their `uid` in `auth.currentUser!.uid`.
/// If `auth.currentUser` is null, that means the user is not logged in,
/// and this function should return null.
///
/// THROWS.
Future<UserModel?> loggedInUser() async {
  if (auth.currentUser == null) return null;

  final DocumentSnapshot<Map<String, dynamic>> userSnapshot = await
    usersCollection
      .doc(auth.currentUser!.uid)
      .get();

  return UserModel.fromSnapshot(userSnapshot);
}

/// Logs off and deletes the current logged in user's account.
///
/// First deletes this user's documents from BOTH
/// the `usersScoresCollection` and `usersCollection`,
/// then calls `auth.currentUser!.delete()`.
///
/// If there's no `auth.currentUser`,
/// this function returns "Cannot delete current user! No user logged in!".
///
/// Returns 'Ok' if everything seemed to be successful,
/// or the error string if something failed.

Future<String> deleteLoggedInUser() async {
  if (auth.currentUser == null) return "Cannot delete current user! No user logged in!";

  try {
    String userId = auth.currentUser!.uid;

    await usersCollection
      .doc(userId)
      .delete();

    await usersScoresCollection
      .doc(userId)
      .delete();

    await auth.currentUser!.delete();
  } on FirebaseException catch (error) {
    return error.message ?? error.code;
  } catch (error) {
    return error.toString();
  }

  return 'Ok';
}

/// Returns the `UserModel` document in the `usersCollection` with `id` as its key.
///
/// If the document doesn't exist, this function SHOULD return null.
///
/// This function THROWS.
/// For example:
/// if receiving the user document from the Firestore
///   failed,
/// or if parsing the document into a `UserModel`,
///   using `UserModel.fromSnapshot`, also failed.
Future<UserModel?> userWithId(String id) async {
  return UserModel.fromSnapshot(await usersCollection.doc(id).get());
}

Future<String> updateLoggedInUserScores(TestResult testResult) async {
  final String? userId = auth.currentUser?.uid;

  if (userId == null) {
    return "You are not logged in!";
  }

  final UserScores? userScores;

  try {
    userScores = UserScores.fromSnapshot(await usersScoresCollection.doc(userId).get());
  } catch (error) {
    return "Failed to get your scores...";
  }

  if (userScores == null) {
    return "Failed to modify your scores. Your scores were not found!";
  }

  UserScores userScoresWithChanges;

  try {
    userScoresWithChanges = userScores.update(
      testResult.questionsAnsweredCorrect,
      testResult.questionsAnswered,
    );
  } catch (error) {
    return "Failed to modify your scores...";
  }

  try {
    await usersScoresCollection.doc(userId).set(userScoresWithChanges.toJson());
  } catch (error) {
    return "Failed to modify your scores...";
  }

  return "Ok";
}
