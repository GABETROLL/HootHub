// back-end
import 'package:hoothub/firebase/models/question.dart';
// front-end
import 'package:flutter/material.dart';
import 'package:hoothub/screens/play_test_solo/answers.dart';
import 'package:hoothub/screens/styles.dart';

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
    return Answers(
      questionModel: questionModel,
      answerMaker: (BuildContext context, int index, String answer) {
        final Icon icon;
        final Color color;

        if (index == questionModel.correctAnswer) {
          icon = const Icon(Icons.check, color: Colors.white);
          color = const HSVColor.fromAHSV(1, 120, themeColorsSaturation, themeColorsValue).toColor();
        } else {
          color = const HSVColor.fromAHSV(1, 0, themeColorsSaturation, themeColorsValue).toColor();

          if (chosenAnswer == null || chosenAnswer == index) {
            icon = const Icon(Icons.close, color: Colors.white);
          } else {
            icon = const Icon(null);
          }
        }

        return Answer(icon: icon, answer: answer, color: color);
      },
      nextButton: ElevatedButton(
        onPressed: onNext,
        child: const Text('Next'),
      ),
    );
  }
}
