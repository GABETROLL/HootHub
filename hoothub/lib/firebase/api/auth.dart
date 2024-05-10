// models
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hoothub/firebase/models/user_scores.dart';
import 'clients.dart';
import 'package:hoothub/firebase/models/user.dart';
import 'package:hoothub/firebase/models/test.dart';

/// Signs up and logs in user with a private account.
///
/// Attempts to login+signup user into `FirebaseAuth`.
/// Attempts to add the user's `UserModel` and `UserScores` documents into `FirebaseFirestore`,
/// in their corresponding private collections, found in `clients.dart`.
///
/// The account can be made public, using the other functions in this file.
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
      password: password
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
      isPublic: false,
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
      isPublic: false,
      tests: <String>[],
    );
  } catch (error) {
    return "Error creating user's model: $error";
  }

  try {
    // NEW USER'S SCORES SHOULD BE PRIVATE BY DEFAULT.
    await privateUsersScoresCollection.doc(userId).set(userScoresModel.toJson());
  } on FirebaseException catch (error) {
    return "Error uploading new user's scores model: ${error.message ?? error.code}";
  } catch (error) {
    "Error uploading new user's scores model: $error";
  }

  try {
    // NEW USER'S PROFILE SHOULD BE PRIVATE BY DEFAULT.
    await privateUsersCollection.doc(userId).set(userModel.toJson());
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

/// Return the `UserModel` representation of the currently logged-in user (`auth.currentUser`),
/// which should be in the `publicUsers` or `privateUsers` FirebaseFirestore collections.
///
/// The `UserModel` document in the public collection should precede the one in the private collection,
/// if both are found.
///
/// The user, if they are logged in, should have their `uid` in `auth.currentUser!.uid`.
///
/// THROWS.
Future<UserModel?> loggedInUser() async {
  if (auth.currentUser == null) return null;

  UserModel? privateUserModel;
  UserModel? publicUserModel;

  final DocumentSnapshot<Map<String, dynamic>> privateUserSnapshot = await
    privateUsersCollection
      .doc(auth.currentUser!.uid)
      .get();
  privateUserModel = UserModel.fromSnapshot(privateUserSnapshot);

  final DocumentSnapshot<Map<String, dynamic>> publicUserSnapshot = await
    publicUsersCollection
      .doc(auth.currentUser!.uid)
      .get();
  publicUserModel = UserModel.fromSnapshot(publicUserSnapshot);

  if (publicUserModel != null) return publicUserModel;
  return privateUserModel;
}

/// Logs off and deletes the current logged in user's account.
///
/// First deletes this user's documents from BOTH
/// the public and private Firestore collections,
/// then calls `auth.currentUser!.delete()`.
///
/// Returns 'Ok' if everything seemed to be successful,
/// or the error string if something failed.
///
/// If there's no `auth.currentUser`,
/// this function returns "Cannot delete current user! No user logged in!".
Future<String> deleteLoggedInUser() async {
  if (auth.currentUser == null) return "Cannot delete current user! No user logged in!";

  try {
    String userId = auth.currentUser!.uid;

    await privateUsersCollection
      .doc(userId)
      .delete();
    await publicUsersCollection
      .doc(userId)
      .delete();

    await privateUsersScoresCollection
      .doc(userId)
      .delete();
    await publicUsersScoresCollection
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

/// Returns the `UserModel` document in the Firestore with `id` as its key.
///
/// The `UserModel` document will be searched in both the public and private users collections,
/// but the model coming from the public collection, if found, will take precedence over the one
/// found in the private collection.
///
/// This function THROWS if receiving the user document from the Firestore
/// failed, or if parsing the document into a `UserModel`,
/// using `UserModel.fromSnapshot`, also failed.
Future<UserModel?> userWithId(String id) async {
  final UserModel? privateUserModel = UserModel.fromSnapshot(await privateUsersCollection.doc(id).get());
  final UserModel? publicUserModel = UserModel.fromSnapshot(await publicUsersCollection.doc(id).get());

  if (privateUserModel != null) return privateUserModel;
  return publicUserModel;
}

/// Adds `testModel.id` to the `UserModel`s `publicTests`.
Future<String> addPublicTestToLoggedInUser(String testId) async {
  try {
    UserModel? userModel = await loggedInUser();

    if (userModel == null) {
      return 'Unable to construct user model.';
    }

    userModel.tests.add(testId);

    // The `userModel.isPublic` AND `userModel.id` SHOULD MATCH
    // THE COLLECTION AND DOCUMENT'S KEY,
    // BECAUSE OF Firestore Security Rules.
    if (userModel.isPublic) {
      await publicUsersCollection.doc(userModel.id).set(userModel.toJson());
    } else {
      await privateUsersCollection.doc(userModel.id).set(userModel.toJson());
    }
  } on FirebaseException catch (error) {
    return error.message ?? error.code;
  } catch (error) {
    return error.toString();
  }

  return 'Ok';
}
