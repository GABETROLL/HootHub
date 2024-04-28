import 'model.dart';

class Question implements Model {
  const Question({required this.question, required this.answers, required this.correctAnswer});

  final String question;
  final List<String> answers;
  final int correctAnswer;

  @override
  bool isValid() => answers.length > 1 && 0 <= correctAnswer && correctAnswer < answers.length;

  /// Throws error if `index` is out of the range of `answers`.
  void _checkIndex(int index) {
    if (index < 0 || index >= answers.length) {
      throw "Correct answer index: $index out of range";
    }
  }

  /// Returns a copy of `this`
  /// that now has its `index`-th answer equal to `answer`.
  ///
  /// Throws an error if the index is outside the range of `answers`.
  Question setAnswer(int index, String answer) {
    _checkIndex(index);

    List<String> newAnswers = answers;
    newAnswers[index] = answer;

    return Question(question: question, answers: newAnswers, correctAnswer: correctAnswer);
  }

  /// Returns a copy of `this`
  /// that now has `correctAnswer: index`.
  ///
  /// Throws an error if the index is outside the range of `answers`.
  Question setCorrectAnswer(int index) {
    _checkIndex(index);

    return Question(question: question, answers: answers, correctAnswer: index);
  }

  /// Adds `answer` to the end of `answers`.
  void addAnswer(String answer) {
    answers.add(answer);
  }

  static Question fromJson(Map<String, dynamic> data) {
    return Question(
      question: data['question'],
      answers: data['answers'],
      correctAnswer: data['correctAnswer'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'question': question,
    'answers': answers,
    'correctAnswer': correctAnswer,
  };
}
