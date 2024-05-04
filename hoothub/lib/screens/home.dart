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
                userId: 'DsS1ZzDNxqci3NLEsW5WQJIiG422',
                questions: <Question>[
                  Question(
                    question: 'Simplify `sqrt(9)`:',
                    answers: ['sqrt(3)', '3', 'sqrt(9)', '6'],
                    correctAnswer: 1,
                    secondsDuration: 61
                  ),
                  Question(
                    question: 'Simplify `sqrt(27)`:',
                    answers: ['9', '3 * sqrt(3)', '3', 'sqrt(3)'],
                    correctAnswer: 1,
                    secondsDuration: 6,
                  ),
                  Question(
                    question: 'Simplify `sqrt(10)`:',
                    answers: ['sqrt(10)', 'sqrt(2)sqrt(5)', '3', 'cbrt(100)'],
                    correctAnswer: 0,
                    secondsDuration: -1
                  ),
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
