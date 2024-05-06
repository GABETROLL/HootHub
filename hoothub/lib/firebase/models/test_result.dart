import 'model.dart';

class TestResult implements Model {
  TestResult({
    required this.correctAnswers,
    required this.score,
  });

  int correctAnswers;
  double score;

  @override
  bool isValid() => true;

  static TestResult fromJson(Map<String, dynamic> data) {
    return TestResult(
      correctAnswers: data['correctAnswers'],
      score: data['score'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'correctAnswers': correctAnswers,
    'score': score,
  };
}
