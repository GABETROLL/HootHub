import 'model.dart';
import 'question.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for test.
///
/// BOTH IDS ARE OPTIONAL, SINCE THEY WILL BE CREATED BY FIREBASE.
/// PROVIDING THEM INDICATES TO `saveTest` TO USE THESE INSTEAD
/// OF GENERATING NEW ONES, SO THEY NEED TO BE CORRECT.
/// NOT PROVIDING THEM INDICATES TO `saveTest` TO GENERATE THEM
/// AUTOMATICALLY WHEN SAVING THEM, VIA THE CURRENT USER'S UID
/// AND BY GENERATING A NEW UNIQUE KEY FOR THE TEST IN THE FIRESTORE.
///
/// `id` is the ID of the test,
/// the unique key for the test in the `tests` Firestore collection.
/// `userId` is the ID of the user that created it,
/// the unique key for the user in the `users` Firestore collection.
///
/// `name` is the "title" of the test
/// `questions` is a List<Question>.
class Test implements Model {
  Test({
    this.id,
    this.userId,
    this.name = '',
    this.imageUrl,
    this.questions = const <Question>[],
    this.usersThatUpvoted = const <String>[],
    this.usersThatDownvoted = const <String>[],
  });

  String? id;
  String? userId;
  String name;
  String? imageUrl;
  List<Question> questions;
  List<String> usersThatUpvoted;
  List<String> usersThatDownvoted;

  /// Validates `this` before it can be put in `FirebaseFirestore`.
  ///
  /// A `Test` is valid if its `name` and `questions` aren't empty,
  /// and if all of its questions are valid.
  ///
  /// `id` and `userId` and `imageUrl` ARE NOT NEEDED TO VALIDATE A TEST,
  /// because the ID's will be created by `saveTest`,
  /// and because tests may not always have an image.
  @override
  bool isValid() {
    bool questionsValid = true;

    for (Question question in questions) {
      questionsValid &= question.isValid();
    }

    return name.isNotEmpty && questions.isNotEmpty && questionsValid;
  }

  /// Sets `this.name: name`.
  void setName(String name) {
    this.name = name;
  }

  /// Adds a new, empty question at the end of `answers`
  ///
  /// The new, empty question should have an empty title, answers,
  /// should have answer 0 as the correct answer,
  /// and should last its constructor's default time, of 20 seconds.
  void addNewEmptyQuestion() {
    questions.add(Question(question: '', answers: <String>['', ''], correctAnswer: 0));
  }

  /// Throws error if `index` is out of the range of `questions`.
  void _checkQuestionIndex(int index) {
    if (index < 0 || index >= questions.length) {
      throw "Question index out of range: $index";
    }
  }

  /// Sets `question: question` to the `questionIndex`-th question.
  void setQuestion(int questionIndex, String question) {
    _checkQuestionIndex(questionIndex);
    questions[questionIndex].setQuestion(question);
  }

  /// Assigns `answer` to the `answerIndex`-th answer of the `questionIndex`-th question.
  /// 
  /// Throws if either the `questionIndex` is out of range of `questions`,
  /// or if `answerIndex` is out of range of `questions[questionIndex].answers`. 
  void setAnswer(int questionIndex, int answerIndex, String answer) {
    _checkQuestionIndex(questionIndex);
    questions[questionIndex].setAnswer(answerIndex, answer);
  }

  /// Assigns `correctAnswer: answerIndex` to the `questionIndex`-th question.
  ///
  /// Throws if either the `questionIndex` is out of range of `questions`,
  /// or if `answerIndex` is out of range of `questions[questionIndex].answers`.
  void setCorrectAnswer(int questionIndex, int answerIndex) {
    _checkQuestionIndex(questionIndex);
    questions[questionIndex].setCorrectAnswer(answerIndex);
  }

  /// Adds a new, empty answer to the end of the `answers` of the `questionIndex`-th question.
  ///
  /// Throws if the `questionIndex` is out of range of `questions`.
  void addNewEmptyAnswer(int questionIndex) {
    _checkQuestionIndex(questionIndex);
    questions[questionIndex].addNewEmptyAnswer();
  }

  /// Sets the time duration, in seconds, of the `questionIndex`-th question.
  ///
  /// Throws if the `questionIndex` is out of range of `questions`.
  void setSecondsDuration(int questionIndex, int secondsDuration) {
    _checkQuestionIndex(questionIndex);
    questions[questionIndex].setSecondsDuration(secondsDuration);
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
      id: data['id'],
      userId: data['userId'],
      name: data['name'],
      imageUrl: data['imageUrl'],
      questions: questions,
      usersThatUpvoted: data['usersThatUpvoted'],
      usersThatDownvoted: data['usersThatDownvoted'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'name': name,
    'imageUrl': imageUrl,
    'questions': List.from(
      questions.map<Map<String, dynamic>>((Question question) => question.toJson()),
    ),
    'usersThatUpvoted': usersThatUpvoted,
    'usersThatDownvoted': usersThatDownvoted,
  };
}
