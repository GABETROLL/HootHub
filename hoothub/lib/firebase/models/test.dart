import 'iterable_equals.dart';
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
/// `upvotes`, `downvotes` and `commentCount` should be equal to
///   the lengths of `usersThatUpvoted`, `usersThatDownvoted` and `comments`,
///   AND THIS TEST WON'T BE VALID IF ANY OF THEM ARE NOT.
/// `usersThatUpvoted`/`usersThatDownvoted` are lists of IDs
///   of the users that upvoted/downvoted this test.
/// `comments` are a list of IDs of the `Comment` documents for this test.
class Test implements Model {
  const Test({
    required this.id,
    required this.userId,
    required this.name,
    required this.dateCreated,
    required this.questions,
    required this.userResults,
    required this.upvotes,
    required this.downvotes,
    required this.commentCount,
    required this.usersThatUpvoted,
    required this.usersThatDownvoted,
    required this.comments,
  });

  final String? id;
  final String? userId;
  final String name;
  final Timestamp? dateCreated;
  final List<Question> questions;
  final Map<String, TestResult> userResults;
  final int upvotes;
  final int downvotes;
  final int commentCount;
  final List<String> usersThatUpvoted;
  final List<String> usersThatDownvoted;
  final List<String> comments;

  static Test newTest() => const Test(
    id: null,
    userId: null,
    name: '',
    dateCreated: null,
    questions: <Question>[],
    userResults: <String, TestResult>{},
    upvotes: 0,
    downvotes: 0,
    commentCount: 0,
    usersThatUpvoted: <String>[],
    usersThatDownvoted: <String>[],
    comments: <String>[],
  );

  /// Validates `this` before it can be put in `FirebaseFirestore`.
  ///
  /// A `Test` is valid if its `name` and `questions` aren't empty,
  /// if all of its questions are valid,
  /// all of the `userResults.values` are valid individually
  /// and if their keys and `userId`s match,
  /// and if `upvotes`, `downvotes` and `commentCount` match the lengths of
  /// `usersThatUpvoted`, `usersThatDownvoted` and `comments`.
  ///
  /// `id`, `userId`, `dateCreated` ARE NOT NEEDED TO VALIDATE A TEST,
  /// because they SHOULD be created automatically by `saveTest`.
  ///
  /// `id`, `userId`, `dateCreated`, `usersThatUpvoted`, `usersThatDownvoted` and `comments`
  /// WON'T BE VALIDATED HERE, AND SHOULD BE VALIDATED BY FIREBASE SECURITY RULES.
  @override
  bool isValid() {
    for (final (int index, Question question) in questions.indexed) {
      if (!(question.isValid())) {
        print("question #$index invalid!");
        return false;
      }
    }

    // VALIDATE EACH ENTRY IN `userResults`

    for (final MapEntry<String, TestResult> mapEntry in userResults.entries) {
      // Each `testResult` must have a non-null `userId` field,
      // that's EQUAL to its key in `userResults`.
      final String userIdKey = mapEntry.key;
      final TestResult testResult = mapEntry.value;

      if (testResult.userId == null || testResult.userId != userIdKey) {
        print("User result's ID doesn't match its key: $userIdKey, ${testResult.userId}");
        return false;
      }

      // VALIDATE `testResult` USING ITS `.isValid`:

      if (!(testResult.isValid())) {
        print("Test result is invalid!");
        return false;
      }
    }

    return upvotes == usersThatUpvoted.length
      && downvotes == usersThatDownvoted.length
      && commentCount == comments.length
      && name.isNotEmpty && questions.isNotEmpty;
  }

  bool userUpvotedTest(String userId) {
    return usersThatUpvoted.contains(userId);
  }

  bool userDownvotedTest(String userId) {
    return usersThatDownvoted.contains(userId);
  }

