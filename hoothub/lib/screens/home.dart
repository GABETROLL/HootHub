// back-end
import 'package:hoothub/firebase/models/test.dart';
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
              testModel: Test(id: 'dlkfjz;ldsjg;lewakjf;lakewj;lkJSfd', name: 'Test Test!')
            ),
          ),
        );
      },
      child: const Text('Go to `MakeTest` screen with test Test!'),
    );
  }
}
