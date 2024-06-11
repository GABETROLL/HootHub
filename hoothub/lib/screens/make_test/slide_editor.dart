import 'package:hoothub/firebase/models/question.dart';
// front-end
import 'package:flutter/material.dart';
import 'image_editor.dart';
import 'package:hoothub/screens/styles.dart';

/// WARNING: Tries to expand to fill its parent,
/// so its parent must have finite width.
///
/// (Built `Widget` is a `Column`)
class MultipleChoiceEditor extends StatelessWidget {
  const MultipleChoiceEditor({
    super.key,
    required this.questionModel,
    required this.answerEditingControllers,
    required this.addNewEmptyAnswer,
    required this.setCorrectAnswer,
  });

  final Question questionModel;
  final List<TextEditingController> answerEditingControllers;
  final void Function() addNewEmptyAnswer;
  final void Function(int) setCorrectAnswer;

  @override
  Widget build(BuildContext context) {
    final List<Widget> choices = <Widget>[];

    for (int index = 0; index < questionModel.answers.length; index++) {
      final choice = Row(
        children: <Widget>[
          Checkbox(
            value: index == questionModel.correctAnswer,
            onChanged: (bool? checked) {
              if (checked != null && checked) {
                setCorrectAnswer(index);
              }
            }
          ),
          Expanded(
            child: TextField(
              controller: answerEditingControllers[index],
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

    if (questionModel.answers.length < 6) {
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
    required this.questionModel,
    required this.questionEditingController,
    required this.answerEditingControllers,
    required this.questionImageEditor,
    required this.addNewEmptyAnswer,
    required this.setCorrectAnswer,
    required this.setSecondsDuration,
  });

  final Question questionModel;
  final TextEditingController questionEditingController;
  final List<TextEditingController> answerEditingControllers;
  final ImageEditor questionImageEditor;
  final void Function() addNewEmptyAnswer;
  final void Function(int) setCorrectAnswer;
  final void Function(int) setSecondsDuration;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        TextField(
          controller: questionEditingController,
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
                value: questionModel.secondsDuration.toDouble(),
                onChanged: (double selectedSecondsDuration) {
                  setSecondsDuration(selectedSecondsDuration.toInt());
                },
                min: 1,
                max: 60,
                divisions: 60,
                label: questionModel.secondsDuration.toString(),
              ),
            ),
          ],
        ),
        Text('${questionModel.secondsDuration} second${questionModel.secondsDuration > 1 ? 's' : ''}'),
        MultipleChoiceEditor(
          questionModel: questionModel,
          answerEditingControllers: answerEditingControllers,
          addNewEmptyAnswer: () => addNewEmptyAnswer(),
          setCorrectAnswer: (int index) => setCorrectAnswer(index),
        ),
      ],
    );
  }
}
