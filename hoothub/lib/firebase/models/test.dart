import 'model.dart';
import 'question.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Test implements Model {
  const Test({required this.name, this.questions = const <Question>[]});

  final String name;
  final List<Question> questions;

  /// A `Test` is valid if its `name` and `questions` aren't empty,
  /// and if all of its questions are valid.
  @override
  bool isValid() {
    bool questionsValid = true;

    for (Question question in questions) {
      questionsValid &= question.isValid();
    }

    return name.isNotEmpty && questions.isNotEmpty && questionsValid;
  }

  /// Returns copy of `this` with `name: name`.
  Test setName(String name) =>
    Test(name: name, questions: questions);

  /// Returns copy of `this` with a new, empty question at the end of `questions`.
  ///
  /// The new, empty question should have an empty title, answers,
  /// and should have answer 0 as the correct answer.
  Test addNewEmptyQuestion() {
    List<Question> newQuestions = List.from(questions);
    Question newQuestion = const Question(question: '', answers: <String>[], correctAnswer: 0);
    newQuestions.add(newQuestion);

    return Test(name: name, questions: newQuestions);
  }

  /// Returns copy of `this`, that has the `index`-th question equal to `question`.
  ///
  /// Throws an error if `index` is out of range of `questions`. 
  Test setQuestion(int index, Question question) {
    List<Question> newQuestions = questions;

    if (index < 0 || index >= questions.length) {
      throw "Can't set question at index: $index, that index is out of range.";
    }

    newQuestions[index] = question;

    return Test(name: name, questions: newQuestions);
  }

  /// Returns the `Test` representation of `snapshot.data()`.
  /// If the data is null, this method returns null.
  /// If any of the fields are wrong, the constructor call inside this method
  /// takes care of those errors, and throws them up the stack.
  static Test? fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic>? data = snapshot.data();

    if (data == null) return null;

    // TODO: Will this work?
    if (data['questions'] is! List<Map<String, dynamic>>) {
      throw "`questions` field of snapshot data is not the correct type!";
    }

    List<Question> questions = List.from(
      data['questions'].map(
        (Map<String, dynamic> question) => Question.fromJson(question),
      ),
    );

    return Test(
      name: data['name'],
      questions: questions,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'name': name,
    'questions': List.from(
      questions.map<Map<String, dynamic>>((Question question) => question.toJson())
    ) ,
  };
}
