// back-end
import 'package:hoothub/firebase/models/question.dart';
// front-end
import 'package:flutter/material.dart';
import 'package:hoothub/screens/styles.dart';

class Answer extends StatelessWidget {
  const Answer({
    super.key,
    required this.icon,
    required this.answer,
    required this.color,
  });

  final Icon icon;
  final String answer;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: Row(
        children: <Widget>[
          icon,
          Expanded(
            child: Text(answer, style: answerTextStyle),
          ),
        ],
      ),
    );
  }
}

class Answers extends StatelessWidget {
  const Answers({
    super.key,
    required this.questionModel,
    required this.answerMaker,
    this.nextButton,
  });

  final Question questionModel;
  final Widget Function(BuildContext context, int index, String answer) answerMaker;
  final Widget? nextButton;

  @override
  Widget build(BuildContext context) {
    Widget styledAnswerMaker(Widget answer) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: answer,
        ),
      );
    }

    final List<Widget> choices = <Widget>[];

    for (int index = 0; index < questionModel.answers.length; index += 2) {
      final int a = index;
      final int b = index + 1;

      List<Widget> answers = [
        styledAnswerMaker(
          answerMaker(context, a, questionModel.answers[a])
        ),
      ];

      if (b < questionModel.answers.length) {
        answers.add(
          styledAnswerMaker(
            answerMaker(context, b, questionModel.answers[b]),
          ),
        );
      }

      choices.add(Row(children: answers));
    }

    if (nextButton != null) {
      try {
        choices.add(nextButton!);
      } catch (error) {
        // Null value accessed, probably.
      }
    }

    return Column(children: choices);
  }
}
