import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hoothub/firebase/api/auth.dart';
// APIs
import 'clients.dart';
import 'tests.dart';
// models
import '../models/test.dart';
import '../models/comment_tree.dart';

/// Comments on a test in the `testsCollection`,
/// by uploading the `CommentTree` representation of `comment`
/// to the `commentsCollection`,
/// by adding the new comment's ID to the test document's `comments`
/// and by incrementing this comment's corresponding test's `commentCount`
/// field by one,
/// and by incrementing the test's author's score document's `netComments`
/// field by one.
///
/// If a `FirebaseException` occurs, this function returns its `message ?? code`.
/// If any other error occurs, this function returns its `toString()`.
///
/// THROWS: Shouldn't throw anything.
Future<String> commentOnTestWithId(String testId, String comment) async {
  if (auth.currentUser == null) return "You can't comment without being logged in! Please log in to comment.";

  // 1) Construct and validate `CommentTree` model
  DocumentReference<Map<String, dynamic>> commentReference = commentsCollection.doc();

  try {
    // I'm scared that `auth.currentUser!.uid` may fail, because `currentUser`
    // is a non-final public field, and couldn't be promoted
    // by the null-guard above. So, I put it in the try-catch.
    final CommentTree commentModel = CommentTree(
      id: commentReference.id,
      userId: auth.currentUser!.uid, // throws?
      testId: testId,
      parentCommentId: null,
      comment: comment,
      usersThatUpvoted: <String>[],
      usersThatDownvoted: <String>[],
      replyIds: <String>[],
    );

    if (!commentModel.isValid()) return "Comment invalid!";

    // 2) Include the comment in the test
    Test? testModel = await testWithId(testId); // throws, but caught
    if (testModel == null) return 'Test not found!';

    // NEW TEST MODEL, SO, SHOULDN'T AFFECT ANY OTHER INSTANCES,
    // BUT JUST TO BE SURE:
    testModel = testModel.copy();
    testModel.comments.add(commentReference.id);
    testModel = testModel.setCommentCount(testModel.commentCount + 1);

    // 3) Increment the test author's `comments` counter in their `UserScores` document.
    String? testAuthorId = testModel.userId;
    if (testAuthorId == null) return "Test's author not found!";

    String commentIncrementOnTestAuthorScoresStatus = await addCommentToUserScoresWithId(testAuthorId);

    if (commentIncrementOnTestAuthorScoresStatus != "Ok") {
      throw commentIncrementOnTestAuthorScoresStatus; // throws, but caught
    }

    // Save the changes to the test and save the comment
    await commentReference.set(commentModel.toJson()); // throws, but caught
    await saveTest(testModel); // throws, but caught
  } on FirebaseException catch (error) {
    return error.message ?? error.code;
  } catch (error) {
    return error.toString();
  }

  return 'Ok';
}

/// Tries to DELETE the comment document with `commentId` as its document ID key
/// in the `comments` collection.
///
/// Returns the status of the comment deletion.
///
/// THROWS: Shouldn't throw anything.
Future<String> deleteCommentWithId(String testId, String commentId) async {
  CommentTree? commentTree;

  try {
    commentTree = await commentWithId(commentId);
  } catch (error) {
    print("Failed to download comment to delete: $error");
    return "Failed to download comment to delete...";
  }

  if (commentTree == null) {
    return "Did not find comment to delete...";
  }

  try {
    commentTree = commentTree.setUserId(null).setComment("[DELETED]");

    await commentsCollection.doc(commentId).set(commentTree.toJson());

    return 'Comment deleted successfully!';
  } on FirebaseException catch (error) {
    print("An error occured while deleting comment $commentId: ${error.message ?? error.code}");
    return "An error occured while deleting comment!";
  } catch (error) {
    print("An error occured while deleting comment $commentId: ${error.toString()}");
    return "An error occured while deleting comment!";
  }
}

/// Tries to return the comment document, in the `comments` collection,
/// with `commentId` as its document ID key.
///
/// THROWS.
Future<CommentTree?> commentWithId(String commentId) async {
  return CommentTree.fromSnapshot(await commentsCollection.doc(commentId).get());
}

/// Tries to reply to a comment with `commentId` as its Firestore ID / `id` field.
///
/// Please review the schema to understand what this function does.
///
/// THROWS: Shouldn't throw anything.
Future<String> replyToCommentWithId(String parentCommentId, String comment) async {
  if (auth.currentUser == null) return "You can't comment without being logged in! Please log in to comment.";

  try {
    // Make sure the comment being replied to exists
    CommentTree? parentCommentModel = await commentWithId(parentCommentId);
    if (parentCommentModel == null) return 'Comment not found!';

    // Construct and validate `CommentTree` model
    DocumentReference<Map<String, dynamic>> commentReference = commentsCollection.doc();

    final CommentTree commentModel = CommentTree(
      id: commentReference.id,
      userId: auth.currentUser!.uid, // throws? `auth.currentUser` cannot be promoted.
      testId: parentCommentModel.testId,
      parentCommentId: parentCommentId,
      comment: comment,
      usersThatUpvoted: <String>[],
      usersThatDownvoted: <String>[],
      replyIds: <String>[],
    );

    if (!commentModel.isValid()) return 'Comment invalid!';

    // Add comment reply's ID to the parent comment's model
    parentCommentModel.replyIds.add(commentReference.id);

    // Save changes to the parent comment model and save the new reply.
    await commentsCollection.doc(parentCommentId).set(parentCommentModel.toJson());
    await commentReference.set(commentModel.toJson());
  } on FirebaseException catch (error) {
    return error.message ?? error.code;
  } catch (error) {
    return error.toString();
  }

  return 'Ok';
}
