// back-end
import 'package:hoothub/firebase/models/question.dart';
import 'package:hoothub/firebase/models/test.dart';
// front-end
import 'package:flutter/material.dart';
import 'package:hoothub/firebase/models/test_result.dart';
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
      print('Restarted timer');

      body = ListView(
        children: <Widget>[
          Text(currentQuestion.question),
          Countdown(
            controller: countdownController,
            seconds: currentQuestion.secondsDuration,
            build: (BuildContext context, double time) => Text(time.toString()),
            onFinished: () {
              print('COUNTDOWN FOR QUESTION $_currentQuestionIndex FINISHED!');
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
              print('Paused timer');
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
