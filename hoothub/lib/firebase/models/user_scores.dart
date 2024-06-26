import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hoothub/firebase/models/test_result.dart';
import 'model.dart';

class AnswerRatio implements Model {
  const AnswerRatio({required this.questionsAnswered, required this.questionsAnsweredCorrect});

  final int questionsAnswered;
  final int questionsAnsweredCorrect;

  double get ratio => questionsAnswered / questionsAnsweredCorrect;

  /// Validates `questionsAnswered` and `questionsAnsweredCorrect` with each other.
  ///
  /// `questionsAnsweredCorrect` cannot be larger than `questionsAnswered`,
  /// and they must both be positive integers.
  @override
  bool isValid() => (
    questionsAnsweredCorrect >= 0
    && questionsAnswered >= 0
    && questionsAnsweredCorrect <= questionsAnswered
  );

  AnswerRatio update(int moreQuestionsAnswered, int moreQuestionsAnsweredCorrect) {
    return AnswerRatio(
      questionsAnswered: questionsAnswered + moreQuestionsAnswered,
      questionsAnsweredCorrect: questionsAnsweredCorrect + moreQuestionsAnsweredCorrect,
    );
  }

  static AnswerRatio fromJson(Map<String, dynamic> data) {
    return AnswerRatio(
      questionsAnswered: data['questionsAnswered'],
      questionsAnsweredCorrect: data['questionsAnsweredCorrect'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'questionsAnswered': questionsAnswered,
    'questionsAnsweredCorrect': questionsAnsweredCorrect,
  };
}

/// Independent document `Model` that represents a corresponding `UserModel`'s test score statistics.
class UserScores implements Model {
  UserScores({
    required this.userId,
    required this.netAnswerRatio,
    required this.bestScore,
    required this.bestAnswerRatio,
    required this.netUpvotes,
    required this.upvotes,
    required this.downvotes,
    required this.netComments,
    required this.hardestTest,
    required this.easiestTest,
  });

  final String? userId;
  final AnswerRatio netAnswerRatio;
  final int bestScore;
  final AnswerRatio bestAnswerRatio;
  final int netUpvotes;
  final int upvotes;
  final int downvotes;
  final int netComments;
  final String? hardestTest;
  final String? easiestTest;

  /// Validates `netAnswerRatio` and `bestAnswerRatio`.
  @override
  bool isValid() => netAnswerRatio.isValid() && bestAnswerRatio.isValid();

  /// Returns DEEP COPY of `this`.
  ///
  /// Immutable and deep fields are not copied.
  UserScores copy() => UserScores(
    userId: userId,
    netAnswerRatio: netAnswerRatio,
    bestScore: bestScore,
    bestAnswerRatio: bestAnswerRatio,
    netUpvotes: netUpvotes,
    upvotes: upvotes,
    downvotes: downvotes,
    netComments: netComments,
    hardestTest: hardestTest,
    easiestTest: easiestTest,
  );

  /// Returns copy of `this`, with consideration to the new questions the owner of `this`
  /// answered correctly vs the new questions the owner of `this` answered.
  UserScores update(TestResult testResult) {
    final AnswerRatio testResultAnswerRatio = AnswerRatio(
      questionsAnswered: testResult.questionsAnswered,
      questionsAnsweredCorrect: testResult.questionsAnsweredCorrect,
    );

    return UserScores(
      userId: userId,
      netAnswerRatio: netAnswerRatio.update(testResult.questionsAnswered, testResult.questionsAnsweredCorrect),
      bestScore: testResult.score > bestScore ? testResult.score : bestScore,
      bestAnswerRatio: testResultAnswerRatio.ratio > bestAnswerRatio.ratio ? testResultAnswerRatio : bestAnswerRatio,
      netUpvotes: netUpvotes,
      upvotes: upvotes,
      downvotes: downvotes,
      netComments: netComments,
      hardestTest: hardestTest,
      easiestTest: easiestTest,
    );
  }

  static UserScores? fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic>? data = snapshot.data();

    if (data == null) return null;

    return UserScores(
      userId: data['userId'],
      netAnswerRatio: AnswerRatio.fromJson(data['netAnswerRatio']),
      bestScore: data['bestScore'],
      bestAnswerRatio: AnswerRatio.fromJson(data['bestAnswerRatio']),
      netUpvotes: data['netUpvotes'],
      upvotes: data['upvotes'],
      downvotes: data['downvotes'],
      netComments: data['netComments'],
      hardestTest: data['hardestTest'],
      easiestTest: data['easiestTest'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'netAnswerRatio': netAnswerRatio.toJson(),
    'bestScore': bestScore,
    'bestAnswerRatio': bestAnswerRatio.toJson(),
    'netUpvotes': netUpvotes,
    'upvotes':upvotes,
    'downvotes': downvotes,
    'netComments': netComments,
    'hardestTest': hardestTest,
    'easiestTest': easiestTest,
  };
}
