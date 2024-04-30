import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// models
import 'package:hoothub/firebase/models/test.dart';
import 'package:hoothub/firebase/models/user.dart';

final _auth = FirebaseAuth.instance;
final _testsCollection = FirebaseFirestore.instance.collection('tests');
final _usersCollection = FirebaseFirestore.instance.collection('users');

/// Saves test in FirebaseFirestore, in the `tests` collection.
/// Also adds the test's backend-generated UID in the current user's document's `tests`.
///
/// TODO: FIGURE OUT WHAT TO DO IF THE TEST ALREADY HAS AN ID.
///
/// ASSUMES THAT TEST IS VALID.
///
/// If everything seems to go correctly, this function returns 'Ok'.
/// If a `FirebaseException` occurs, this function returns its `code`.
/// If any other error occurs, this function returns its `String` representation.
/// 
/// If the user's document wasn't found in the Firestore,
/// this function tries to delete the test's document in the Firestore,
/// then returns 'Current user credentials not found.'.
/// If deleting the document also fails, this function returns:
/// 'Current user credentials not found.\nDeleting uploaded test also failed:\n${errorStringOrCode}'
///
/// Schema:
/// C tests/
/// -- D testId
/// ---- userId
///
/// C users/
/// -- D userId
/// ---- tests: <testId>[...]
Future<String> saveTest(Test test) async {
  if (_auth.currentUser == null) {
    return 'No user logged in!';
  }

  DocumentReference<Map<String, dynamic>> testReference;

  // generate test UID and set `test.id`, if not already present.
  if (test.id == null) {
    testReference = _testsCollection.doc();
    test.id = testReference.id;
  } else {
    testReference = _testsCollection.doc(test.id);
  }

  DocumentSnapshot<Map<String, dynamic>> userSnapshot;
  try {
    userSnapshot = await _usersCollection.doc(_auth.currentUser!.uid).get();
  } on FirebaseException catch (error) {
    return error.code;
  } catch (error) {
    return error.toString();
  }
  UserModel? userModel = UserModel.fromSnapshot(userSnapshot);

  if (userModel == null) {
    return 'Error getting user credentials.';
  }

  userModel.tests.add(test.id!);

  try {
    await _usersCollection.doc(_auth.currentUser!.uid).set(userModel.toJson());
    await testReference.set(test.toJson());
  } on FirebaseException catch (error) {
    return error.code;
  } catch (error) {
    return error.toString();
  }

  return 'Ok';
}
