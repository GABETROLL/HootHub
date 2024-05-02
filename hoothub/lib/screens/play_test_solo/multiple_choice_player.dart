// back-end
import 'package:hoothub/firebase/models/question.dart';
// front-end
import 'package:flutter/material.dart';

/// WARNING: I think this one also tries to expand to fill its parent,
/// so its parent must have finite width.
///
/// (Built `Widget` is a `Column`)
class MultipleChoicePlayer extends StatefulWidget {
  const MultipleChoicePlayer({
    super.key,
    required this.questionModel,
  });

  final Question questionModel;

  @override
  State<MultipleChoicePlayer> createState() => _MultipleChoicePlayerState();
}

class _MultipleChoicePlayerState extends State<MultipleChoicePlayer> {
  int? _chosenAnswer;

  @override
  Widget build(BuildContext context) {
    final List<Widget> choices = <Widget>[];

    for (final (int index, String answer) in widget.questionModel.answers.indexed) {
      final choice = Row(
        children: [
          Checkbox(
            value: _chosenAnswer != null && index == _chosenAnswer ? true : false,
            onChanged: (bool? checked) {
              // User can only choose their answer once (_chosenAnswer is not null).
              // All other attempts at choosing an answer after that should do nothing.
              if (_chosenAnswer != null) return;

              // At first, all the answers' corresponding checkboxes
              // have false as their value. When the user changes this one,
              // and they HAVEN'T chosen their answer yet (read the above statement),
              // the only possible `checked` value for this one, from then on is true
              // (read how the `value` is assigned, right above).
              //
              // When that happens, we choose this answer in `_chosenAnswer`,
              // and afterwards, because of the above statement, the user will not be able
              // to choose an answer for this question again.
              //
              // If the `checked` value isn't true, nothing will happen, since
              // choosing an answer, but having the checkbox not appear checked
              // would be confusing.
              if (checked != null && checked) {
                setState(() { _chosenAnswer = index; });
              }
            }
          ),
          Expanded(child: Text(answer)),
        ],
      );

      choices.add(choice);
    }

    return Column(children: choices);
  }
}
