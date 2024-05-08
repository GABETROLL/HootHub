import 'model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentTree implements Model {
  CommentTree({
    this.id,
    this.userId,
    this.testId,
    required this.comment,
    required this.usersThatUpvoted,
    required this.usersThatDownvoted,
    required this.replyIds,
  });

  String? id;
  String? userId;
  String? testId;
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
      comment: data['comment'],
      usersThatUpvoted: data['usersThatUpvoted'],
      usersThatDownvoted: data['usersThatDownvoted'],
      replyIds: data['replyIds'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'comment': comment,
    'usersThatUpvoted': usersThatUpvoted,
    'usersThatDownvoted': usersThatDownvoted,
    'replyIds': replyIds,
  };
}
