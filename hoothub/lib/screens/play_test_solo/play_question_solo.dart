// back-end
import 'package:hoothub/firebase/models/question.dart';
import 'package:hoothub/firebase/models/test_result.dart';
// front-end
import 'package:flutter/material.dart';
import 'package:hoothub/screens/play_test_solo/multiple_choice_player.dart';
import 'package:hoothub/screens/play_test_solo/multiple_choice_revelation.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:hoothub/screens/styles.dart';

class PlayQuestionSolo extends StatefulWidget {
  const PlayQuestionSolo({
    super.key,
    required this.currentQuestionIndex,
    required this.currentQuestion,
    required this.questionImage,
    required this.questionImageLoaded,
    required this.currentTestResult,
    required this.onNext,
  });

  final int currentQuestionIndex;
  final Question currentQuestion;
  final Widget questionImage;
  final bool questionImageLoaded;
  final TestResult currentTestResult;
  final void Function(TestResult nextTestResult) onNext;

  @override
  State<PlayQuestionSolo> createState() => _PlayQuestionSoloState();
}

class _PlayQuestionSoloState extends State<PlayQuestionSolo> {
  late TestResult _testResult;

  late final StopWatchTimer _stopWatchTimer;

  // answer
  int? _answerSelectedIndex;
  bool _answerRevealed = false;

  @override
  void initState() {
    super.initState();
    _testResult = widget.currentTestResult;

    // timer
    _stopWatchTimer = StopWatchTimer(
      mode: StopWatchMode.countDown,
      presetMillisecond: StopWatchTimer.getMilliSecFromSecond(widget.currentQuestion.secondsDuration),
      // Player ran out of time:
      onEnded: () => _onQuestionFinished(answerSelectedIndex: null),
    );
  }

  @override
  void dispose() async {
    super.dispose();
    await _stopWatchTimer.dispose();
  }

  /// Returns the current question's time left, IN INT SECONDS from the stream: `_stopWatchTimer.secondTime`.
  /// If that stream has no value, this getter returns the current question's time duration instead.
  /// TODO: MAKE THIS DOUBLE, AND MORE PRECISE THAN SECONDS.
  int get timeLeft => _stopWatchTimer.secondTime.hasValue ? _stopWatchTimer.secondTime.value : widget.currentQuestion.secondsDuration;

  /// WARNING: DOESN'T STOP TIMER.
  void _onQuestionFinished({ required int? answerSelectedIndex }) {
    // THE ONLY WAY A QUESTION COULD FINISH,
    // IS IF THE ANSWER WASN'T ALREADY REVEALED,
    // BECAUSE THE PLAYER SHOULDN'T BE ABLE TO ACCESS ANSWERING A QUESTION
    // IF THE ANSWERS WERE ALREADY REVEALED.
    assert (!_answerRevealed);

    final bool answeredCorrectly = answerSelectedIndex == widget.currentQuestion.correctAnswer;
    // TODO: TURN INTO DOUBLE!
    final double answeringTime = (widget.currentQuestion.secondsDuration - timeLeft).toDouble();

    final TestResult newTestResult = _testResult.updateScore(
      answeredCorrectly,
      answeringTime,
      widget.currentQuestion.secondsDuration.toDouble(),
    );

    setState(() {
      _answerSelectedIndex = answerSelectedIndex; // may not always change!
      _answerRevealed = true; // Always changes state (DUE TO ASSERTION IN THE START OF THIS METHOD (`_onQuestionFinished`!)
      _testResult = newTestResult; // may not always change!
    });
  }

  @override
  Widget build(BuildContext context) {
    // DO NOT START THE TIMER UNTIL `PlayTestSolo -> InfoDownloader<Uint8List>`
    // HAS FINISHED DOWNLOADING THIS QUESTION'S IMAGE.
    if (widget.questionImageLoaded && !_answerRevealed) {
      _stopWatchTimer.onStartTimer();
    }

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
        StreamBuilder(
          stream: _stopWatchTimer.secondTime,
          initialData: _stopWatchTimer.secondTime.hasValue ? _stopWatchTimer.secondTime.value : widget.currentQuestion.secondsDuration,
          builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
            if (snapshot.error != null) {
              print(snapshot.error);
            }

            if (snapshot.data != null) {
              return Text(
                snapshot.data.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 40),
              );
            } else {
              return const Text('??');
            }            
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
                onAnswerSelected: ({required int answerSelectedIndex}) {
                  _stopWatchTimer.onStopTimer();
                  _onQuestionFinished(answerSelectedIndex: answerSelectedIndex);
                },
              )
            ),
          ),
        ),
      ],
    );
  }
}
