import 'package:hoothub/firebase/models/question.dart';
// front-end
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hoothub/screens/make_test/image_editor.dart';

/// WARNING: Tries to expand to fill its parent,
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
              controller: answerTextEditingController,
              // TODO: Make text save even when the user doesn't press ENTER or submits the text...
              onEditingComplete: () => setAnswer(index, answerTextEditingController.text),
              style: const TextStyle(fontSize: 75),
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
    required this.questionImage,
    required this.asyncSetQuestionImage,
    required this.asyncOnImageNotRecieved,
    required this.addNewEmptyAnswer,
    required this.setCorrectAnswer,
    required this.setAnswer,
    required this.setSecondsDuration,
  });

  final Question questionModel;
  final void Function(String) setQuestion;
  final Uint8List? questionImage;
  final void Function(Uint8List) asyncSetQuestionImage;
  final void Function() asyncOnImageNotRecieved;
  final void Function() addNewEmptyAnswer;
  final void Function(int) setCorrectAnswer;
  final void Function(int, String) setAnswer;
  final void Function(int) setSecondsDuration;

  @override
  Widget build(BuildContext context) {
    final questionTextEditingController = TextEditingController(text: questionModel.question);

    return ListView(
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
        Container(
          alignment: Alignment.center,
          constraints: const BoxConstraints(maxWidth: 500),
          child: ImageEditor(
            imageData: questionImage,
            asyncOnChange: asyncSetQuestionImage,
            asyncOnImageNotRecieved: asyncOnImageNotRecieved,
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
          addNewEmptyAnswer: () => addNewEmptyAnswer(),
          setCorrectAnswer: (int index) => setCorrectAnswer(index),
          setAnswer: (int index, String answer) => setAnswer(index, answer),
        ),
      ],
    );
  }
}
