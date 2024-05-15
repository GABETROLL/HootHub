import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hoothub/firebase/api/auth.dart';
import 'clients.dart';
// models
import 'package:hoothub/firebase/models/test.dart';

/// Saves `test` as a document in the `testsCollection`.
///
/// IF THESE FIELDS IN `test` ARE MISSING, THIS FUNCTION CREATES THEM IN-PLACE, IN `test`:
/// - `id` will be a unique test ID for the test document's key in the `tests` collection.
/// - `userId` will be the CURRENTLY LOGGED IN USER'S `uid` (auth.currentUser!.uid)
///   (IF THE CURRENT USER IS NOT LOGGED IN, THIS FUNCTION JUST RETURNS 'No user logged in!').///   
/// - `dateCreated` will be `Timestamp.now()`.
/// 
/// IF THE `test` DOES NOT HAVE A `userId`, THIS FUNCTION ASSUMES THIS IS A BRAND NEW TEST,
/// AND ADDS THE TEST'S ID TO THE CURRENTLY LOGGED IN USER, USING `addTestIdToLoggedInUser(testReference.id)`.
///
/// IF THE USER UPLOADING THIS TEST DOES NOT OWN THE NEW TEST (`userId` doesn't match `auth.currentUser!.uid`)
/// OR THERE ALREADY EXISTS A TEST WITH `test.id` AS ITS KEY, THE FIRESTORE SECURITY RULES
/// WON'T ALLOW THIS OPERATION.
///
/// ANY OTHER IDs PRESENT IN `test`, NO MATTER HOW NESTED,
/// ARE REQUIRED TO BE VALID.
///
/// THE DOCUMENT SHOULD BE VERIFIED IN THE FIRESTORE SECURITY RULES.
///
/// RETURN VALUES
/// If everything seems to go correctly, this function returns 'Ok'.
/// If no user is currently logged in, this function returns 'No user logged in!'.
/// If a `FirebaseException` occurs, this function returns its `message ?? code`.
/// If any other error occurs, this function returns the `error.toString()`.
///
/// ERRORS
/// This function shouldn't throw.
Future<String> saveTest(Test test) async {
  if (auth.currentUser == null) return 'No user logged in!';

  try {
    // The test's reference will either have `test.id` if that's not null,
    // or a generated unique ID.
    DocumentReference<Map<String, dynamic>> testReference = testsCollection.doc(test.id);

    String userId = auth.currentUser!.uid;

    // GENERATE OPTIONAL `test` DATA TO UPLOAD IT:
    // (to show the user the changes after the test has been uploaded)
    // (THE MODEL WILL BE VALIDATED BY FIRESTORE SECURITY RULES)
    test.id ??= testReference.id;
    test.userId ??= userId;
    test.dateCreated = Timestamp.now();

    // IF THE TEST DOESN'T HAVE A `userId`,
    // ASSUME THAT IT'S BRAND NEW, AND
    // ADD THE TEST'S ID TO ITS CORRESPONDING USER.
    if (test.userId == null) {
      addTestIdToLoggedInUser(testReference.id);
    }

    // SAVE TEST TO ITS CORRESPONDING REFERENCE.
    await testReference.set(test.toJson());
  } on FirebaseException catch (error) {
    return error.message ?? error.code;
  } catch (error) {
    return error.toString();
  }

  return 'Ok';
}

/// Returns the test in the `testsCollection` with `testId` as its key.
///
/// If the test is not found, this function returns null.
///
/// THROWS.
Future<Test?> testWithId(String testId) async {
  return Test.fromSnapshot(await testsCollection.doc(testId).get());
}

/// Tries to execute the `query` and return its `docs` result as an Iterable<Test>.
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

/// Tries to return
/// the first `limit` newest/oldest tests in the Firestore `tests` collection,
/// using `queryTests`.
///
/// The tests are ordered according to `newest`.
///
/// PLEASE READ THE DOCUMENTATION FOR `queryTests`!
Future<Iterable<Test?>> testsByDateCreated({ required int limit, required bool newest }) async {
  return await queryTests(
    testsCollection
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

/// Returns all tests made by the user with `userId` as their key
/// (that have `userId: userId` in their documents),
/// ordered by `orderByNewest`.
Future<Iterable<Test?>> testsByUser(String userId, { required bool orderByNewest }) async {
  return await queryTests(
    testsCollection
      .where('userId', isEqualTo: userId)
      .orderBy('dateCreated', descending: orderByNewest),
  );
}
/* 
Future<dynamic> testsByName(String nameQuery) async {
  return await 
} */
