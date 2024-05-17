// back-end
import 'package:hoothub/firebase/models/test.dart';
import 'package:hoothub/firebase/api/tests.dart';
// front-end
import 'package:flutter/material.dart';
import 'test_card.dart';

/// A UI for viewing different categories of tests from the Firestore.
///
/// Doesn't have its own `Scaffold` wrapping its contents,
/// AND IT'S MEANT TO BE WRAPPED BY `Home`, OR BY A WIDGET THAT IS.
/// IT'S NOT MEANT TO BE USED DIRECTLY IN A ROUTE.
class ViewTests extends StatefulWidget {
  const ViewTests({
    super.key,
    required this.query,
  });

  final TestQuery query;

  @override
  State<ViewTests> createState() => _ViewTestsState();
}

class _ViewTestsState extends State<ViewTests> {
  List<Widget>? _testCards;
  String? _testQueryError;

  Future<void> _fetchTests(BuildContext context) async {
    Iterable<Test?> tests;

    try {
      tests = await widget.query();
    } catch (error) {
      return setState(() {
        _testQueryError = error.toString();
      });
    }

    print('TESTS: $tests');

    List<Widget> testCards = [];

    for (Test? test in tests) {
      // TODO: HANDLE TEST THROWING
      if (test == null) {
        testCards.add(const Text('Could not find test.'));
        continue;
      }

      testCards.add(TestCard(testModel: test));
    }

    setState(() {
      _testCards = testCards;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_testCards == null && _testQueryError == null) {
      _fetchTests(context);

      return const Text('Searching for tests...');
    } else if (_testQueryError != null) {
      return Center(
        child: Text('Error searching for tests: $_testQueryError'),
      );
    }

    // THIS BRANCH SHOULD HAVE `_testCards != null`!!!
    //
    // Cannot promote `_testCards` to non-nullable, because it's a non-final field.
    // So, I just catch the error produced when accessing `_testCards` null,
    // and display that text.
    try {
      return ListView(children: _testCards!);
    } catch (error) {
      return Center(
        child: Text('Error displaying tests: $error'),
      );
    }
  }
}
