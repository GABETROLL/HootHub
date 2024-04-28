import 'package:hoothub/firebase/models/question.dart';
// front-end
import 'package:flutter/material.dart';

class MultipleChoiceEditor extends StatelessWidget {
  const MultipleChoiceEditor({
    super.key,
    required this.questionModel,
    required this.setCorrectAnswer,
    required this.setAnswer,
  });

  final Question questionModel;
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
            onChanged: (bool? checked) => setCorrectAnswer(index),
          ),
          TextField(
            controller: answerTextEditingController,
            onSubmitted: (String answer) => setAnswer(index, answer),
            decoration: InputDecoration(
              hintText: 'Answer ${index + 1} ${index >= 2 ? '(Optional)' : ''}',
            ),
          ),
        ],
      );

      choices.add(choice);
    }

    return Column(children: choices);
  }
}

class SlideEditor extends StatelessWidget {
  const SlideEditor({
    super.key,
    required this.questionModel,
    required this.setQuestion,
  });

  final Question questionModel;
  final void Function(Question) setQuestion;

  @override
  Widget build(BuildContext context) {
    final questionTextEditingController = TextEditingController(text: questionModel.question);

    return Column(
      children: <Widget>[
        TextField(
          controller: questionTextEditingController,
          decoration: const InputDecoration(
            hintText: 'Question',
          ),
        ),
        MultipleChoiceEditor(
          questionModel: questionModel,
          setCorrectAnswer: (int index) => setQuestion(questionModel.setCorrectAnswer(index)),
          setAnswer: (int index, String answer) => setQuestion(questionModel.setAnswer(index, answer)),
        ),
      ],
    );
  }
}
