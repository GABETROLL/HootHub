import 'package:hoothub/firebase/models/question.dart';
// front-end
import 'package:flutter/material.dart';

/// WARNING: I think this one also tries to expand to fill its parent,
/// so its parent must have finite width.
///
/// (Built `Widget` is a `Column`)
class MultipleChoiceEditor extends StatelessWidget {
  const MultipleChoiceEditor({
    super.key,
    required this.questionModel,
    required this.addNewEmptyAnswer,
    required this.setCorrectAnswer,
    required this.setAnswer,
  });

  final Question questionModel;
  final void Function() addNewEmptyAnswer;
  final void Function(int) setCorrectAnswer;
  final void Function(int, String) setAnswer;

  @override
  Widget build(BuildContext context) {
    final List<Widget> choices = <Widget>[];

    for (final (int index, String answer) in questionModel.answers.indexed) {
      final answerTextEditingController = TextEditingController(text: answer);

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
              // TODO: Make text save even when the user doesn't press ENTER or submits the text...
              onEditingComplete: () => setAnswer(index, answerTextEditingController.text),
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
  const SlideEditor({
    super.key,
    required this.questionModel,
    required this.setQuestion,
    required this.addNewEmptyAnswer,
    required this.setCorrectAnswer,
    required this.setAnswer,
    required this.setSecondsDuration,
  });

  final Question questionModel;
  final void Function(String) setQuestion;
  final void Function() addNewEmptyAnswer;
  final void Function(int) setCorrectAnswer;
  final void Function(int, String) setAnswer;
  final void Function(int) setSecondsDuration;

  @override
  Widget build(BuildContext context) {
    final questionTextEditingController = TextEditingController(text: questionModel.question);

    return Column(
      children: <Widget>[
        TextField(
          controller: questionTextEditingController,
          // TODO: Make text save even when the user doesn't press ENTER or submits the text...
          onEditingComplete: () {
            print('STOPPED EDITING QUESTION');
            setQuestion(questionTextEditingController.text);
          },
          decoration: const InputDecoration(
            hintText: 'Question',
          ),
        ),
        Slider(
          value: questionModel.secondsDuration as double,
          onChanged: (double selectedSecondsDuration) {
            setSecondsDuration(selectedSecondsDuration as int);
          },
          min: 1,
          max: 60,
          divisions: 60,
          label: questionModel.secondsDuration.toString(),
        ),
        MultipleChoiceEditor(
          questionModel: questionModel,
          addNewEmptyAnswer: () => addNewEmptyAnswer(),
          setCorrectAnswer: (int index) => setCorrectAnswer(index),
          setAnswer: (int index, String answer) => setAnswer(index, answer),
        ),
      ],
    );
  }
}