  bool equals(Test other) {
    return (
      id == other.id
      && userId == other.userId
      && name == other.name
      && dateCreated == other.dateCreated
      && iterableEquals(questions, other.questions, (Question a, Question b) => a.equals(b))
      && iterableEquals(
        userResults.entries,
        other.userResults.entries,
        (MapEntry<String, TestResult> a, MapEntry<String, TestResult> b) => a.key == b.key && a.value.equals(b.value)
      )
      && upvotes == other.upvotes
      && downvotes == other.downvotes
      && commentCount == other.commentCount
      && iterableEquals(usersThatUpvoted, other.usersThatUpvoted, (String a, String b) => a == b)
      && iterableEquals(usersThatDownvoted, other.usersThatDownvoted, (String a, String b) => a == b)
      && iterableEquals(comments, other.comments, (String a, String b) => a == b)
    );
  }

  Test setId(String? newId) => Test(
    id: newId,
    userId: userId,
    name: name,
    dateCreated: dateCreated,
    questions: List.of(questions),
    userResults: Map<String, TestResult>.of(userResults),
    upvotes: upvotes,
    downvotes: downvotes,
    commentCount: commentCount,
    usersThatUpvoted: List<String>.of(usersThatUpvoted),
    usersThatDownvoted: List<String>.of(usersThatDownvoted),
    comments: List<String>.of(comments),
  );

  Test setUserId(String? newUserId) => Test(
    id: id,
    userId: newUserId,
    name: name,
    dateCreated: dateCreated,
    questions: List.of(questions),
    upvotes: upvotes,
    downvotes: downvotes,
    commentCount: commentCount,
    userResults: Map<String, TestResult>.of(userResults),
    usersThatUpvoted: List<String>.of(usersThatUpvoted),
    usersThatDownvoted: List<String>.of(usersThatDownvoted),
    comments: List<String>.of(comments),
  );

  Test setDateCreated(Timestamp? newDateCreated) => Test(
    id: id,
    userId: userId,
    name: name,
    dateCreated: newDateCreated,
    questions: List.of(questions),
    userResults: Map<String, TestResult>.of(userResults),
    upvotes: upvotes,
    downvotes: downvotes,
    commentCount: commentCount,
    usersThatUpvoted: List<String>.of(usersThatUpvoted),
    usersThatDownvoted: List<String>.of(usersThatDownvoted),
    comments: List<String>.of(comments),
  );

  Test setUpvotes(int newUpvotes) => Test(
    id: id,
    userId: userId,
    name: name,
    dateCreated: dateCreated,
    questions: List.of(questions),
    userResults: Map<String, TestResult>.of(userResults),
    upvotes: newUpvotes,
    downvotes: downvotes,
    commentCount: commentCount,
    usersThatUpvoted: List<String>.of(usersThatUpvoted),
    usersThatDownvoted: List<String>.of(usersThatDownvoted),
    comments: List<String>.of(comments),
  );

  Test setDownvotes(int newDownvotes) => Test(
    id: id,
    userId: userId,
    name: name,
    dateCreated: dateCreated,
    questions: List.of(questions),
    userResults: Map<String, TestResult>.of(userResults),
    upvotes: upvotes,
    downvotes: newDownvotes,
    commentCount: commentCount,
    usersThatUpvoted: List<String>.of(usersThatUpvoted),
    usersThatDownvoted: List<String>.of(usersThatDownvoted),
    comments: List<String>.of(comments),
  );

  Test setCommentCount(int newCommentCount) => Test(
    id: id,
    userId: userId,
    name: name,
    dateCreated: dateCreated,
    questions: List.of(questions),
    userResults: Map<String, TestResult>.of(userResults),
    upvotes: upvotes,
    downvotes: downvotes,
    commentCount: newCommentCount,
    usersThatUpvoted: List<String>.of(usersThatUpvoted),
    usersThatDownvoted: List<String>.of(usersThatDownvoted),
    comments: List<String>.of(comments),
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
    upvotes: upvotes,
    downvotes: downvotes,
    commentCount: commentCount,
    usersThatUpvoted: List<String>.of(usersThatUpvoted),
    usersThatDownvoted: List<String>.of(usersThatDownvoted),
    comments: List<String>.of(comments),
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
      upvotes: data['upvotes'],
      downvotes: data['downvotes'],
      commentCount: data['commentCount'],
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
    'upvotes': upvotes,
    'downvotes': downvotes,
    'commentCount': commentCount,
    'usersThatUpvoted': usersThatUpvoted,
    'usersThatDownvoted': usersThatDownvoted,
    'comments': comments,
  };
}
