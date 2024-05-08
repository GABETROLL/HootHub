import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// models
import 'package:hoothub/firebase/models/test.dart';
import 'package:hoothub/firebase/models/user.dart';

final _auth = FirebaseAuth.instance;
final _testsCollection = FirebaseFirestore.instance.collection('tests');
final _usersCollection = FirebaseFirestore.instance.collection('users');

/// Saves `test` as a document in the `tests` FirebaseFirestore collection.
///
/// IF THESE FIELDS IN `test` ARE MISSING, THIS FUNCTION CREATES THEM IN-PLACE, IN `test`:
/// - `id` will be a unique test ID for the test document's key in the `tests` collection.
/// - `userId` will be the CURRENTLY LOGGED IN USER'S `uid` (_auth.currentUser!.uid)
///   (IF THE CURRENT USER IS NOT LOGGED IN, THIS FUNCTION JUST RETURNS 'No user logged in!').
/// - `dateCreated` will be `Timestamp.now()`.
///
/// TODO: VERIFY AND DOCUMENT THE TEST VALIDATION IN THE FIREBASE SECURITY RULES.
/// ANY OTHER IDs PRESENT IN `test`, NO MATTER HOW NESTED,
/// IS REQUIRED TO BE VALID.
///
/// RETURN VALUES
/// If everything seems to go correctly, this function returns 'Ok'.
/// If no user is currently logged in, this function returns 'No user logged in!'.
/// If a `FirebaseException` occurs, this function returns its `code`.
/// If any other error occurs, this function returns the `error.toString()`.
///
/// ERRORS
/// This function shouldn't throw.
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

  try {
    // The test's reference will either have `test.id` if that's not null,
    // or a generated unique ID.
    DocumentReference<Map<String, dynamic>> testReference = _testsCollection.doc(test.id);

    // If `test.id` is null,
    // I'll ASSUME THAT THE USER DOESN'T HAVE THIS TEST ALREADY,
    // AND IS CREATING A NEW TEST,
    // and add `testReference.id` to the user's model's `tests`.
    if (test.id == null) {
      DocumentReference<Map<String, dynamic>> userReference = _usersCollection.doc(_auth.currentUser!.uid);
      UserModel? userModel = UserModel.fromSnapshot(await userReference.get());

      if (userModel == null) {
        return 'Unable to construct user model.';
      }

      userModel.tests.add(testReference.id);

      await userReference.set(userModel.toJson());
    }

    // GENERATE OPTIONAL `test` DATA TO UPLOAD IT:

    // (to show the user the changes after the test has been uploaded)
    test.id ??= testReference.id;
    // TODO: REVIEW TEST EDITING PERMISSIONS IN THE BACKEND.
    test.userId ??= _auth.currentUser!.uid;
    test.dateCreated = Timestamp.now();

    // SAVE TEST TO ITS CORRESPONDING REFERENCE.
    await testReference.set(test.toJson());
  } on FirebaseException catch (error) {
    return error.message ?? error.code;
  } catch (error) {
    return error.toString();
  }

  return 'Ok';
}

/// Tries to find and return the test in the `tests` Firestore collection
/// that has `testId` as its key, and has `id: testId`.
///
/// If the test is private, and the user trying to fetch the test
/// isn't the test's owner, this function **SHOULD** return null,
/// BECAUSE THE FIREBASE SECURITY RULES SHOULD PREVENT THE USER FROM SEEING THE TEST.
Future<Test?> testWithId(String testId) async {
  try {
    DocumentSnapshot<Map<String, dynamic>> testSnapshot = await _testsCollection.doc(testId).get();
    Test? result = Test.fromSnapshot(testSnapshot);
    return result;
  } catch (error) {
    return null;
  }
}

/// Tries to return `querySnapshot.docs` as an Iterable<Test>.
///
/// If transforming an individual test `QueryDocumentSnapshot` to a `Test`
/// goes wrong, then THE ERROR GETS THROWN IN ITS PLACE IN THE ITERABLE.
///
/// If anything else goes wrong with this function, THE ERROR IS THROWN.
Future<Iterable<Test?>> queryTests(Query<Map<String, dynamic>> query) async {
  QuerySnapshot<Map<String, dynamic>> querySnapshot = await query.get();

  return querySnapshot.docs.map<Test?>(
    (QueryDocumentSnapshot<Map<String, dynamic>> queryDocumentSnapshot) {
      return Test.fromSnapshot(queryDocumentSnapshot);
    },
  );
}

/// Tries to return the `queryTests` representation of
/// the first `limit` newest/oldest tests in the Firestore `tests` collection.
/// The tests are ordered according to `newest`.
///
/// PLEASE READ THE DOCUMENTATION FOR `queryTests`!
Future<Iterable<Test?>> testsByDateCreated({ required int limit, required bool newest }) async {
  return await queryTests(
    _testsCollection
      .orderBy('dateCreated', descending: newest)
      .limit(limit),
  );
}

/// Tries to return the first `limit` tests in the Firestore `tests` collection,
/// that have the most/least NET UPVOTES.
///
/// NET UPVOTES ===== (upvotes - downvotes)
///
/// If something goes wrong with getting the tests or anything else in this function,
/// THE ERROR IS RETURNED.
/* Future<Iterable<Test?>> testsByNetUpvotes(int limit) async {
  // TODO: IMPLEMENT THE QUERY
}
 */
/// Returns **ALL** of the tests made by the `UserModel` with `id: userId`,
/// ordered according to `orderByNewest`.
Future<Iterable<Test?>> testsByUser(String userId, { required bool orderByNewest }) async {
  return await queryTests(
    _testsCollection
      .where('userId', isEqualTo: userId)
      .orderBy('dateCreated', descending: orderByNewest),
  );
}
/* 
Future<dynamic> testsByName(String nameQuery) async {
  return await 
} */