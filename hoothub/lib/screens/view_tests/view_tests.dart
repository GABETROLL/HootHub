// back-end
import 'package:hoothub/firebase/models/user.dart';
import 'package:hoothub/firebase/models/test.dart';
import 'package:hoothub/firebase/api/auth.dart';
import 'package:hoothub/firebase/api/tests.dart';
// front-end
import 'package:flutter/material.dart';
import 'package:hoothub/widgets/test_card.dart';

/// A UI for viewing different categories of tests from the Firestore.
///
/// Doesn't have its own `Scaffold` wrapping its contents,
/// AND IT'S MEANT TO BE WRAPPED BY `Home`, OR BY A WIDGET THAT IS.
/// IT'S NOT MEANT TO BE USED DIRECTLY IN A ROUTE.
class ViewTests extends StatefulWidget {
  const ViewTests({super.key});

  @override
  State<ViewTests> createState() => _ViewTestsState();
}

class _ViewTestsState extends State<ViewTests> {
  List<Widget>? _testCards;
  bool _searchedForTests = false;

  Future<void> _fetchTests() async {
    Iterable<Test?> tests;

    try {
      tests = await testsByDateCreated(limit: 100, newest: true);
    } catch (error) {
      // If even getting the tests goes wrong,
      // just indicate to the `build` method that the tests
      // were searched, so that it can tell the user that
      // something went wrong.
      setState(() {
        _searchedForTests = true;
      });
      return;
    }

    List<Widget> testCards = [];

    for (Test? test in tests) {
      // TODO: HANDLE TEST THROWING
      if (test == null) {
        testCards.add(const Text('Could not find test.'));
        continue;
      }

      UserModel? testAuthor;

      if (test.userId != null) {
        try {
          testAuthor = await userWithId(test.userId!);
        } catch (error) {
          // continue to next statement
        }
      }

      testCards.add(
        TestCard(
          testName: test.name,
          username: testAuthor?.username ?? '...',
        ),
      );
    }

    setState(() {
      _searchedForTests = true;
      _testCards = testCards;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_searchedForTests) {
      _fetchTests();

      return const Text('Searching for tests...');
    }

    // Cannot promote `_testCards` to non-nullable, because it's a non-final field.
    // So, I just catch the error produced when accessing `_testCards` null,
    // and display that text.
    try {
      return ListView(
        children: _testCards!,
      );
    } catch (error) {
      return const Center(child: Text('Something went wrong searching for tests...'));
    }
  }
}
