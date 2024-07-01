/// Contains the "editor" conversion of the `Question` and `Test` models in `package:hoothub/firebase/models/`.
///
/// The reason for these models existing, is that the user must be able to edit text in real-time
/// in the `MakeTest` `Widget`, and having the text only edit itself whenever the user presses
/// enter would be a very annoying task.
///
/// The user should also be able to delete an answer or a question. Doing the `TextEditingController`s-
/// substitutes-question-and-answer-texts thing would be fine, if the only features this app would have
/// were adding and editing questions and answers, since we could just place the `TextEditingController`s
/// outside of the models, in the `MakeTest` widet's `State` object, BUT, when it comes to DELETING answers
/// and questions in the UI, not only would we have to delete the answers and questions in the MODELS,
/// BUT ALSO DELETE THEIR `TextEditingController`S, TOO, AND EVEN THEIR IMAGES!!
///
/// So, instead, we're settling for a centralized system of storing all of the `Test` model's information,
/// where we take the `Test` the user is supposed to be editing through `MakeTest`,
/// and convert it into an `TestModelEditor`, where we can manage EVERYTHING about test editing,
/// INCLUDING BOTH TEXT EDITING AND QUESTUON/ANSWER DELETING.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hoothub/firebase/models/question.dart';
import 'package:hoothub/firebase/models/test.dart';
import 'package:hoothub/firebase/models/test_result.dart';
import 'package:hoothub/firebase/api/images.dart';

import 'dart:typed_data';
import 'package:flutter/material.dart';

class QuestionModelEditor {
  QuestionModelEditor({
    required this.questionEditingController,
    required this.image,
    required this.answerEditingControllers,
    required this.correctAnswer,
    this.secondsDuration = 20,
  });

  TextEditingController questionEditingController;
  Uint8List? image;
  List<TextEditingController> answerEditingControllers;
  int correctAnswer;
  int secondsDuration;

  /// Converts `question` into its `QuestionModelEditor` equivalent.
  ///
  /// WARNING: IF `testId` IS NOT NULL,
  /// THIS METHOD DOWNLOADS
  /// THIS QUESTION'S IMAGE FROM CLOUD STORAGE, USING `downloadQuestionImage`,
  /// AND ASSIGNS IT TO `image`.
  static Future<QuestionModelEditor> fromQuestion(String? testId, int questionIndex, Question question) async {
    return QuestionModelEditor(
      questionEditingController: TextEditingController(text: question.question),
      image: testId != null ? (await downloadQuestionImage(testId, questionIndex)) : null,
      answerEditingControllers: List<TextEditingController>.from(
        question.answers.map<TextEditingController>(
          (String answer) => TextEditingController(text: answer),
        ),
      ),
      correctAnswer: question.correctAnswer,
      secondsDuration: question.secondsDuration,
    );
  }

  /// Converts `this` into its `Question` equivalent.
  ///
  /// WARNING: DOES NOT UPLOAD QUESTION'S IMAGE TO CLOUD STORAGE!!!
  Question toQuestion() {
    return Question(
      question: questionEditingController.text,
      answers: List<String>.from(
        answerEditingControllers.map<String>(
          (TextEditingController answerEditingController) => answerEditingController.text,
        ),
      ),
      correctAnswer: correctAnswer,
      secondsDuration: secondsDuration,
    );
  }

  /// Adds a new, empty `TextEditingController` to the end of `answerEditingControllers`.
  void addNewEmptyAnswer() {
    answerEditingControllers.add(
      TextEditingController(),
    );
  }

  /// Throws error if `index` is out of the range of `answerEditingControllers`.
  void _checkAnswerIndex(int index) {
    if (index < 0 || index >= answerEditingControllers.length) {
      throw "Answer index out of range: $index";
    }
  }

