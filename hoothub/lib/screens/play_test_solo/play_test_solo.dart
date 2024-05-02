// back-end
import 'package:hoothub/firebase/models/question.dart';
import 'package:hoothub/firebase/models/test.dart';
// front-end
import 'package:flutter/material.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'multiple_choice_player.dart';

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

  @override
  Widget build(BuildContext context) {
    // `_currentQuestionIndex` out of range of `widget.testModel.questions.length`.
    if (_currentQuestionIndex >= widget.testModel.questions.length) {
      return const Center(child: Text("All done! You've made it to the end of the test!"));
    }

    final Question currentQuestion = widget.testModel.questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.testModel.name),
      ),
      body: ListView(
        children: <Widget>[
          Text(currentQuestion.question),
          Countdown(
            seconds: 20,
            build: (BuildContext context, double time) => Text(time.toString()),
            interval: const Duration(seconds: 1),
            onFinished: () {
              print('COUNTDOWN FOR QUESTION $_currentQuestionIndex FINISHED!');
              setState(() { _currentQuestionIndex++; });
            },
          ),
          MultipleChoicePlayer(questionModel: currentQuestion),
        ],
      ),
    );
  }
}
