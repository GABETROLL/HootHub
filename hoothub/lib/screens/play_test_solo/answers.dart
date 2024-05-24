import 'package:flutter/material.dart';
import 'package:hoothub/firebase/models/question.dart';
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
    final List<Widget> choices = <Widget>[];

    for (final (int index, String answer) in questionModel.answers.indexed) {
      choices.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: answerMaker(context, index, answer),
        ),
      );
    }

    if (nextButton != null) {
      try {
        choices.add(nextButton!);
      } catch (error) {
        // Null value accessed
      }
    }

    return Column(children: choices);
  }
}
