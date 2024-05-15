import 'model.dart';
import 'question.dart';
import 'test_result.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Independent `Model` for test.
///
/// `id`, `userId` and `dateCreated` are optional.
/// If they are not provided, `saveTest` will generate them for
/// the test document. If they are, please make sure they are correct.
///
/// `id` is the ID of the test,
/// the unique key for the test in the `tests` Firestore collection.
/// `userId` is the ID of the user that created it,
/// the unique key for the user in the `users` Firestore collection.
///
/// `name` is the "title" of the test.
/// `dateCreated` is a `Timestamp` of the exact micro(?)second this test
///   was uploaded to Firebase.
/// `imageUrl` is the FirebaseStorage download URL for this tests' thumbnail.
/// `questions` is a List<Question>: the questions of the test.
/// `userResults` is a map of each userId
///   and their test results, as a `TestResult` object.
///   (I'M NOT YET SURE IF THIS DATA SHOULD BE SEPARATE)
/// `usersThatUpvoted`/`usersThatDownvoted` are lists of IDs
///   of the users that upvoted/downvoted this test.
/// `comments` are a list of IDs of the `Comment` documents for this test.
class Test implements Model {
  Test({
    this.id,
    this.userId,
    String? name,
    this.dateCreated,
    this.imageUrl,
    List<Question>? questions,
    Map<String, TestResult>? userResults,
    List<String>? usersThatUpvoted,
    List<String>? usersThatDownvoted,
    List<String>? comments,
  }) {
    if (name != null) {
      this.name = name;
    }
    if (questions != null) {
      this.questions = questions;
    }
    if (userResults != null) {
      this.userResults = userResults;
    }
    if (usersThatUpvoted != null) {
      this.usersThatUpvoted = usersThatUpvoted;
    }
    if (usersThatDownvoted != null) {
      this.usersThatDownvoted = usersThatDownvoted;
    }
    if (comments != null) {
      this.comments = comments;
    }
  }

  String? id;
  String? userId;
  String name = '';
  Timestamp? dateCreated;
  String? imageUrl;
  List<Question> questions = <Question>[];
  Map<String, TestResult> userResults = <String, TestResult>{};
  List<String> usersThatUpvoted = <String>[];
  List<String> usersThatDownvoted = <String>[];
  List<String> comments = <String>[];

  /// Validates `this` before it can be put in `FirebaseFirestore`.
  ///
  /// A `Test` is valid if its `name` and `questions` aren't empty,
  /// if all of its questions are valid,
  /// and if all of the `userResults.values` are valid, according to this test.
  ///
  /// `id`, `userId`, `dateCreated` and `imageUrl` ARE NOT NEEDED TO VALIDATE A TEST,
  /// because the first 3 fields (HOPEFULLY WERE) created automatically by `saveTest`,
  /// and because tests may not always have an image.
  @override
  bool isValid() {
    for (Question question in questions) {
      if (!(question.isValid())) return false;
    }

    for (TestResult testResult in userResults.values) {
      if (!(0 <= testResult.correctAnswers && testResult.correctAnswers < questions.length)) {
        return false;
      }
      // TODO: VERIFY `testResult` BASED ON THE SCORING FORMULA!
    }

    return name.isNotEmpty && questions.isNotEmpty;
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

  /// Sets `imageUrl: questionImageUrl` to the `questionIndex`-th question.
  void setQuestionImage(int questionIndex, String questionImageUrl) {
    _checkQuestionIndex(questionIndex);
    questions[questionIndex].setImage(questionImageUrl);
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

  Test copy() => Test(
    id: id,
    userId: userId,
    name: name,
    dateCreated: dateCreated,
    imageUrl: imageUrl,
    questions: questions,
    userResults: userResults,
    usersThatUpvoted: usersThatUpvoted,
    usersThatDownvoted: usersThatDownvoted,
  );

  /// Returns the `Test` representation of `snapshot.data()`.
  ///
  /// If the data is null, this method returns null.
  ///
  /// Throws if the data is invalid.
  static Test? fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic>? data = snapshot.data();

    if (data == null) return null;

    final dynamic questionsData = data['questions'];
    final List<Map<String, dynamic>> typecastQuestionsData;

    try {
      // `questionsData` should be a `List<Map<String, dynamic>>`, where each `Map<String, dynamic>`
      // represents a `Question` object, in its "JSON" form.
      //
      // Firestore actually returns the data as a `List<dynamic>`, NOT a `List<T>`,
      // even if all of its items are of type `T`.
      //
      // `data['questions']` MUST be a `List`. If it's not a `List`, we can already know
      // that it's invalid, and we can throw the below error.
      //
      // First, I attempt to treat `data['questions']` as `List<dynamic>`,
      // and if it is, no error is thrown,
      // and I then cast it to `List<Map<String, dynamic>>`.
      // If that's not possible either, then this error is thrown again:
      typecastQuestionsData = (
        questionsData as List<dynamic>
      ).cast<Map<String, dynamic>>();
    } catch (error) {
      throw "`questions` field of snapshot data is not valid! Got: $questionsData";
    }

    List<Question> questions = List<Question>.from(
      typecastQuestionsData.map<Question>(
        (Map<String, dynamic> question) => Question.fromJson(question),
      ),
    );

    final dynamic userResultsData = data['userResults'];
    Map<String, Map<String, dynamic>> typecastUserResultsData;

    try {
      typecastUserResultsData = (
        userResultsData as Map
      ).cast<String, Map<String, dynamic>>();
    } catch (error) {
      throw "`userResults` field of snapshot data is not valid! Got: $userResultsData";
    }

    Map<String, TestResult> userResults = Map<String, TestResult>.fromEntries(
      typecastUserResultsData.entries.map<MapEntry<String, TestResult>>(
        (MapEntry<String, Map<String, dynamic>> userResult) => MapEntry<String, TestResult>(
          userResult.key,
          TestResult.fromJson(userResult.value),
        ), 
      ),
    );

    return Test(
      id: data['id'],
      userId: data['userId'],
      name: data['name'],
      dateCreated: data['dateCreated'],
      imageUrl: data['imageUrl'],
      questions: questions,
      userResults: userResults,
      usersThatUpvoted: (data['usersThatUpvoted'] as List<dynamic>).cast<String>(),
      usersThatDownvoted: (data['usersThatDownvoted'] as List<dynamic>).cast<String>(),
      comments: (data['comments'] as List<dynamic>).cast<String>(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'name': name,
    'dateCreated': dateCreated,
    'imageUrl': imageUrl,
    'questions': List<Map<String, dynamic>>.from(
      questions.map<Map<String, dynamic>>((Question question) => question.toJson()),
    ),
    'userResults': Map<String, Map<String, dynamic>>.from(
      userResults.map<String, Map<String, dynamic>>(
        (String userId, TestResult testResult) => MapEntry<String, Map<String, dynamic>>(
          userId, testResult.toJson(),
        ),
      ),
    ),
    'usersThatUpvoted': usersThatUpvoted,
    'usersThatDownvoted': usersThatDownvoted,
    'comments': comments,
  };
}
