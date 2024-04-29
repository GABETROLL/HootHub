import 'model.dart';

class Question implements Model {
  Question({required this.question, required this.answers, required this.correctAnswer});

  String question;
  List<String> answers;
  int correctAnswer;

  @override
  bool isValid() => answers.length > 1 && 0 <= correctAnswer && correctAnswer < answers.length;

  /// Sets `this.question: question`.
  void setQuestion(String question) {
    this.question = question;
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
