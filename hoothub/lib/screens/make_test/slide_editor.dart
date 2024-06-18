// front-end
import 'package:flutter/material.dart';
import 'package:hoothub/screens/make_test/editors.dart';
import 'package:hoothub/screens/styles.dart';

/// WARNING: Tries to expand to fill its parent,
/// so its parent must have finite width.
///
/// (Built `Widget` is a `Column`)
class MultipleChoiceEditor extends StatelessWidget {
  const MultipleChoiceEditor({
    super.key,
    required this.questionModelEditor,
    required this.addNewEmptyAnswer,
    required this.setCorrectAnswer,
  });

  final QuestionModelEditor questionModelEditor;
  final void Function() addNewEmptyAnswer;
  final void Function(int) setCorrectAnswer;

  @override
  Widget build(BuildContext context) {
    // WARNING: DO NOT USE `questionModelEditor`'S METHODS FOR SETTING ITS STATE,
    // USE `addNewEmptyAnswer` and `setCorrectAnswer` INSTEAD,
    // SINCE THOSE WILL BE THE ONES THAT CALL THIS WIDGET'S PARENT'S `setState`!

    final List<Widget> choices = <Widget>[];

    for (int index = 0; index < questionModelEditor.answerEditingControllers.length; index++) {
      final choice = Row(
        children: <Widget>[
          Checkbox(
            value: index == questionModelEditor.correctAnswer,
            onChanged: (bool? checked) {
              if (checked != null && checked) {
                setCorrectAnswer(index);
              }
            }
          ),
          Expanded(
            child: TextField(
              controller: questionModelEditor.answerEditingControllers[index],
              style: answerTextStyle,
              decoration: InputDecoration(
                hintText: 'Answer ${index + 1} ${index >= 2 ? '(Optional)' : ''}',
              ),
            ),
          ),
        ],
      );

      choices.add(choice);
    }

    // Only allow the player the option to add a new answer,
    // if the amount of answers in `questionModelEditor` is below 6:
    if (questionModelEditor.answerEditingControllers.length < 6) {
      choices.add(
        ElevatedButton(
          onPressed: () => addNewEmptyAnswer(),
          child: const Text('Add answer')
        ),
      );
    }

    return Column(children: choices);
  }
}

/// WARNING: Tries to expand to fill its parent,
/// so its parent must have finite width.
///
/// (Built `Widget` is a `Column`)
class SlideEditor extends StatelessWidget {
  const SlideEditor({
    super.key,
    required this.questionModelEditor,
    required this.questionImageEditor,
    required this.addNewEmptyAnswer,
    required this.setCorrectAnswer,
    required this.setSecondsDuration,
  });

  final QuestionModelEditor questionModelEditor;
  final Widget questionImageEditor;
  final void Function() addNewEmptyAnswer;
  final void Function(int) setCorrectAnswer;
  final void Function(int) setSecondsDuration;

  @override
  Widget build(BuildContext context) {
    // WARNING: DO NOT USE `questionModelEditor`'S METHODS FOR SETTING ITS STATE,
    // USE `addNewEmptyAnswer`, `setCorrectAnswer` and `setSecondsDuration` INSTEAD,
    // SINCE THOSE WILL BE THE ONES THAT CALL THIS WIDGET'S PARENT'S `setState`!

    return ListView(
      children: <Widget>[
        TextField(
          controller: questionModelEditor.questionEditingController,
          style: questionTextStyle,
          decoration: const InputDecoration(hintText: 'Question'),
        ),
        Center(
          child: Container(
            alignment: Alignment.center,
            constraints: const BoxConstraints(maxHeight: questionImageHeight),
            child: questionImageEditor,
          ),
        ),
        Row(
          children: <Widget>[
            const Text('Time:'),
            Expanded(
              child: Slider(
                value: questionModelEditor.secondsDuration.toDouble(),
                onChanged: (double selectedSecondsDuration) {
                  setSecondsDuration(selectedSecondsDuration.toInt());
                },
                min: 1,
                max: 60,
                divisions: 60,
                label: questionModelEditor.secondsDuration.toString(),
              ),
            ),
          ],
        ),
        Text('${questionModelEditor.secondsDuration} second${questionModelEditor.secondsDuration.abs() != 1 ? 's' : ''}'),
        MultipleChoiceEditor(
          questionModelEditor: questionModelEditor,
          addNewEmptyAnswer: () => addNewEmptyAnswer(),
          setCorrectAnswer: (int index) => setCorrectAnswer(index),
        ),
      ],
    );
  }
}
