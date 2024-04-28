// back-end
import 'package:hoothub/firebase/models/test.dart';
import 'package:hoothub/firebase/models/question.dart';
// front-end
import 'package:flutter/material.dart';
import 'make_test/make_test.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => MakeTest(
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
      child: const Text('Go to `MakeTest` screen with test Test!'),
    );
  }
}