  /// Deletes the `index`-th answer editing controller in `answerEditingControllers`,
  /// and updates `correctAnswer` accordingly.
  ///
  /// Throws if `index` is out of range of `answerEditingControllers`.
  void deleteAnswer(int index) {
    _checkAnswerIndex(index);

    // 0 <= index && index < answerEditingControllers.length

    if (correctAnswer >= answerEditingControllers.length - 1) {
      correctAnswer = answerEditingControllers.length - 1;
    }

    // correctAnswer < answerEditingControllers.length

    if (correctAnswer == answerEditingControllers.length - 1 || correctAnswer > index) {
      correctAnswer--;
    }

    // correctAnswer < answerEditingControllers.length - 1

    if (correctAnswer < 0) {
      correctAnswer = 0;
    }

    // 0 <= correctAnswer < answerEditingControllers.length - 1

    answerEditingControllers.removeAt(index);

    // 0 <= correctAnswer < answerEditingControllers.length
  }

  /// Sets `correctAnswer: index`.
  ///
  /// Throws an error if the index is outside the range of `answerEditingControllers`.
  void setCorrectAnswer(int index) {
    _checkAnswerIndex(index); // THIS LINE IS NEEDED TO VALIDATE `index`.
    correctAnswer = index;
  }

  /// Sets `this.secondsDuration: secondsDuration`.
  void setSecondsDuration(int secondsDuration) {
    this.secondsDuration = secondsDuration;
  }
}

class TestModelEditor {
  TestModelEditor({
    required this.id,
    required this.userId,
    required this.nameEditingController,
    required this.image,
    required this.dateCreated,
    required this.questionModelEditors,
    required this.userResults,
    required this.usersThatUpvoted,
    required this.usersThatDownvoted,
   required this.comments,
  });

  final String? id;
  final String? userId;
  final TextEditingController nameEditingController;
  Uint8List? image;
  final Timestamp? dateCreated;
  final List<QuestionModelEditor> questionModelEditors;
  Map<String, TestResult> userResults = <String, TestResult>{};
  List<String> usersThatUpvoted = <String>[];
  List<String> usersThatDownvoted = <String>[];
  List<String> comments = <String>[];

  /// Converts `test` to its `TestModelEditor` equivalent.
  ///
  /// WARNING: IF `testId` IS NOT NULL,
  /// THIS METHOD DOWNLOADS
  /// THIS TESTS'S IMAGE FROM CLOUD STORAGE, USING `downloadTestImage`,
  /// AND ASSIGNS IT TO `image`.
  ///
  /// THIS METHOD ALSO CONVERTS EACH QUESTION IN `test.questions` TO A
  /// `QuestionModelEditor`, USING `QuestionModelEditor.fromQuestion(<current question>)`,
  /// WHICH ALSO DOWNLOADS THE QUESTION'S IMAGE, USING `downloadQuestionImage`,
  /// AND ASSIGNS IT TO THE QUESTION'S `image` FIELD.
  static Future<TestModelEditor> fromTest(Test test) async {
    String? testId = test.id;

    List<QuestionModelEditor> questionModelEditors = <QuestionModelEditor>[];

    for (final (int index, Question question) in test.questions.indexed) {
      final QuestionModelEditor questionModelEditor = await QuestionModelEditor.fromQuestion(
        testId, index, question,
      );

      questionModelEditors.add(questionModelEditor);
    }

    return TestModelEditor(
      id: testId,
      userId: test.userId,
      nameEditingController: TextEditingController(text: test.name),
      image: testId != null ? (await downloadTestImage(testId)) : null,
      dateCreated: test.dateCreated,
      questionModelEditors: questionModelEditors,
      userResults: test.userResults,
      usersThatUpvoted: test.usersThatUpvoted,
      usersThatDownvoted: test.usersThatDownvoted,
      comments: test.comments,
    );
  }

