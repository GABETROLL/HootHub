// back-end
import 'package:hoothub/firebase/models/test.dart';
import 'package:hoothub/firebase/models/question.dart';
// front-end
import 'package:flutter/material.dart';
import 'view_test/view_test.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => ViewTest(
              testModel: Test(
                name: 'Test Test!',
                questions: <Question>[
                  Question(question: 'What is `1 + 1`?', answers: ['0', '1', '2', '3'], correctAnswer: 2),
                ],
              ),
            ),
          ),
        );
      },
      child: const Text('Go to `ViewTest` screen with test Test!'),
    );
  }
}
