import 'iterable_equals.dart';
import 'model.dart';

/// Dependent `Model` for `Test` to use.
/// Represents a question in its corresponding `Test`.
class Question implements Model {
  Question({
    required this.question,
    required this.answers,
    required this.correctAnswer,
    this.secondsDuration = 20,
  });

  final String question;
  final List<String> answers;
  final int correctAnswer;
  final int secondsDuration;

  /// A `Question` is valid if:
  /// - Its `question` is not empty
  /// - It has more than one answer
  /// - The `correctAnswer` is a valid index for `answers`
  /// - `secondsDuration` is in the range of 1 to 60
  @override
  bool isValid() => (
    question.isNotEmpty
    && answers.length > 1
    && 0 <= correctAnswer && correctAnswer < answers.length
    && 1 <= secondsDuration && secondsDuration <= 60
  );

  bool equals(Question other) => (
    question == other.question
    && iterableEquals(answers, other.answers, (String a, String b) => a == b)
    && correctAnswer == other.correctAnswer
    && secondsDuration == other.secondsDuration
  );

  /// Returns a DEEP copy of `this`.
  ///
  /// Immutable fields are not copied.
  Question copy() => Question(
    question: question,
    answers: List<String>.of(answers),
    correctAnswer: correctAnswer,
  );

  static Question fromJson(Map<String, dynamic> data) {
    return Question(
      question: data['question'],
      answers: (data['answers'] as List<dynamic>).cast<String>(),
      correctAnswer: data['correctAnswer'],
      secondsDuration: data['secondsDuration'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'question': question,
    'answers': answers,
    'correctAnswer': correctAnswer,
    'secondsDuration': secondsDuration,
  };
}
