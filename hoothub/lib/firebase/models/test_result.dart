import 'model.dart';

/// Dependent `Model` for `Test` to use.
/// Represents a user's answers score for its corresponding `Test`.
class TestResult implements Model {
  const TestResult({
    this.userId,
    required this.correctAnswers,
    required this.score,
  });

  final String? userId;
  final int correctAnswers;
  final int score;

  @override
  bool isValid() => true;

  static TestResult fromJson(Map<String, dynamic> data) {
    return TestResult(
      userId: data['userId'],
      correctAnswers: data['correctAnswers'],
      score: data['score'],
    );
  }

  /// Returns a DEEP copy of `this`.
  ///
  /// Immutable fields are not copied.
  TestResult copy() => TestResult(userId: userId, correctAnswers: correctAnswers, score: score);

  /// Returns a new `TestResult` instance, with the new score for the player,
  /// based on how they answered the current question.
  ///
  /// If the player answered the current question correctly,
  /// in the result, `correctAnswers` will be incremented by 1,
  /// and `score` will have `1000 * (answeringTime / questionDuration)`
  /// more points.
  TestResult updateScore(bool answeredCorrectly, double answeringTime, double questionDuration) {
    int questionScore = 0;

    if (answeredCorrectly) {
      // WRONG.
      questionScore = (1000 * (answeringTime / questionDuration)).toInt();
    }

    return TestResult(
      correctAnswers: answeredCorrectly ? correctAnswers + 1 : correctAnswers,
      score: score + questionScore,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'correctAnswers': correctAnswers,
    'score': score,
  };
}
