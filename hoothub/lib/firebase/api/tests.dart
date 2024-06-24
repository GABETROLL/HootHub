import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hoothub/firebase/api/auth.dart';
import 'clients.dart';
// models
import 'package:hoothub/firebase/models/test.dart';

class SaveTestResult {
  const SaveTestResult({
    required this.status,
    required this.updatedTest,
  });

  final String status;
  final Test updatedTest;
}

/// Saves `test` as a document in the `testsCollection`.
///
/// IF THESE FIELDS IN `test` ARE MISSING, THIS FUNCTION GENERATES THEM:
/// - `id` will be a unique test ID for the test document's key in the `tests` collection.
/// - `userId` will be the CURRENTLY LOGGED IN USER'S `uid` (auth.currentUser!.uid)
///   (IF THE CURRENT USER IS NOT LOGGED IN, THIS FUNCTION JUST RETURNS 'No user logged in!').
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
///
/// For `status`:
///
/// If everything seems to go correctly, this function returns 'Ok'.
/// If no user is currently logged in, this function returns 'No user logged in!'.
/// If a `FirebaseException` occurs, this function returns its `message ?? code`.
/// If any other error occurs, this function returns the `error.toString()`.
///
/// ERRORS
/// This function shouldn't throw.
Future<SaveTestResult> saveTest(Test test) async {
  if (auth.currentUser == null) return SaveTestResult(status: 'No user logged in!', updatedTest: test);

  try {
    // The test's reference will either have `test.id` if that's not null,
    // or a generated unique ID.
    DocumentReference<Map<String, dynamic>> testReference = testsCollection.doc(test.id);

    // IF THE TEST DOESN'T HAVE A `userId`,
    // ASSUME THAT IT'S BRAND NEW, AND
    // ADD THE TEST'S ID TO THE CURRENT USER'S ACCOUNT.
    String userId = auth.currentUser!.uid;

    if (test.userId == null) {
      addTestIdToLoggedInUser(testReference.id);
    }

    // GENERATE OPTIONAL `test` DATA TO UPLOAD IT:
    // (to show the user the changes after the test has been uploaded)
    // (THE MODEL WILL BE VALIDATED BY FIRESTORE SECURITY RULES)
    //
    // WARNING: IF THIS `try` CODE BLOCK FAILS MID-WAY THROUGH GENERATING `test`'s
    // VALUES, AND WHEN THE USER TRIES TO SAVE `test` AGAIN, THE CORRECT GENERATED VALUES
    // WOULD TURN OUT TO BE DIFFERENT, THE NEW VALUES WON'T GENERATE, SINCE THE OLD ONES
    // ARE ALREADY OCCUPYING THEIR PLACE IN `test`.
    // TODO; MAKE SURE THIS DOESN'T HAPPEN!

    if (test.id == null) {
      test = test.setId(testReference.id);
    }
    if (test.userId == null) {
      test = test.setUserId(userId);
    }
    if (test.dateCreated == null) {
      test = test.setDateCreated(Timestamp.now());
    }

    // SAVE TEST TO ITS CORRESPONDING REFERENCE.
    await testReference.set(test.toJson());
  } on FirebaseException catch (error) {
    return SaveTestResult(status: error.message ?? error.code, updatedTest: test);
  } catch (error) {
    return SaveTestResult(status: error.toString(), updatedTest: test);
  }

  return SaveTestResult(status: 'Ok', updatedTest: test);
}

/// Returns the test in the `testsCollection` with `testId` as its key.
///
/// If the test is not found, this function returns null.
///
/// THROWS.
Future<Test?> testWithId(String testId) async {
  return Test.fromSnapshot(await testsCollection.doc(testId).get());
}

