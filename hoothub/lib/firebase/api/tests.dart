import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hoothub/firebase/api/auth.dart';
import 'package:hoothub/firebase/models/test_result.dart';
import 'package:hoothub/firebase/models/user_scores.dart';
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

class SaveTestNullableResult {
  const SaveTestNullableResult({
    required this.status,
    required this.updatedTest,
  });

  final String status;
  final Test? updatedTest;
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
/// IF THE USER UPLOADING THIS `test` DOES NOT OWN IT, (test.userId` doesn't match `auth.currentUser!.uid`),
/// this function won't upload the test, and will consider it invalid.
///
/// [OUTDATED?]
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
  final User? currentUser = auth.currentUser;

  if (currentUser == null) return SaveTestResult(status: 'No user logged in!', updatedTest: test);

  try {
    // The test's reference will either have `test.id` if that's not null,
    // or a generated unique ID.
    DocumentReference<Map<String, dynamic>> testReference = testsCollection.doc(test.id);

    String userId = currentUser.uid;

    // GENERATE OPTIONAL `test` DATA TO UPLOAD IT:
    // (to show the user the changes after the test has been uploaded)
    // (THE MODEL WILL BE VALIDATED BY FIRESTORE SECURITY RULES)

    if (test.id == null) {
      test = test.setId(testReference.id);
    }

    if (test.userId == null) {
      test = test.setUserId(userId);
    } else if (test.userId != userId) {
      // Test doesn't belong to the current user!
      return SaveTestResult(status: "Invalid test!", updatedTest: test);
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

  return SaveTestResult(status: 'Saved test successfully!', updatedTest: test);
}

/// Returns the test in the `testsCollection` with `testId` as its key.
///
/// If the test is not found, this function returns null.
///
/// THROWS.
Future<Test?> testWithId(String testId) async {
  return Test.fromSnapshot(await testsCollection.doc(testId).get());
}

/// Deletes test  with `testId` as its key from `testsCollection`.
/// Removes all of the 
Future<String> deleteTestWithId(String testId) async {
  try {
    Test testModel = Test.fromSnapshot(await testsCollection.doc(testId).get())!;
    String testAuthorId = testModel.userId!;
    UserScores testAuthorScores = (await scoresOfUserWithId(testAuthorId))!;

    testAuthorScores = testAuthorScores.setNetUpvotes(testAuthorScores.netUpvotes - testModel.upvotes);
    testAuthorScores = testAuthorScores.setNetDownvotes(testAuthorScores.netDownvotes - testModel.downvotes);
    testAuthorScores = testAuthorScores.setNetComments(testAuthorScores.netComments - testModel.commentCount);

    await testsCollection.doc(testId).delete();
    await usersScoresCollection.doc(testAuthorId).set(testAuthorScores.toJson());
  } catch (error) {
    return "Failed to delete your test...";
  }

  return "Test deleted successfully!";
}

/// Votes on `test` according to `up`,
/// then adds the user's votes to the test's author's `UserScores` document.
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
  String voteString = up ? 'up' : 'down';
  String errorMessage = "An error occured while ${voteString}voting...";

  try {
    // 1) Gather the current user's ID, the test's author, and the test's author's scores

    String? userId = auth.currentUser?.uid;
    if (userId == null) {
      return SaveTestResult(status: "You don't seem logged in! Log in to ${voteString}vote!", updatedTest: test);
    }

    String? testId = test.id;
    if (testId == null) return SaveTestResult(status: "Failed to ${voteString}vote on test...", updatedTest: test);

    String? testAuthorId = test.userId;
    if (testAuthorId == null) {
      return SaveTestResult(
        status: "Failed to ${voteString}vote on test...",
        updatedTest: test,
      );
    }

    UserScores? testAuthorScores = await scoresOfUserWithId(testAuthorId);
    if (testAuthorScores == null) {
      return SaveTestResult(
        status: "Failed to ${voteString}vote on test...",
        updatedTest: test,
      );
    }

    // 2) Alter the test and the test's author's voting information

    // ALTER VOTING LISTS, BUT SAFELY, IN TEST'S COPY:
    // (THE LISTS ARE ALSO SAFELY AND DEEPLY COPIED WITH `.copy()`)
    Test testCopy = test.copy();

    void removeUpvote(UserScores testAuthorScores) {
      testCopy.usersThatUpvoted.remove(userId);
      testCopy = testCopy.setUpvotes(testCopy.upvotes - 1);
      testAuthorScores = testAuthorScores.setNetUpvotes(testAuthorScores.netUpvotes - 1);
    }

    void addUpvote(UserScores testAuthorScores) {
      testCopy.usersThatUpvoted.add(userId);
      testCopy = testCopy.setUpvotes(testCopy.upvotes + 1);
      testAuthorScores = testAuthorScores.setNetUpvotes(testAuthorScores.netUpvotes + 1);
    }

    void removeDownvote(UserScores testAuthorScores) {
      testCopy.usersThatDownvoted.remove(userId);
      testCopy = testCopy.setDownvotes(testCopy.downvotes - 1);
      testAuthorScores = testAuthorScores.setNetDownvotes(testAuthorScores.netDownvotes - 1);
    }

    void addDownvote(UserScores testAuthorScores) {
      testCopy.usersThatDownvoted.add(userId);
      testCopy = testCopy.setDownvotes(testCopy.downvotes + 1);
      testAuthorScores = testAuthorScores.setNetDownvotes(testAuthorScores.netDownvotes + 1);
    }

    if (up) {
      if (testCopy.usersThatUpvoted.contains(userId)) {
        removeUpvote(testAuthorScores);
      }
      else {
        if (testCopy.usersThatDownvoted.contains(userId)) {
          removeDownvote(testAuthorScores);
        }
        addUpvote(testAuthorScores);
      }
    } else {
      if (testCopy.usersThatDownvoted.contains(userId)) {
        removeDownvote(testAuthorScores);
      }
      else {
        if (testCopy.usersThatUpvoted.contains(userId)) {
          removeUpvote(testAuthorScores);
        }
        addDownvote(testAuthorScores);
      }
    }

    // 3) Save changes to the test and the test author's scores
    await testsCollection.doc(testId).set(testCopy.toJson());
    await usersScoresCollection.doc(testAuthorId).set(testAuthorScores.toJson());

    // 4) Return result
    return SaveTestResult(status: "${voteString}voted successfully!", updatedTest: testCopy);
  } on FirebaseException catch (error) {
    print("An error occured while voting: ${error.message ?? error.code}");
    return SaveTestResult(status: errorMessage, updatedTest: test);
  } catch (error) {
    print("An error occured while voting: $error");
    return SaveTestResult(status: errorMessage, updatedTest: test);
  }
}

/// Adds current user's `testResult` to the test document with `testId` as its key
/// in the `tests` Cloud Firestore collection.
/// Updates current user's `UserScores` document in accordance with `testResult`.
///
/// If the current user is not found,
/// or `testResult.userId` doesn't match the current user's ID,
/// or the test in Cloud Firestore with with `testId` as its key is not found,
/// or the test doesn't have a matching `id` attribute,
/// or the test is invalid,
/// or the current user already has their test result in the test,
/// or the test WITH `testResult` is invalid,
/// or anything else goes wrong,
/// this function doesn't modify the test in Cloud Firestore,
/// and returns the issue as the `status` field of the result,
/// and null as the `updatedTest` field of the result.
///
/// Normally, this function returns:
/// SaveTestResult(status: "SaveTestResult", updatedTest: <updatedTest>)
Future<SaveTestNullableResult> completeTestAsLoggedInUser(final String testId, TestResult testResult) async {
  // FIND CURRENT USER'S ID

  String? userId = auth.currentUser?.uid;

  if (userId == null) {
    return const SaveTestNullableResult(
      status: "You're not logged in, so your scores won't save!",
      updatedTest: null,
    );
  }

  // Test results somehow don't belong to the user
  if (testResult.userId != null && testResult.userId != userId) {
    return const SaveTestNullableResult(
      status: "Invalid test results...",
      updatedTest: null,
    );
  }

  // ADD CURRENT USER'S ID TO `testResult`

  testResult = testResult.setUserId(userId);

  // MODIFY TEST

  Test? testModel;

  try {
    testModel = await testWithId(testId);
  } catch (error) {
    return const SaveTestNullableResult(
      status: "Failed to find test to complete...",
      updatedTest: null,
    );
  }

  if (testModel == null) {
    return const SaveTestNullableResult(
      status: "Failed to find test to complete...",
      updatedTest: null,
    );
  }

  if (testModel.id != testId) {
    return const SaveTestNullableResult(
      status: "Downloaded test's ID doesn't match...",
      updatedTest: null,
    ); 
  }

  if (!(testModel.isValid())) {
    return const SaveTestNullableResult(
      status: "Test invalid!",
      updatedTest: null,
    );
  }

  // If the player has played their own test, don't save their test scores to it,
  // but don't display an intimidating error message, since they could be testing it.
  if (testModel.userId == userId) {
    return const SaveTestNullableResult(
      status: "Your test results didn't save to the test, since you created it.",
      updatedTest: null,
    );
  }

  // If the player has already played this test, `userId` should be present
  // in the test's `userResults` `Map` as a key,
  // and we should keep their original scores.
  //
  // Otherwise, we assume this is their first time playing the test,
  // and we add their scores to the test.
  //
  // FIREBASE SECURITY RULES SHOULD VERIFY THAT WE'RE NOT UPDATING OUR SCORES TWICE
  // (AND PERHAPS EVEN VERIFY THAT WE DON'T CANCEL OUR ORIGINAL SCORES
  // TO CHEAT FOR BETTER ONES?).
  // ASSUMES USER'S ID WON'T BE PRESENT IN THE `id` FIELD IN ONE OF `testModel.userResults.values`,
  // WHICH SHOULD HOPEFULLY BE PREVENTED BY FIREBASE SECURITY RULES.
  if (testModel.userResults.containsKey(userId)) {
    return const SaveTestNullableResult(
      status: "You already played this test, so your test results didn't save.",
      updatedTest: null,
    );
  }

  final Test testWithChanges;

  try {
    // This method call already checks for `testResult.userId` being null,
    // or having this same user already played it.
    // Since those issues were already checked by above return messages,
    // this must be another issue, and this will be its return message:
    testWithChanges = testModel.addTestResult(testResult);
  } catch (error) {
    print("Failed to add user's scores to test: $error");
    return const SaveTestNullableResult(
      status: "Failed to add user's scores to test...",
      updatedTest: null,
    );
  }

  if (!(testWithChanges.isValid())) {
    return const SaveTestNullableResult(
      status: "Invalid test results...",
      updatedTest: null,
    );
  }

  try {
    await testsCollection.doc(testId).set(testWithChanges.toJson());
  } catch (error) {
    return const SaveTestNullableResult(
      status: "Failed to upload user's scores...",
      updatedTest: null,
    );
  }

  // UPDATE CURRENT USER'S SCORES

  String userScoresUpdateStatus = await completeTestInMyUserScores(testResult);

  if (userScoresUpdateStatus != "Ok") {
    return SaveTestNullableResult(
      status: userScoresUpdateStatus,
      updatedTest: testWithChanges,
    );
  }

  return SaveTestNullableResult(status: "Saved scores successfully!", updatedTest: testWithChanges);
}

typedef TestQuery = Query<Map<String, dynamic>>;

/// Tries to execute the `query` and return its `docs` result as an List<Test?>.
///
/// Some tests in the result may be null, if their snapshots don't have
/// any data.
///
/// If an error happens while converting a `QueryDocumentSnapshot`
/// to a `Test`, null gets returned in its place.
Future<List<Test?>> queryTests(TestQuery query) async {
  QuerySnapshot<Map<String, dynamic>> querySnapshot = await query.get();

  return List<Test?>.from(
    querySnapshot.docs.map<Test?>(
      (QueryDocumentSnapshot<Map<String, dynamic>> queryDocumentSnapshot) {
        try {
          return Test.fromSnapshot(queryDocumentSnapshot);
        } catch (error) {
          print("Error constructing test from QueryDocumentSnapshot: $error");
          return null;
        }
      },
    ),
  );
}

/// Filters `query` to the first `limit` newest/oldest tests,
/// ordered according to `newest`
///
/// PLEASE READ THE DOCUMENTATION FOR `queryTests`!
TestQuery testsByDateCreated(TestQuery query, { required int limit, required bool newest }) {
  return query
    .orderBy('dateCreated', descending: newest)
    .limit(limit);
}

/// Filters `query` to the first `limit` tests
/// that have the MOST/LEAST NET UPVOTES, ordered by `most`.
///
/// NET UPVOTES ===== (upvotes - downvotes)
///
/// PLEASE READ THE DOCUMENTATION FOR `queryTests`!
TestQuery testsByNetUpvotes(TestQuery query, { required int limit, required bool most }) {
  return query
    .orderBy('usersThatUpvoted', descending: most)
    .orderBy('usersThatDownvoted', descending: !most)
    .limit(limit);
}

/// Filters `query` to the first `limit` tests
/// that have the MOST/LEAST UPVOTES, ordered by `most`.
///
/// PLEASE READ THE DOCUMENTATION FOR `queryTests`!
TestQuery testsByUpvotes(TestQuery query, { required int limit, required bool most }) {
  return query
    .orderBy('usersThatUpvoted', descending: most)
    .limit(limit);
}

/// Filters `query` to the first `limit` tests
/// that have the MOST/LEAST DOWNVOTES, ordered by `most`.
///
/// PLEASE READ THE DOCUMENTATION FOR `queryTests`!
TestQuery testsByDownvotes(TestQuery query, {required int limit, required bool most }) {
  return query
    .orderBy('usersThatDownvoted', descending: most)
    .limit(limit);
}

/// Returns a `Query` of all the tests made by the `userId`
/// in the `tests` Firestore collection,
///
/// (that have `userId: userId` in their documents).
///
/// PLEASE READ THE DOCUMENTATION FOR `queryTests`!
TestQuery testsByUser({ required String userId }) {
  return testsCollection
    .where('userId', isEqualTo: userId);
}

/// Filters `query` to all the tests with their `name` field equals the `name` parameter.
///
/// PLEASE READ THE DOCUMENTATION FOR `queryTests`!
TestQuery testsByName(TestQuery query, { required String name }) {
  return query.where('name', isEqualTo: name);
}
