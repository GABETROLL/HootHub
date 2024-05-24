// back-end
import 'package:hoothub/firebase/models/question.dart';
// front-end
import 'package:flutter/material.dart';
import 'answer.dart';

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
    final List<Widget> choices = <Widget>[];

    for (final (int index, String answer) in questionModel.answers.indexed) {
      choices.add(
        InkWell(
          onTap: () => onAnswerSelected(answerSelectedIndex: index),
          child: Answer(icon: const Icon(null), answer: answer),
        ),
      );
    }

    return Column(children: choices);
  }
}
