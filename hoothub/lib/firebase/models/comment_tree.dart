import 'model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  String? id;
  String? userId;
  String? testId;
  String? parentCommentId;
  String comment;
  List<String> usersThatUpvoted;
  List<String> usersThatDownvoted;
  List<String> replyIds;

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
