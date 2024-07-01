// back-end
import 'dart:typed_data';
import 'package:hoothub/firebase/api/tests.dart';
import 'package:hoothub/firebase/models/question.dart';
import 'package:hoothub/firebase/models/test.dart';
import 'package:hoothub/firebase/api/images.dart';
// front-end
import 'package:flutter/material.dart';
import 'package:hoothub/firebase/models/test_result.dart';
import 'package:hoothub/screens/styles.dart';
import 'package:hoothub/screens/widgets/info_downloader.dart';
import 'play_question_solo.dart';
import 'test_results.dart';

/// `Widget` for `MaterialPageRoute<Test>`.
///
/// Plays `testModel` with the user,
/// then pops its route with the new version of `testModel`.
/// If there are no changes to be made to `testModel`, this route
/// pops with null.
///
/// The changes to be made to `testModel` from THIS `Widget`'s route
/// are the user's test results.
class PlayTestSolo extends StatefulWidget {
  const PlayTestSolo({
    super.key,
    required this.testModel,
  });

  final Test testModel;

  @override
  State<PlayTestSolo> createState() => _PlayTestSoloState();
}

class _PlayTestSoloState extends State<PlayTestSolo> {
  TestResult _testResult = const TestResult(
    // Even if the user is currently logged in when this test starts,
    // we want to upload their test results with their login info
    // AT THE END OF THE TEST, in case they somehow logged off or changed accounts
    // before the test finished.
    //
    // The user's ID will be filled in the `completeTest` call, down below.
    userId: null,
    questionResults: <QuestionResult>[],
    score: 0,
  );
  int _currentQuestionIndex = 0;

  void _next(TestResult newTestResult) => setState(() {
    _testResult = newTestResult;
    _currentQuestionIndex++;
  });

  @override
  Widget build(BuildContext context) {
    final Widget body;

    final String? testId = widget.testModel.id;

    if (testId == null) {
      return const Center(child: Text("Unfortunately, you can't play this test. It has a null id!"));
    }

    if (_currentQuestionIndex < 0) {
      body = const Center(
        child: Text('`_currentQuestionIndex` is below 0!'),
      );
      // `_currentQuestionIndex` out of range of `widget.testModel.questions.length`.
    } else if (_currentQuestionIndex >= widget.testModel.questions.length) {
      body = TestSoloResults(
        testResult: _testResult,
        questionsAmount: widget.testModel.questions.length,
        exit: () async {
          SaveTestNullableResult testCompletionResults = await completeTest(
            testId,
            _testResult,
          );

          if (!(context.mounted)) return;

          if (testCompletionResults.status != 'Ok') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(testCompletionResults.status)),
            );
            Navigator.pop<Test>(context, null);
          } else {
            // POP WITH RESULT

            // According to how `completeTest` works,
            // if `testCompletionResults.updatedTest` is null,
            // `testCompletionResults.status` WILL NOT BE 'Ok'.
            //
            // So, I think we can safely pop with `testCompletionResults.updatedTest`...
            // `testCompletionResults.updatedTest` MAY BE THE SAME AS `widget.testModel`,
            // BECAUSE THE PLAYER ALREADY PLAYED IT, WHICH MAY CAUSE `ViewTests`
            // TO REFRESH UNNECESSARILY.
            Navigator.pop<Test>(context, testCompletionResults.updatedTest);
          }
        },
      );
    } else {
      final Question currentQuestion = widget.testModel.questions[_currentQuestionIndex];

      // WARNING: KEEP THE KEY!
      // (Downloads the question's image, before any playing
      // or answer revealing can begin)
      body = InfoDownloader<Uint8List>(
        key: UniqueKey(),
        downloadInfo: () => downloadQuestionImage(testId, _currentQuestionIndex),
        builder: (BuildContext context, Uint8List? imageData, bool downloaded) {
          final Widget questionImage;

          if (downloaded) {
            if (imageData != null) {
              questionImage = Image.memory(imageData);
            } else {
              // no image displayed, if it was fetched,
              // and the question has no corresponding image.
              //
              // This `SizedBox` should be a 0x0 `Widget`,
              // and basically be nothing.
              questionImage = const SizedBox();
            }
          } else {
            questionImage = Image.asset('default_image.png');
          }

          // WARNING: KEEP THE KEY!
          return PlayQuestionSolo(
            key: UniqueKey(),
            currentQuestionIndex: _currentQuestionIndex,
            currentQuestion: currentQuestion,
            questionImage: questionImage,
            questionImageLoaded: downloaded,
            currentTestResult: _testResult,
            onNext: _next,
          );
        },
        buildError: (BuildContext context, Object error) {
          return Center(
            child: Text(
              "Error loading or displaying test $testId's question #$_currentQuestionIndex's image: $error",
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.testModel.name),
      ),
      body: Theme(
        data: ThemeData(
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: primaryColor),
          ),
          elevatedButtonTheme: const ElevatedButtonThemeData(
            style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(primaryColor),
              foregroundColor: MaterialStatePropertyAll(white),
            ),
          ),
        ),
        child: body,
      ),
    );
  }
}
