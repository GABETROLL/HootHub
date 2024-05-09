import 'package:cloud_firestore/cloud_firestore.dart';
// APIs
import 'clients.dart';
import 'tests.dart';
// models
import '../models/test.dart';
import '../models/comment_tree.dart';

/// Comments on a test in the `tests` Firestore collection,
/// by uploading a new `CommentTree` document to the `comments` collection,
/// and by adding the new comment's ID to the test document's `comments`.
///
/// THROWS: Shouldn't throw anything.
Future<String> commentOnTestWithId(String testId, String comment) async {
  if (auth.currentUser == null) return "You can't comment without being logged in! Please log in to comment.";

  // Construct and validate `CommentTree` model
  DocumentReference<Map<String, dynamic>> commentReference = commentsCollection
    .doc();

  final CommentTree commentModel = CommentTree(
    id: commentReference.id,
    userId: auth.currentUser!.uid,
    testId: testId,
    parentCommentId: null,
    comment: comment,
    usersThatUpvoted: <String>[],
    usersThatDownvoted: <String>[],
    replyIds: <String>[],
  );

  if (!commentModel.isValid()) return "Comment invalid!";

  try {
    // Include the comment in the test
    Test? testModel = await testWithId(testId);
    if (testModel == null) return 'Test not found!';
    testModel.comments.add(commentReference.id);

    // Save the changes to the test and save the comment
    await commentReference.set(commentModel.toJson());
    await saveTest(testModel);
  } on FirebaseException catch (error) {
    return error.message ?? error.code;
  } catch (error) {
    return error.toString();
  }

  return 'Ok';
}

/// Tries to DELETE the comment document, in the `comments` collection,
/// with `commentId` as its document ID key.
///
/// (IT **SHOULD** ALSO HAVE `commentId` AS ITS `id` FIELD)
///
/// Returns 'Ok' if everything seems to have gone well,
/// `error.message ?? error.code` if a FirebaseException occured,
/// or `error.toString()` if any other error occured.
///
/// THROWS: Shouldn't throw anything.
Future<String> deleteCommentWithId(String commentId) async {
  try {
    await commentsCollection.doc(commentId).delete();
    return 'Ok';
  } on FirebaseException catch (error) {
    return error.message ?? error.code;
  } catch (error) {
    return error.toString();
  }
}

/// Tries to return the comment document, in the `comments` collection,
/// with `commentId` as its document ID key.
///
/// THROWS: Shouldn't throw anything. 
Future<CommentTree?> commentWithId(String commentId) async {
  try {
    DocumentSnapshot<Map<String, dynamic>> commentSnapshot = await commentsCollection.doc(commentId).get();
    return CommentTree.fromSnapshot(commentSnapshot);
  } catch (error) {
    return null;
  }
}

/// Tries to reply to a comment with `commentId` as its Firestore ID / `id` field.
///
/// Tries to:
/// - download the comment being replied to from the `comments` collection,
/// - generate a new reference with an auto-generated ID for the new comment being made,
/// - create the new `CommentTree` model for the comment,
///   using `comment`, the user's ID, and the parent comment's `testID`
///   (It will have all of its lists initialized empty),
/// - add the new comment's ID to the parent comment model's `replyIds` list,
/// - re-upload the edited `CommentTree` model for the parent comment,
///   to add the reply to its document in the Firestore,
/// - upload the new comment in the `comments` collection.
///
/// RETURN VALUE
/// - Should return 'Ok' if everything seems to go OK.
/// - If the user is not logged in, this function returns 
///   "You can't comment without being logged in! Please log in to comment.".
/// - If the parent comment (the comment being replied to) is not found,
///   this function returns: 'Comment not found!'.
/// - If the `CommentTree` model constructed for this new comment is not valid,
///   this function returns: 'Comment invalid!'.
/// - If a `FirebaseException` occurs, this function tries to return the error's
///   `message`. If the message is null, this function returns the error's `code`.
/// - If anything else goes wrong, this function returns the error's `toString()`.
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
      userId: auth.currentUser!.uid,
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
