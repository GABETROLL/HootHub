import 'model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Independent `Model` representing a user's comment.
class CommentTree implements Model {
  CommentTree({
    required this.id,
    required this.userId,
    required this.testId,
    required this.parentCommentId,
    required this.comment,
    required this.usersThatUpvoted,
    required this.usersThatDownvoted,
    required this.replyIds,
  });

  final String? id;
  final String? userId;
  final String? testId;
  final String? parentCommentId;
  final String comment;
  final List<String> usersThatUpvoted;
  final List<String> usersThatDownvoted;
  final List<String> replyIds;

  /// A `CommentTree` is a valid Firestore document
  /// if it has a non-empty comment.
  ///
  /// `id`, `userId` and `testId` are not considered for this validation, because
  /// the APIs will validate them, OR GENERATE THEM AUTOMATICALLY,
  /// IF THIS MODEL IS BEING UPLOADDED.
  ///
  /// `usersThatUpvoted` `usersThatDownvoted` `replyIds`
  /// are not validated, because the constructor will take care of them,
  /// and because a comment having no upvotes, downvotes or replies
  /// should be possible.
  @override
  bool isValid() {
    return comment.isNotEmpty;
  }

  /// Returns a DEEP copy of `this`.
  ///
  /// Immutable fields are not copied.
  CommentTree copy() => CommentTree(
    id: id,
    userId: userId,
    testId: testId,
    parentCommentId: parentCommentId,
    comment: comment,
    usersThatUpvoted: List.of(usersThatUpvoted),
    usersThatDownvoted: List.of(usersThatDownvoted),
    replyIds: List.of(replyIds),
  );

  static CommentTree? fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final Map<String, dynamic>? data = snapshot.data();

    if (data == null) return null;

    return CommentTree(
      id: data['id'],
      userId: data['userId'],
      testId: data['testId'],
      parentCommentId: data['parentCommentId'],
      comment: data['comment'],
      usersThatUpvoted: (data['usersThatUpvoted'] as List<dynamic>).cast<String>(),
      usersThatDownvoted: (data['usersThatDownvoted'] as List<dynamic>).cast<String>(),
      replyIds: (data['replyIds'] as List<dynamic>).cast<String>(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'testId': testId,
    'parentCommentId': parentCommentId,
    'comment': comment,
    'usersThatUpvoted': usersThatUpvoted,
    'usersThatDownvoted': usersThatDownvoted,
    'replyIds': replyIds,
  };
}
