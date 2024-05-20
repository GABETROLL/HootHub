import 'package:flutter/material.dart';
import 'package:hoothub/screens/styles.dart';

class Answer extends StatelessWidget {
  const Answer({super.key, required this.icon, required this.answer});

  final Icon icon;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        icon,
        Expanded(
          child: Text(answer, style: answerTextStyle),
        ),
      ],
    );
  }
}
