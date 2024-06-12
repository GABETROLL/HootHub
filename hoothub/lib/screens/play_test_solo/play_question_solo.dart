// back-end
import 'package:hoothub/firebase/models/question.dart';
import 'package:hoothub/firebase/models/test_result.dart';
// front-end
import 'package:flutter/material.dart';
import 'package:hoothub/screens/play_test_solo/multiple_choice_player.dart';
import 'package:hoothub/screens/play_test_solo/multiple_choice_revelation.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:hoothub/screens/styles.dart';

/// WARNING: ASSUMES `currentTestResult` IS ONLY REFERENCED
/// BY ITSELF. MAKE SURE THAT `currentTestResult` WAS
/// COPIED USING `.copy()` BEFORE INPUTTING IT INTO HERE.
///
/// WARNING: ALSO COPY `nextTestResult` INSIDE THE `onNext` CALLBACK.
///
/// THIS IS ALSO A `StatefulWidget`, SO, `currentTestResult`
/// WILL CHANGE INTERNALLY THROUGH `setState`. IF YOU DON'T
/// COPY `currentTestResult` FROM `PlayTestSolo`, SINCE BOTH
/// `PlayTestSolo` and THIS `StatefulWidget` WILL REFERENCE IT,
/// `PlayTestSolo`'s STATE WILL ALSO CHANGE, WITHOUT CALLING ITS `setState`.
class PlayQuestionSolo extends StatefulWidget {
  const PlayQuestionSolo({
    super.key,
    required this.currentQuestionIndex,
    required this.currentQuestion,
    required this.questionImage,
    required this.currentTestResult,
    required this.onNext,
  });

  final int currentQuestionIndex;
  final Question currentQuestion;
  final Widget questionImage;
  final TestResult currentTestResult;
  final void Function(TestResult nextTestResult) onNext;

  @override
  State<PlayQuestionSolo> createState() => _PlayQuestionSoloState();
}

class _PlayQuestionSoloState extends State<PlayQuestionSolo> {
  final _countdownController = CountdownController(autoStart: true);
  int? _answerSelectedIndex;
  bool _answerRevealed = false;

  late TestResult _testResult;

  @override
  void initState() {
    super.initState();
    _testResult = widget.currentTestResult;
  }

  @override
  void dispose() {
    super.dispose();
    _countdownController.pause();
  }

  // TODO: MAKE PLAYING QUESTION CONSIDER ANSWERING TIME FOR TEST RESULT.
  void _onQuestionFinished({ required int? answerSelectedIndex }) {
    setState(() {
      _countdownController.pause();
      _answerSelectedIndex = answerSelectedIndex;
      _answerRevealed = true;

      // If `answerSelectedIndex` is null, it won't equal to `correctAnswer`.
      if (answerSelectedIndex == widget.currentQuestion.correctAnswer) {
        _testResult.correctAnswers++;
      }
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
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 991),
            child: (
              _answerRevealed
              ? MultipleChoiceRevelation(
                questionModel: widget.currentQuestion,
                chosenAnswer: _answerSelectedIndex,
                // TODO: DISPLAY CURRENT SCORE HERE
                onNext: () => widget.onNext(_testResult),
              )
              : MultipleChoicePlayer(
                questionModel: widget.currentQuestion,
                onAnswerSelected: _onQuestionFinished,
              )
            ),
          ),
        ),
      ],
    );
  }
}
