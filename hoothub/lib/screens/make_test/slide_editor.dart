import 'package:hoothub/firebase/models/question.dart';
// front-end
import 'package:flutter/material.dart';

/// WARNING: I think this one also tries to expand to fill its parent,
/// so its parent must have finite width.
///
/// (Built `Widget` is a `Column`)
class MultipleChoiceEditor extends StatelessWidget {
  MultipleChoiceEditor({
    super.key,
    required this.questionModel,
    required this.addNewEmptyAnswer,
    required this.setCorrectAnswer,
    required this.setAnswer,
  }) {
    answerTextEditingControllers = <TextEditingController>[];

    for (final String answer in questionModel.answers) {
      answerTextEditingControllers.add(TextEditingController(text: answer));
    }
  }

  final Question questionModel;
  final void Function() addNewEmptyAnswer;
  final void Function(int) setCorrectAnswer;
  final void Function(int, String) setAnswer;

  late final List<TextEditingController> answerTextEditingControllers;

  @override
  Widget build(BuildContext context) {
    final List<Widget> choices = <Widget>[];

    for (final (int index, TextEditingController answerTextEditingController) in answerTextEditingControllers.indexed) {
      final choice = Row(
        children: [
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
              controller: answerTextEditingController,
              decoration: InputDecoration(
                hintText: 'Answer ${index + 1} ${index >= 2 ? '(Optional)' : ''}',
              ),
            ),
          ),
        ],
      );

      choices.add(choice);
    }

    choices.add(
      ElevatedButton(
        onPressed: () => addNewEmptyAnswer(),
        child: const Text('Add answer')
      ),
    );

    return Column(children: choices);
  }
}

/// WARNING: Tries to expand to fill its parent,
/// so its parent must have finite width.
///
/// (Built `Widget` is a `Column`)
class SlideEditor extends StatelessWidget {
  SlideEditor({
    super.key,
    required this.questionModel,
    required this.setQuestion,
    required this.addNewEmptyAnswer,
    required this.setCorrectAnswer,
    required this.setAnswer,
    required this.setSecondsDuration,
  }) {
    questionTextEditingController = TextEditingController(text: questionModel.question);
    multipleChoiceEditor = MultipleChoiceEditor(
      questionModel: questionModel,
      addNewEmptyAnswer: addNewEmptyAnswer,
      setCorrectAnswer: setCorrectAnswer,
      setAnswer: setAnswer,
    );
  }

  final Question questionModel;
  final void Function(String) setQuestion;
  final void Function() addNewEmptyAnswer;
  final void Function(int) setCorrectAnswer;
  final void Function(int, String) setAnswer;
  final void Function(int) setSecondsDuration;

  late final TextEditingController questionTextEditingController;
  late final MultipleChoiceEditor multipleChoiceEditor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextField(
          controller: questionTextEditingController,
          decoration: const InputDecoration(
            hintText: 'Question',
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
        multipleChoiceEditor,
      ],
    );
  }
}
