// back-end
import 'package:hoothub/firebase/models/question.dart';
// front-end
import 'package:flutter/material.dart';
import 'package:hoothub/screens/play_test_solo/multiple_choice_player.dart';
import 'package:hoothub/screens/play_test_solo/multiple_choice_revelation.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:hoothub/screens/styles.dart';

class PlayQuestionSolo extends StatefulWidget {
  const PlayQuestionSolo({
    super.key,
    required this.currentQuestionIndex,
    required this.currentQuestion,
    required this.questionImage,
    required this.onNext,
  });

  final int currentQuestionIndex;
  final Question currentQuestion;
  final Widget questionImage;
  final void Function() onNext;

  @override
  State<PlayQuestionSolo> createState() => _PlayQuestionSoloState();
}

class _PlayQuestionSoloState extends State<PlayQuestionSolo> {
  final _countdownController = CountdownController(autoStart: true);
  int? _answerSelectedIndex;
  bool _answerRevealed = false;

  @override
  void dispose() {
    super.dispose();
    _countdownController.pause();
  }

  void _onQuestionFinished({ required int? answerSelectedIndex }) {
    setState(() {
      _countdownController.pause();
      _answerSelectedIndex = answerSelectedIndex;
      _answerRevealed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Text(
          widget.currentQuestion.question,
          textAlign: TextAlign.center,
          style: questionTextStyle,
        ),
        SizedBox(
          height: questionImageHeight,
          child: widget.questionImage,
        ),
        Countdown(
          controller: _countdownController,
          seconds: widget.currentQuestion.secondsDuration,
          build: (BuildContext context, double time) {
            return Text(
              time.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 40),
            );
          },
          onFinished: () {
            _onQuestionFinished(answerSelectedIndex: null);
          },
        ),
        (
          _answerRevealed
          ? MultipleChoiceRevelation(
            questionModel: widget.currentQuestion,
            chosenAnswer: _answerSelectedIndex,
            onNext: widget.onNext,
          )
          : MultipleChoicePlayer(
            questionModel: widget.currentQuestion,
            onAnswerSelected: _onQuestionFinished,
          )
        )
      ],
    );
  }
}
