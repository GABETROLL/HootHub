// back-end
import 'package:hoothub/firebase/api/auth.dart';
import 'package:hoothub/firebase/models/user.dart';

import 'package:hoothub/firebase/models/test.dart';
import 'package:hoothub/firebase/models/question.dart';
// front-end
import 'package:flutter/material.dart';
import 'package:hoothub/screens/login.dart';
import 'view_test/view_test.dart';

/// For now, this widget only shows the user a test test.
///
/// If the user is not logged in, this widget should re-direct the user to the Login screen.
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  UserModel? _userModel;

  /// Tries to get the user's `UserModel` from `loggedInUser`,
  /// to then assign it to `_userModel`.
  ///
  /// If that result is null, it pushes the `Login` screen to the `Navigator`,
  /// and tries to get its route's result,
  /// to then assign it to `_userModel` instead, even if it's null.
  ///
  /// If the `Login` route fails, for some reason, this function
  /// displays a `SnackBar` with the error as a `String`.
  Future<void> checkLogin(BuildContext context) async {
    UserModel? userModel = await loggedInUser();

    if (userModel != null) {
      return setState(() {
        _userModel = userModel;
      });
    }

    if (!(context.mounted)) return;

    try {
      userModel = await Navigator.push<UserModel?>(
        context,
        MaterialPageRoute<UserModel?>(
          builder: (BuildContext context) => Login(),
        ),
      );

      setState(() {
        _userModel = userModel;
      });
    } catch (error) {
      if (!(context.mounted)) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error receiving login screen information: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userModel == null) {
      checkLogin(context);

      return const Scaffold(
        body: Center(
          child: Text('Loading...'),
        )
      );
    }

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
                    secondsDuration: 60
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
                    secondsDuration: 1,
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
