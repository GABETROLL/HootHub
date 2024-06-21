import 'package:hoothub/firebase/models/test_result.dart';
import 'package:flutter/material.dart';

class TestSoloResults extends StatelessWidget {
  const TestSoloResults({
    super.key,
    required this.testResult,
    required this.questionsAmount,
    required this.exit,
  });

  final TestResult testResult;
  final int questionsAmount;
  final void Function() exit;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text(
          'Final Score',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 80),
        ),
        Text(
          testResult.score.toString(),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 120),
        ),
        const Text(
          'Questions answered correct:',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 60),
        ),
        Text(
          '${testResult.correctAnswers}/$questionsAmount',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 90),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: exit,
              child: const Text('Back to Test Card'),
            ),
          ],
        ),
      ],
    );
  }
}
