import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hoothub/firebase/api/auth.dart';
import 'clients.dart';
// models
import 'package:hoothub/firebase/models/test.dart';

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
  if (auth.currentUser == null) {
    return 'No user logged in!';
  }

  try {
    // The test's reference will either have `test.id` if that's not null,
    // or a generated unique ID.
    // And the test's collection will be the public/private one, depending on `isPublic`.
    DocumentReference<Map<String, dynamic>> testReference;

    String userId = auth.currentUser!.uid;

    if (test.isPublic == true) {
      testReference = publicTestsCollection.doc(test.id);

      // If `test.id` is null,
      // I'll ASSUME THAT THE USER DOESN'T HAVE THIS TEST ALREADY,
      // AND IS CREATING A NEW TEST,
      // and add `testReference.id` to the user's model's `tests`.
      if (test.id == null) {
        addTestIdToLoggedInUser(testReference.id);
      }
    } else {
      testReference = testsCollection.doc(test.id);
    }

    // GENERATE OPTIONAL `test` DATA TO UPLOAD IT:
    // (to show the user the changes after the test has been uploaded)
    // (`userId` and `id` WILL BE VALIDATED BY Firestore Security Rules)
    test.id ??= testReference.id;
    test.userId ??= userId;
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

/// Tries to find and return the test
/// in both the public and private test collections in the Firestore,
/// that have `testId` as its key.
///
/// If the test is found in both the public and the private collections,
/// the one in the public collection is returned.
///
/// If the test is private, and the user trying to fetch the test
/// isn't the test's owner, this function **SHOULD** return null,
/// BECAUSE THE FIREBASE SECURITY RULES SHOULD PREVENT THE USER FROM SEEING THE TEST.
Future<Test?> testWithId(String testId) async {
  try {
    Test? publicResult = Test.fromSnapshot(await publicTestsCollection.doc(testId).get());
    Test? privateResult = Test.fromSnapshot(await testsCollection.doc(testId).get());

    if (publicResult != null) return publicResult;
    return privateResult;
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
    publicTestsCollection
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

/// Returns all public tests that have `userId: userId`, ordered according to `orderByNewest`.
Future<Iterable<Test?>> testsByUser(String userId, { required bool orderByNewest }) async {
  return await queryTests(
    publicTestsCollection
      .where('userId', isEqualTo: userId)
      .orderBy('dateCreated', descending: orderByNewest),
  );
}
/* 
Future<dynamic> testsByName(String nameQuery) async {
  return await 
} */