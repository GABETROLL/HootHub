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
    List<Question>? questions,
    Map<String, TestResult>? userResults,
    List<String>? usersThatUpvoted,
    List<String>? usersThatDownvoted,
    List<String>? comments,
  }) {
    if (name != null) {
      this.name = name;
    } else {
      this.name = '';
    }

    if (questions != null) {
      this.questions = questions;
    } else {
      this.questions = <Question>[];
    }

    if (userResults != null) {
      this.userResults = userResults;
    } else {
      this.userResults = <String, TestResult>{};
    }

    if (usersThatUpvoted != null) {
      this.usersThatUpvoted = usersThatUpvoted;
    } else {
      this.usersThatUpvoted = <String>[];
    }

    if (usersThatDownvoted != null) {
      this.usersThatDownvoted = usersThatDownvoted;
    } else {
      this.usersThatDownvoted = <String>[];
    }

    if (comments != null) {
      this.comments = comments;
    } else {
      this.comments = <String>[];
    }
  }

  final String? id;
  final String? userId;
  late final String name;
  final Timestamp? dateCreated;
  late final List<Question> questions;
  late final Map<String, TestResult> userResults;
  late final List<String> usersThatUpvoted;
  late final List<String> usersThatDownvoted;
  late final List<String> comments;

  /// Validates `this` before it can be put in `FirebaseFirestore`.
  ///
  /// A `Test` is valid if its `name` and `questions` aren't empty,
  /// if all of its questions are valid,
  /// and if all of the `userResults.values` are valid, according to this test.
  ///
  /// `id`, `userId`, `dateCreated` ARE NOT NEEDED TO VALIDATE A TEST,
  /// because they SHOULD be created automatically by `saveTest`.
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

  bool userUpvotedTest(String userId) {
    return usersThatUpvoted.contains(userId);
  }

  bool userDownvotedTest(String userId) {
    return usersThatDownvoted.contains(userId);
  }

  Test setId(String? newId) => Test(
    id: newId,
    userId: userId,
    name: name,
    dateCreated: dateCreated,
    questions: List.of(questions),
    userResults: Map<String, TestResult>.of(userResults),
    usersThatUpvoted: List<String>.of(usersThatUpvoted),
    usersThatDownvoted: List<String>.of(usersThatDownvoted),
  );

  Test setUserId(String? newUserId) => Test(
    id: id,
    userId: newUserId,
    name: name,
    dateCreated: dateCreated,
    questions: List.of(questions),
    userResults: Map<String, TestResult>.of(userResults),
    usersThatUpvoted: List<String>.of(usersThatUpvoted),
    usersThatDownvoted: List<String>.of(usersThatDownvoted),
  );

  Test setDateCreated(Timestamp? newDateCreated) => Test(
    id: id,
    userId: userId,
    name: name,
    dateCreated: newDateCreated,
    questions: List.of(questions),
    userResults: Map<String, TestResult>.of(userResults),
    usersThatUpvoted: List<String>.of(usersThatUpvoted),
    usersThatDownvoted: List<String>.of(usersThatDownvoted),
  );

  /// Returns DEEP COPY of `this`.
  ///
  /// Immutable fields are not copied.
  Test copy() => Test(
    id: id,
    userId: userId,
    name: name,
    dateCreated: dateCreated,
    questions: List<Question>.of(questions),
    userResults: Map<String, TestResult>.of(userResults),
    usersThatUpvoted: List<String>.of(usersThatUpvoted),
    usersThatDownvoted: List<String>.of(usersThatDownvoted),
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
