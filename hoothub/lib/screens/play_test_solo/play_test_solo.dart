// back-end
import 'package:hoothub/firebase/models/question.dart';
import 'package:hoothub/firebase/models/test.dart';
// front-end
import 'package:flutter/material.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'multiple_choice_player.dart';
import 'multiple_choice_revelation.dart';

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
  int _currentQuestionIndex = 0;
  final countdownController = CountdownController();

  Future<void> revealCorrectAnswer({
    required BuildContext context,
    required Question currentQuestion,
    int? answerSelectedIndex
  }) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => MultipleChoiceRevelation(
          questionModel: currentQuestion,
          chosenAnswer: answerSelectedIndex,
        ),
      ),
    );

    setState(() { _currentQuestionIndex++; });
  }

  @override
  Widget build(BuildContext context) {
    // `_currentQuestionIndex` out of range of `widget.testModel.questions.length`.
    if (_currentQuestionIndex >= widget.testModel.questions.length) {
      return const Center(child: Text("All done! You've made it to the end of the test!"));
    }

    final Question currentQuestion = widget.testModel.questions[_currentQuestionIndex];
    countdownController.start();
    countdownController.restart();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.testModel.name),
      ),
      body: ListView(
        children: <Widget>[
          Text(currentQuestion.question),
          Countdown(
            controller: countdownController,
            seconds: 20, // TODO: Make the test customize the time each question takes
            build: (BuildContext context, double time) => Text(time.toString()),
            interval: const Duration(seconds: 1),
            onFinished: () {
              // print('COUNTDOWN FOR QUESTION $_currentQuestionIndex FINISHED!');
              revealCorrectAnswer(
                context: context,
                currentQuestion: currentQuestion
              );
            },
          ),
          MultipleChoicePlayer(
            questionModel: currentQuestion,
            onAnswerSelected: (int answerSelectedIndex) {
              countdownController.pause();
              revealCorrectAnswer(
                context: context,
                currentQuestion: currentQuestion,
                answerSelectedIndex: answerSelectedIndex
              );
            }
          ),
        ],
      ),
    );
  }
}
