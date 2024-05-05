import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// models
import 'package:hoothub/firebase/models/test.dart';
import 'package:hoothub/firebase/models/user.dart';

final _auth = FirebaseAuth.instance;
final _testsCollection = FirebaseFirestore.instance.collection('tests');
final _usersCollection = FirebaseFirestore.instance.collection('users');

/// Saves test in FirebaseFirestore, in the `tests` collection.
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
/// DESCRIPTION: IDs:
/// Uses `test.id` to determine the path of the `test` in the `tests` collection.
/// This function 'saves' the `test` by overriding any existing document in the `tests` collection
/// assinged the same path.
///
/// If the `test.id` is not provided, this function MODIFIES `test` IN-PLACE
/// to assign `test.id = UID_GENERATED_BY_FIRESTORE`.
///
/// If the `test.userId` is provided, but doesn't match the current user's ID,
/// this function returns 'This test is not yours!'.
///
/// If the `test.user` is not provided, this function MODIFIES `test` IN-PLACE
/// to assign `test.userId = CURRENT_USER_ID`.
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
    // generate test UID and set `test.id` (locally), if not already present.
    // if `test.id` is not null, the `testReference` will have it as the path.
    // Otherwise, `doc` will recieve null, and will generate the test's UID automatically,
    // which we can then place in `test.id`.
    DocumentReference<Map<String, dynamic>> testReference = _testsCollection.doc(test.id);
    // TODO: COPY BEFORE ALTERING. (To do this, you'd have to re-download the test
    // to show the user the changes after the test has been uploaded)
    test.id ??= testReference.id;

    // Check if the test already belongs to someone else that's not the currently logged in user,
    // by comparing `test.userId` to `_auth.currentUser!.uid`,
    //
    // Or assign `test.userId = _auth.currentUser!.uid` if `test.userId` is not provided.
    if (test.userId != null && _auth.currentUser!.uid != test.userId) {
      return 'This test is not yours!';
    }
    test.userId = _auth.currentUser!.uid;

    // Add `test.id` to the user's `tests`, in the Firestore.
    DocumentReference<Map<String, dynamic>> userReference = _usersCollection.doc(_auth.currentUser!.uid);
    UserModel? userModel = UserModel.fromSnapshot(await userReference.get());
    if (userModel == null) {
      return 'Unable to construct user model.';
    }

    // TODO: Find a way to make this O(1) instead of O(N).
    // Currently, `userModel.tests` is a list.
    if (!(userModel.tests.contains(test.id))) {
      userModel.tests.add(test.id);
    }

    await userReference.set(userModel.toJson());

    // Save test to its corresponding reference (in the Firestore).
    await testReference.set(test.toJson());
  } on FirebaseException catch (error) {
    return error.message ?? error.code;
  } catch (error) {
    return error.toString();
  }

  return 'Ok';
}

/// Tries to return `querySnapshot.docs` as an Iterable<Test>.
///
/// If transforming an individual test `QueryDocumentSnapshot` to a `Test`
/// goes wrong, then THE ERROR TAKES THE TEST'S PLACE IN THE RETURNED ITERABLE.
///
/// If anything else goes wrong with this function, THE ERROR IS RETURNED.
dynamic queryTests(Query<Map<String, dynamic>> query) async {
  try {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await query.get();

    return querySnapshot.docs.map<dynamic>(
      (QueryDocumentSnapshot<Map<String, dynamic>> queryDocumentSnapshot) {
        try {
          return Test.fromSnapshot(queryDocumentSnapshot);
        } catch (error) {
          return error;
        }
      },
    );
  } catch (error) {
    return error;
  }
}

/// Tries to return the `querySnapshotTests` representation of
/// the first `limit` newest/oldest tests in the Firestore `tests` collection.
/// The tests are ordered according to `newest`.
///
/// If anything goes wrong with getting the tests or anything else in this function,
/// THE ERROR IS RETURNED.
Future<dynamic> testsByDateCreated(int limit, { required bool newest }) async {
  return await queryTests(
    _testsCollection
      .orderBy('dateCreated')
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
Future<dynamic> testsByNetUpvotes(int limit) async {
  // TODO: IMPLEMENT THE QUERY
}

/// Returns **ALL** of the tests made by the `UserModel` with `id: userId`,
/// ordered according to `orderByNewest`.
Future<dynamic> testsByUser(String userId, { required bool orderByNewest }) async {
  return await queryTests(
    _testsCollection
      .where('userId', isEqualTo: userId)
      .orderBy('dateCreated', descending: orderByNewest),
  );
}
