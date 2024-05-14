import 'model.dart';

/// Dependent `Model` for `Test` to use.
/// Represents a user's answers score for its corresponding `Test`.
class TestResult implements Model {
  TestResult({
    this.userId,
    required this.correctAnswers,
    required this.score,
  });

  String? userId;
  int correctAnswers;
  double score;

  @override
  bool isValid() => true;

  static TestResult fromJson(Map<String, dynamic> data) {
    return TestResult(
      userId: data['userId'],
      correctAnswers: data['correctAnswers'],
      score: data['score'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'correctAnswers': correctAnswers,
    'score': score,
  };
}
