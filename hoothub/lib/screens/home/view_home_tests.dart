import 'package:hoothub/firebase/api/clients.dart';
import 'package:hoothub/firebase/api/tests.dart';

import 'package:flutter/material.dart';
import 'package:hoothub/screens/view_tests/view_tests.dart';

class ViewHomeTests extends StatelessWidget {
  const ViewHomeTests({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewTests(
      testsFutureForQuerySettings: (QuerySettings querySettings, String name) {
        TestQuery testQuery = testsCollection;

        if (name.isNotEmpty) {
          testQuery = testsByName(testQuery, name: name);
        }

        switch (querySettings.queryType) {
          case QueryType.date: {
            testQuery = testsByDateCreated(testQuery, limit: querySettings.limit, newest: !querySettings.reverse);
          }
          case QueryType.netUpvotes: {
            testQuery =  testsByNetUpvotes(testQuery, limit: querySettings.limit, most: !querySettings.reverse);
          }
          case QueryType.upvotes: {
            testQuery = testsByUpvotes(testQuery, limit: querySettings.limit, most: !querySettings.reverse);
          }
          case QueryType.downvotes: {
            testQuery = testsByDownvotes(testQuery, limit: querySettings.limit, most: !querySettings.reverse);
          }
        }

        return queryTests(testQuery);
      },
    );
  }
}
