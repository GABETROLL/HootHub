// back-end
import 'package:hoothub/firebase/api/images.dart';
import 'package:hoothub/firebase/models/question.dart';
import 'package:hoothub/firebase/models/test.dart';
// front-end
import 'package:flutter/material.dart';
import 'package:hoothub/firebase/models/test_result.dart';
import 'package:hoothub/screens/styles.dart';
import 'package:hoothub/screens/widgets/info_downloader.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'multiple_choice_player.dart';
import 'multiple_choice_revelation.dart';
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
  final countdownController = CountdownController(autoStart: true);

  Future<void> _nextQuestion({
    required BuildContext context,
    required Question currentQuestion,
    int? answerSelectedIndex,
  }) async {
    int testResultCorrectAnswers = _testResult.correctAnswers;

    if (answerSelectedIndex == currentQuestion.correctAnswer) {
      testResultCorrectAnswers++;
    }

    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => MultipleChoiceRevelation(
          questionModel: currentQuestion,
          chosenAnswer: answerSelectedIndex,
        ),
      ),
    );

    setState(() {
      _currentQuestionIndex++;
      _testResult.correctAnswers = testResultCorrectAnswers;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget body;

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
      countdownController.restart();

      body = ListView(
        children: <Widget>[
          Text(
            currentQuestion.question,
            textAlign: TextAlign.center,
            style: questionTextStyle,
          ),
          SizedBox(
            height: questionImageHeight,
            child: InfoDownloader<String>(
              key: UniqueKey(),
              downloadInfo: () => questionImageDownloadUrl(widget.testModel.id!, _currentQuestionIndex),
              buildSuccess: (BuildContext context, String imageUrl) {
                return Image.network(imageUrl);
              },
              buildLoading: (BuildContext context) {
                return Image.asset('default_image.png');
              },
              buildError: (BuildContext context, Object error) {
                return Center(
                  child: Text(
                    "Error loading or displaying test ${widget.testModel.id}'s question #$_currentQuestionIndex's image: $error",
                  ),
                );
              },
            ),
          ),
          Countdown(
            controller: countdownController,
            seconds: currentQuestion.secondsDuration,
            build: (BuildContext context, double time) => Text(
              time.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 40),
            ),
            onFinished: () {
              _nextQuestion(
                context: context,
                currentQuestion: currentQuestion,
              );
            },
          ),
          MultipleChoicePlayer(
            questionModel: currentQuestion,
            onAnswerSelected: (int answerSelectedIndex) {
              countdownController.pause();
              _nextQuestion(
                context: context,
                currentQuestion: currentQuestion,
                answerSelectedIndex: answerSelectedIndex,
              );
            }
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.testModel.name),
      ),
      body: body,
    );
  }
}
