// back-end
import 'package:hoothub/firebase/models/question.dart';
// front-end
import 'package:flutter/material.dart';
import 'package:hoothub/screens/play_test_solo/answer.dart';

/// Displays all of the answers in `questionModel.questions` in a vertical list,
/// with a green checkmark beside the correct answer and an 'x' icon beside the
/// answer the player chose, if that answer was wrong.
///
/// For the rest of the answers,
/// completely transparent 'x' icons are displayed.
///
/// This widget has a 'Next' button, that calls `onNext` when pressed.
/// 
/// WARNING: I think this one also tries to expand to fill its parent,
/// so its parent must have finite width.
/// (Built `Widget` is a `Column`)
class MultipleChoiceRevelation extends StatelessWidget {
  const MultipleChoiceRevelation({
    super.key,
    required this.questionModel,
    required this.chosenAnswer,
    required this.onNext,
  });

  final Question questionModel;
  // index of the answer the player chose for 'questionModel`.
  //
  // If the player didn't choose any answers before their timer ran out,
  // `chosenAnswer` should be null.
  final int? chosenAnswer;
  final void Function() onNext;

  @override
  Widget build(BuildContext context) {
    final List<Widget> choices = <Widget>[];

    for (final (int index, String answer) in questionModel.answers.indexed) {
      choices.add(
        Answer(
          icon: (
            index == questionModel.correctAnswer
            ? const Icon(
              Icons.check,
              color: Colors.green,
            )
            : Icon(
              Icons.close,
              color: Color(chosenAnswer == null || index == chosenAnswer ? 0xFFFF0000 : 0x00000000),
            )
          ),
          answer: answer
        ),
      );
    }

    choices.add(
      ElevatedButton(
        onPressed: onNext,
        child: const Text('Next'),
      ),
    );

    return Scaffold(
      body: Column(children: choices),
    );
  }
}
