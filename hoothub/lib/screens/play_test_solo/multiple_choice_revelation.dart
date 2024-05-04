// back-end
import 'package:hoothub/firebase/models/question.dart';
// front-end
import 'package:flutter/material.dart';

/// WARNING: I think this one also tries to expand to fill its parent,
/// so its parent must have finite width.
///
/// (Built `Widget` is a `Column`)
class MultipleChoiceRevelation extends StatelessWidget {
  const MultipleChoiceRevelation({
    super.key,
    required this.questionModel,
    required this.chosenAnswer,
  });

  final Question questionModel;
  // index of the answer the player chose for 'questionModel`.
  //
  // If the player didn't choose any answers before their timer ran out,
  // `chosenAnswer` should be null.
  final int? chosenAnswer;

  @override
  Widget build(BuildContext context) {
    final List<Widget> choices = <Widget>[];

    for (final (int index, String answer) in questionModel.answers.indexed) {
      final List<Widget> choiceChildren = <Widget>[
        Expanded(child: Text(answer)),
      ];

      if (chosenAnswer != null && index == chosenAnswer && chosenAnswer != questionModel.correctAnswer) {
        choiceChildren.insert(
          0,
          const Icon(
            Icons.close,
            color: Colors.red,
          ),
        );
      }
      if (index == questionModel.correctAnswer) {
        choiceChildren.insert(
          0,
          const Icon(
            Icons.check,
            color: Colors.green,
          ),
        );
      }

      choices.add(
        Row(children: choiceChildren)
      );
    }

    return Column(children: choices);
  }
}