  /// Converts this to its `Test` equivalent.
  ///
  /// WARNING: DOES NOT UPLOAD TESTS'S IMAGE TO CLOUD STORAGE!!!
  Test toTest() {
    return Test(
      id: id,
      userId: userId,
      name: nameEditingController.text,
      dateCreated: dateCreated,
      questions: List<Question>.from(
        questionModelEditors.map<Question>(
          (QuestionModelEditor questionModelEditor) => Question(
            question: questionModelEditor.questionEditingController.text,
            answers: List<String>.from(
              questionModelEditor.answerEditingControllers.map<String>(
                (TextEditingController textEditingController) => textEditingController.text,
              ),
            ),
            correctAnswer: questionModelEditor.correctAnswer,
            secondsDuration: questionModelEditor.secondsDuration,
          ),
        ),
      ),
      userResults: userResults,
      usersThatUpvoted: usersThatUpvoted,
      usersThatDownvoted: usersThatDownvoted,
      comments: comments,
    );
  }

  /// Adds a new `QuestionModelEditor` at the end of `questionModelEditors`
  ///
  /// The new, `QuestionModelEditor` should be the equivalent of:
  /// `Question(question: '', answers: ['', ''], correctAnswer: 0)`.
  /// (THIS METHOD DOESN'T CONSTRUCT THE ABOVE OBJECT, THEN CONVERT FROM IT,
  /// BUT DIRECTLY CONSTRUCTS ITS `QuestionModelEditor` EQUIVALENT)
  void addNewEmptyQuestion() {
    questionModelEditors.add(
      QuestionModelEditor(
        questionEditingController: TextEditingController(),
        image: null,
        answerEditingControllers: <TextEditingController>[TextEditingController(), TextEditingController()],
        correctAnswer: 0,
      ),
    );
  }

  /// Throws error if `index` is out of the range of `questionModelEditors`.
  void _checkQuestionIndex(int index) {
    if (index < 0 || index >= questionModelEditors.length) {
      throw "Question index out of range: $index";
    }
  }

  /// Deletes the `questionIndex`-th `QuestionModelEditor` in `questionModelEditors`.
  ///
  /// Throws if `questionIndex` is out of range of `questionModelEditors`.
  void deleteQuestion(int questionIndex) {
    _checkQuestionIndex(questionIndex);
    questionModelEditors.removeAt(questionIndex);
  }

  /// Adds a new, empty `TextEditingController` to the end of the `answerEditingControllers`
  /// of the `questionIndex`-th `QuestionModelEditor`.
  ///
  /// Throws if the `questionIndex` is out of range of `questionModelEditors`.
  void addNewEmptyAnswer(int questionIndex) {
    _checkQuestionIndex(questionIndex);
    questionModelEditors[questionIndex].addNewEmptyAnswer();
  }

  /// Assigns `correctAnswer: answerIndex` to the `questionIndex`-th `QuestionModelEditor`.
  ///
  /// Throws if either the `questionIndex` is out of range of `questionModelEditors`,
  /// or if `answerIndex` is out of range of `questionModelEditors[questionIndex].answerEditingControllers`.
  void setCorrectAnswer(int questionIndex, int answerIndex) {
    _checkQuestionIndex(questionIndex);
    questionModelEditors[questionIndex].setCorrectAnswer(answerIndex);
  }

  /// Deletes the `answerIndex`-th answer editing controller in the `answerEditingControllers` field
  /// of the `questionIndex`-th question in `questionModelEditors`.
  ///
  /// Throws if `questionIndex` is out of range of `questionModelEditors`,
  /// or if `answerIndex` is out of range of THAT question's `answerEditingControllers` field.
  void deleteAnswer(int questionIndex, int answerIndex) {
    _checkQuestionIndex(questionIndex);
    questionModelEditors[questionIndex].deleteAnswer(answerIndex);
  }

  /// Sets `secondsDuration: secondsDuration` in the `questionIndex`-th
  /// `QuestionModelEditor`.
  ///
  /// Throws if the `questionIndex` is out of range of `questionModelEditors`.
  void setSecondsDuration(int questionIndex, int secondsDuration) {
    _checkQuestionIndex(questionIndex);
    questionModelEditors[questionIndex].setSecondsDuration(secondsDuration);
  }
}
