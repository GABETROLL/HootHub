import 'package:hoothub/firebase/models/test_result.dart';
import 'package:flutter/material.dart';

class TestSoloResults extends StatelessWidget {
  const TestSoloResults({
    super.key,
    required this.testResult,
    required this.questionsAmount,
  });

  final TestResult testResult;
  final int questionsAmount;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        const Text(
          'Final Score',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 100),
        ),
        Text(
          testResult.score.toString(),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 150),
        ),
        const Text(
          'Questions answered correct:',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 75),
        ),
        Text(
          '${testResult.correctAnswers}/$questionsAmount',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 65),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Back to Test Card'),
            ),
          ],
        ),
      ],
    );
  }
}
