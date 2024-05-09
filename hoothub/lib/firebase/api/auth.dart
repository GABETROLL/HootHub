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
  try {
    final UserCredential userCredential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password
    );

    if (userCredential.user == null) {
      throw 'Failed to create and login user';
    }

    final String userId = userCredential.user!.uid;

    // BY DEFAULT, THE USER AND THEIR SCORES SHOULD BE PRIVATE.
    DocumentReference<Map<String, dynamic>> userScoresReference = privateUsersScoresCollection.doc();

    final UserScores userScoresModel = UserScores(
      id: userScoresReference.id,
      userId: userId,
      isPublic: false,
      questionsAnswered: 0,
      questionsAnsweredCorrect: 0,
    );

    final UserModel userModel = UserModel(
      id: userId,
      username: username,
      dateCreated: Timestamp.now(),
      isPublic: false,
      userScoresId: userScoresReference.id,
      publicTests: <String>[],
    );

    await userScoresReference.set(userScoresModel.toJson());
    await privateUsersCollection.doc(userId).set(userModel.toJson());
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
/// If something goes wrong, or the user model is not found in either collection,
/// or if the user isn't currently logged in, this function returns null.
Future<UserModel?> loggedInUser() async {
  if (auth.currentUser == null) return null;

  UserModel? privateUserModel;
  UserModel? publicUserModel;

  try {
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
  } catch (error) {
    return null;
  }

  if (publicUserModel != null) return publicUserModel;
  return privateUserModel;
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
Future<String> addTestToUserWithId(String id, Test testModel) async {
  try {
    UserModel? userModel = await userWithId(auth.currentUser!.uid);

    if (userModel == null) {
      return 'Unable to construct user model.';
    }

    if (testModel.isPublic) {
      if (testModel.id == null) return 'Test has no ID!';
      userModel.publicTests.add(testModel.id!);
    }

    if (userModel.isPublic) {
      await publicUsersCollection.doc(id).set(userModel.toJson());
    } else {
      await privateUsersCollection.doc(id).set(userModel.toJson());
    }
  } on FirebaseException catch (error) {
    return error.message ?? error.code;
  } catch (error) {
    return error.toString();
  }

  return 'Ok';
}
