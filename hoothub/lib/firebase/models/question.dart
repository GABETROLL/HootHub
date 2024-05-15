import 'model.dart';

/// Dependent `Model` for `Test` to use.
/// Represents a question in its corresponding `Test`.
class Question implements Model {
  Question({
    required this.question,
    this.imageUrl,
    required this.answers,
    required this.correctAnswer,
    this.secondsDuration = 20,
  });

  String question;
  String? imageUrl;
  List<String> answers;
  int correctAnswer;
  int secondsDuration;

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

  /// Sets `this.question: question`.
  void setQuestion(String question) {
    this.question = question;
  }

  /// Sets `imageUrl: imageUrl`.
  void setImage(String imageUrl) {
    this.imageUrl = imageUrl;
  }

  /// Throws error if `index` is out of the range of `answers`.
  void _checkAnswerIndex(int index) {
    if (index < 0 || index >= answers.length) {
      throw "Answer index out of range: $index";
    }
  }

  /// Sets `answers`'s `index`-th answer equal to `answer`.
  ///
  /// Throws an error if the index is outside the range of `answers`.
  void setAnswer(int index, String answer) {
    _checkAnswerIndex(index);
    answers[index] = answer;
  }

  /// Sets `correctAnswer: index`.
  ///
  /// Throws an error if the index is outside the range of `answers`.
  void setCorrectAnswer(int index) {
    _checkAnswerIndex(index);
    correctAnswer = index;
  }

  /// Adds a new, empty answer to the end of `answers`.
  void addNewEmptyAnswer() {
    answers.add('');
  }

  /// Sets `this.secondsDuration: secondsDuration`.
  void setSecondsDuration(int secondsDuration) {
    this.secondsDuration = secondsDuration;
  }

  static Question fromJson(Map<String, dynamic> data) {
    return Question(
      question: data['question'],
      imageUrl: data['imageUrl'],
      answers: (data['answers'] as List<dynamic>).cast<String>(),
      correctAnswer: data['correctAnswer'],
      secondsDuration: data['secondsDuration'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'question': question,
    'imageUrl': imageUrl,
    'answers': answers,
    'correctAnswer': correctAnswer,
    'secondsDuration': secondsDuration,
  };
}
