import 'package:hoothub/firebase/api/tests.dart';

import 'package:flutter/material.dart';
import 'package:hoothub/screens/view_tests/view_tests.dart';

class ViewUserTests extends StatelessWidget {
  const ViewUserTests({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  Widget build(BuildContext context) {
    return ViewTests(
      testsFutureForQuerySettings: (QuerySettings querySettings) {
        final TestQuery testQuery;

        final TestQuery testsByUserQuery = testsByUser(userId: userId);

        switch (querySettings.queryType) {
          case QueryType.date: {
            testQuery = testsByDateCreated(testsByUserQuery, limit: querySettings.limit, newest: !querySettings.reverse);
          }
          case QueryType.netUpvotes: {
            testQuery =  testsByNetUpvotes(testsByUserQuery, limit: querySettings.limit, most: !querySettings.reverse);
          }
          case QueryType.upvotes: {
            testQuery = testsByUpvotes(testsByUserQuery, limit: querySettings.limit, most: !querySettings.reverse);
          }
          case QueryType.downvotes: {
            testQuery = testsByDownvotes(testsByUserQuery, limit: querySettings.limit, most: !querySettings.reverse);
          }
        }

        return queryTests(testQuery);
      },
    );
  }
}
