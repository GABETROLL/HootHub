import 'package:hoothub/firebase/models/iterable_equals.dart';

import 'model.dart';

class QuestionResult implements Model {
  const QuestionResult({
    required this.answeredCorrectly,
    required this.answeringTime,
    required this.questionDuration,
  });

  final bool answeredCorrectly;
  final double answeringTime;
  final double questionDuration;

  /// Validates `answeringTime` with `questionDuration`.
  @override
  bool isValid() => (
    0 <= answeringTime && answeringTime <= questionDuration
  );

  bool equals(QuestionResult other) => (
    answeredCorrectly == other.answeredCorrectly
    && answeringTime == other.answeringTime
    && questionDuration == other.questionDuration
  );

  static QuestionResult fromJson(Map<String, dynamic> data) {
    return QuestionResult(
      answeredCorrectly: data['answeredCorrectly'],
      answeringTime: data['answeringTime'],
      questionDuration: data['questionDuration'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'answeredCorrectly': answeredCorrectly,
    'answeringTime': answeringTime,
    'questionDuration': questionDuration,
  };
}

/// Dependent `Model` for `Test` to use.
/// Represents a user's answers score for its corresponding `Test`.
class TestResult implements Model {
  const TestResult({
    required this.userId,
    required this.questionResults,
    required this.score,
  });

  final String? userId;
  final List<QuestionResult> questionResults;
  final int score;

  /// Wrapper for `questionResults.length`
  int get questionsAnswered => questionResults.length;

  /// WARNING: MAY NOT RETURN CORRECT RESULTS.
  int get questionsAnsweredCorrect => questionResults.fold<int>(
    0, (int count, QuestionResult questionResult) => count + (
      questionResult.answeredCorrectly
      ? 1
      : 0
    ),
  );

  /// Validates each `QuestionResult` in `questionResults`,
  /// then validates `score` using `questionResults`.
  @override
  bool isValid() {
    int correctScore = 0;

    for (QuestionResult questionResult in questionResults) {
      if (!(questionResult.isValid())) return false;

      if (questionResult.answeredCorrectly) {
        final double remainingAnsweringTime = questionResult.questionDuration - questionResult.answeringTime;

        correctScore += (1000 * (remainingAnsweringTime / questionResult.questionDuration)).toInt();
      }
    }

    return score == correctScore;
  }

  bool equals(TestResult other) => (
    userId == other.userId
    && iterableEquals<QuestionResult>(
      questionResults,
      other.questionResults,
      (QuestionResult a, QuestionResult b) => a.equals(b),
    )
    && score == other.score
  );

  /// Sets `this.userId: userId`
  TestResult setUserId(String? newUserId) {
    return TestResult(
      userId: newUserId,
      questionResults: questionResults,
      score: score
    );
  }

  /// THROWS
  static TestResult fromJson(Map<String, dynamic> data) {
    final dynamic questionResultsData = data['questionResults'];
    final List<Map<String, dynamic>> typecastQuestionResultsData;

    try {
      // `questionResultsData` should be a `List<Map<String, dynamic>>`, where each `Map<String, dynamic>`
      // represents a `QuestionResult` object, in its "JSON" form.
      //
      // Firestore actually returns the data as a `List<dynamic>`, NOT a `List<T>`,
      // even if all of its items are of type `T`.
      //
      // `data['questionResults']` MUST be a `List`. If it's not a `List`, we can already know
      // that it's invalid, and we can throw the below error.
      //
      // First, I attempt to treat `data['questionResults']` as `List<dynamic>`,
      // and if it is, no error is thrown,
      // and I then cast it to `List<Map<String, dynamic>>`.
      // If that's not possible either, then this error is thrown again:
      typecastQuestionResultsData = (
        questionResultsData as List<dynamic>
      ).cast<Map<String, dynamic>>();
    } catch (error) {
      throw "`questionResults` field of data is not valid! Got: $questionResultsData";
    }

    List<QuestionResult> questionResults = List<QuestionResult>.of(
      typecastQuestionResultsData.map<QuestionResult>(
        (Map<String, dynamic> questionResult) => QuestionResult.fromJson(questionResult),
      ),
    );

    return TestResult(
      userId: data['userId'],
      questionResults: questionResults,
      score: data['score'],
    );
  }

  /// Returns a new `TestResult` instance,
  /// with this question's result info
  /// at the end of `questionResults`,
  /// and with the new score for the player in the `score` field,
  /// which is based on how they answered the current question:
  ///
  /// If the player answered the current question correctly,
  /// `score` will have `1000 * (remainingAnsweringTime / questionDuration)`
  /// more points.
  ///
  /// ***THE `questionResults` LIST IS COPIED, AND `this` IS COPIED TOO!
  /// Immutable fields/deep fields are not copied.***
  TestResult updateScore(bool answeredCorrectly, double answeringTime, double questionDuration) {
    final double remainingAnsweringTime = questionDuration - answeringTime;

    return TestResult(
      userId: userId,
      questionResults: List<QuestionResult>.of(
        questionResults.followedBy([
          QuestionResult(
            answeredCorrectly: answeredCorrectly,
            answeringTime: answeringTime,
            questionDuration: questionDuration,
          ),
        ]),
      ),
      score: score + (
        answeredCorrectly
        ? (1000 * (remainingAnsweringTime / questionDuration)).toInt()
        : 0
      )
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'questionResults': List<Map<String, dynamic>>.of(
      questionResults.map<Map<String, dynamic>>(
        (QuestionResult questionResult) => questionResult.toJson(),
      ),
    ),
    'score': score,
  };
}
