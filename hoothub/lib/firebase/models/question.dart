class Question {
  Question({required this.question, required this.answers, required this.correctAnswer}) {
    if (answers.isEmpty) {
      throw "'answers' argument of 'Question' model can't be empty.";
    }
    if (correctAnswer < 0 || correctAnswer >= answers.length) {
      throw "'correctAnswer' argument of 'Question' model must be a valid index of the model's 'answers' argument.";
    }
  }

  final String question;
  final List<String> answers;
  final int correctAnswer;

  static Question fromJson(Map<String, dynamic> data) {
    return Question(
      question: data['question'],
      answers: data['answers'],
      correctAnswer: data['correctAnswer'],
    );
  }

  Map<String, dynamic> toJson() => {
    'question': question,
    'answers': answers,
    'correctAnswer': correctAnswer,
  };
}
