// back-end
import 'dart:typed_data';
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
  final TestResult _testResult = TestResult(
    correctAnswers: 0,
    score: 0,
  );
  int _currentQuestionIndex = 0;

  void _next() => setState(() {
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
      );
    } else {
      final Question currentQuestion = widget.testModel.questions[_currentQuestionIndex];

      // WARNING: KEEP THE KEY!
      // (Downloads the question's image, before any playing
      // or answer revealing can begin)
      body = InfoDownloader<Uint8List>(
        key: UniqueKey(),
        downloadInfo: () => downloadQuestionImage(testId, _currentQuestionIndex),
        builder: (BuildContext context, Uint8List? imageData) {
          final Image questionImage;

          if (imageData != null) {
            questionImage = Image.memory(imageData);
          } else {
            questionImage = Image.asset('default_image.png');
          }

          return PlayQuestionSolo(
            key: UniqueKey(),
            currentQuestionIndex: _currentQuestionIndex,
            currentQuestion: currentQuestion,
            questionImage: questionImage,
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
        ),
        child: body,
      ),
    );
  }
}
