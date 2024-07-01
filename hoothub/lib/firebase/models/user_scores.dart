import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hoothub/firebase/models/model.dart';

/// Independent document `Model` that represents a corresponding `UserModel`'s test score statistics.
class UserScores implements Model {
  UserScores({
    required this.userId,
    required this.questionsAnswered,
    required this.questionsAnsweredCorrect,
  });

  final String? userId;
  final int questionsAnswered;
  final int questionsAnsweredCorrect;

  @override
  bool isValid() => questionsAnsweredCorrect >= 0
    && questionsAnswered >= 0
    && questionsAnsweredCorrect <= questionsAnswered
  ;

  /// Returns DEEP COPY of `this`.
  ///
  /// Immutable and deep fields are not copied.
  UserScores copy() => UserScores(
    userId: userId,
    questionsAnswered: questionsAnswered,
    questionsAnsweredCorrect: questionsAnsweredCorrect,
  );

  /// Returns copy of `this`, with consideration to the new questions the owner of `this`
  /// answered correctly vs the new questions the owner of `this` answered.
  UserScores update(int moreQuestionsAnswered, int moreQuestionsAnsweredCorrect) {
    return UserScores(
      userId: userId,
      questionsAnswered: questionsAnswered + moreQuestionsAnswered,
      questionsAnsweredCorrect: questionsAnsweredCorrect + moreQuestionsAnsweredCorrect,
    );
  }

  static UserScores? fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic>? data = snapshot.data();

    if (data == null) return null;

    return UserScores(
      userId: data['userId'],
      questionsAnswered: data['questionsAnswered'],
      questionsAnsweredCorrect: data['questionsAnsweredCorrect'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'questionsAnswered': questionsAnswered,
    'questionsAnsweredCorrect': questionsAnsweredCorrect,
  };
}