/// Votes on `test` according to `up`.
///
/// This function updates the model in Cloud Firestore
/// AND returns the changes to `test`, for local updating.
///
/// If the user has already voted in the opposite voting list,
/// that vote is removed.
///
/// If the user has already voted in the current list,
/// that vote is removed, and the current vote is NOT ADDED.
///
/// If the user has not already voted in the current list,
/// the vote is added.
///
/// SHOULDN'T THROW.
Future<SaveTestResult> voteOnTest({ required Test test, required bool up }) async {
  try {
    String voteString = up ? 'up' : 'down';

    if (auth.currentUser == null) {
      return SaveTestResult(status: "You're not logged in! Log in to ${voteString}vote!", updatedTest: test);
    }

    if (test.id == null) return SaveTestResult(status: "Test has no id!", updatedTest: test);

    // ALTER VOTING LISTS, BUT SAFELY, IN TEST'S COPY:
    // (THE LISTS ARE ALSO SAFELY AND DEEPLY COPIED WITH `.copy()`)
    final Test testCopy = test.copy();

    List<String> votingList = (
      up
      ? testCopy.usersThatUpvoted
      : testCopy.usersThatDownvoted
    );
    List<String> oppositeVotingList = (
      up
      ? testCopy.usersThatDownvoted
      : testCopy.usersThatUpvoted
    );

    if (oppositeVotingList.contains(auth.currentUser!.uid)) {
      oppositeVotingList.remove(auth.currentUser!.uid);
    }

    if (votingList.contains(auth.currentUser!.uid)) {
      votingList.remove(auth.currentUser!.uid);
    } else {
      votingList.add(auth.currentUser!.uid);
    }

    return saveTest(testCopy);
  } on FirebaseException catch (error) {
    return SaveTestResult(status: error.message ?? error.code, updatedTest: test);
  } catch (error) {
    return SaveTestResult(status: error.toString(), updatedTest: test);
  }
}

/// Tries to execute the `query` and return its `docs` result as an List<Test?>.
///
/// Some tests in the result may be null, if their snapshots don't have
/// any data.
///
/// IF AN ERROR HAPPENS WHILE CONVERTING ANY `QueryDocumentSnapshot`
/// TO A `Test`, ITERATING OVER ANY `QueryDocumentSnapshot`,
/// OR ANYWHERE ELSE, IT'S THROWN, AND THE WHOLE QUERY RESULT WILL
/// NOT BE RETURNED.
Future<List<Test?>> queryTests(Query<Map<String, dynamic>> query) async {
  QuerySnapshot<Map<String, dynamic>> querySnapshot = await query.get();

  return List<Test?>.from(
    querySnapshot.docs.map<Test?>(
      (QueryDocumentSnapshot<Map<String, dynamic>> queryDocumentSnapshot) {
        return Test.fromSnapshot(queryDocumentSnapshot);
      },
    ),
  );
}

/// Tries to return
/// the first `limit` newest/oldest tests in the Firestore `tests` collection,
/// using `queryTests`.
///
/// The tests are ordered according to `newest`.
///
/// PLEASE READ THE DOCUMENTATION FOR `queryTests`!
Future<List<Test?>> testsByDateCreated({ required int limit, required bool newest }) {
  return queryTests(
    testsCollection
      .orderBy('dateCreated', descending: newest)
      .limit(limit),
  );
}

/// Tries to return the first `limit` tests in the Firestore `tests` collection,
/// that have the MOST/LEAST NET UPVOTES.
///
/// NET UPVOTES ===== (upvotes - downvotes)
///
/// PLEASE READ THE DOCUMENTATION FOR `queryTests`!
Future<List<Test?>> testsByNetUpvotes({ required int limit, required bool most }) {
  return queryTests(
    testsCollection
      .orderBy('usersThatUpvoted', descending: most)
      .orderBy('usersThatDownvoted', descending: !most)
      .limit(limit),
  );
}

/// Tries to return the first `limit` tests in the Firestore `tests` collection,
/// that have the MOST/LEAST UPVOTES.
///
/// PLEASE READ THE DOCUMENTATION FOR `queryTests`!
Future<List<Test?>> testsByUpvotes({ required int limit, required bool most }) {
  return queryTests(
    testsCollection
      .orderBy('usersThatUpvoted', descending: most)
      .limit(limit),
  );
}

/// Tries to return the first `limit` tests in the Firestore `tests` collection,
/// that have the MOST/LEAST DOWNVOTES
///
/// NET UPVOTES ===== (upvotes - downvotes)
///
/// PLEASE READ THE DOCUMENTATION FOR `queryTests`!
Future<List<Test?>> testsByDownvotes({required int limit, required bool most }) {
  return  queryTests(
    testsCollection
      .orderBy('usersThatDownvoted', descending: most)
      .limit(limit),
  );
}

/// Returns all tests made by the user with `userId` as their key
/// (that have `userId: userId` in their documents),
/// ordered by `orderByNewest`.
///
/// PLEASE READ THE DOCUMENTATION FOR `queryTests`!
Future<List<Test?>> testsByUser(String userId, { required bool orderByNewest }) async {
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

typedef TestQuery = Future<List<Test?>> Function();
