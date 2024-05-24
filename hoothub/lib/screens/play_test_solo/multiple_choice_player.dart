// back-end
import 'package:hoothub/firebase/models/question.dart';
// front-end
import 'package:flutter/material.dart';
import 'answers.dart';

/// WARNING: I think this one also tries to expand to fill its parent,
/// so its parent must have finite width.
///
/// (Built `Widget` is a `Column`)
class MultipleChoicePlayer extends StatelessWidget {
  const MultipleChoicePlayer({
    super.key,
    required this.questionModel,
    required this.onAnswerSelected,
  });

  final Question questionModel;
  final void Function({ required int answerSelectedIndex }) onAnswerSelected;

  @override
  Widget build(BuildContext context) {
    return Answers(
      questionModel: questionModel,
      answerMaker: (BuildContext context, int index, String answer) {
        final double hue = (index / questionModel.answers.length * 360).floorToDouble();

        final Color answerColor = HSVColor.fromAHSV(
          1,
          hue,
          1,
          1,
        ).toColor();

        return InkWell(
          onTap: () => onAnswerSelected(answerSelectedIndex: index),
          child: Answer(icon: const Icon(null), answer: answer, color: answerColor),
        );
      },
    );
  }
}
