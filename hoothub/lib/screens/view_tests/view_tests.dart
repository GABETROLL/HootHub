// back-end
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hoothub/firebase/models/test.dart';
import 'package:hoothub/firebase/api/tests.dart';
// front-end
import 'package:flutter/material.dart';
import 'test_card.dart';

enum QueryType {
  date(label: 'Date', leadingIcon: Icon(Icons.calendar_month)),
  netUpvotes(label: 'Net Upvotes', leadingIcon: Icon(Icons.arrow_upward)),
  upvotes(label: 'Upvotes', leadingIcon: Icon(Icons.arrow_upward)),
  downvotes(label: 'Downvotes', leadingIcon: Icon(Icons.arrow_downward));

  const QueryType({
    required this.label,
    required this.leadingIcon,
  });

  final String label;
  final Widget leadingIcon;
}

class TestsSearchMenu<T> extends StatelessWidget {
  const TestsSearchMenu({
    super.key,
    required this.queryOption,
    required this.setQueryOption,
    required this.queryOptionEntries,
  });

  final T queryOption;
  final void Function(T) setQueryOption;
  final List<DropdownMenuEntry<T>> queryOptionEntries;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<T>(
      label: const Text('Search by'),
      leadingIcon: const Icon(Icons.search),
      initialSelection: queryOption,
      onSelected: (T? queryType) {
        if (queryType != null) {
          setQueryOption(queryType);
        }
      },
      dropdownMenuEntries: queryOptionEntries,
    );
  }
}

class SearchMenu extends StatelessWidget {
  const SearchMenu({
    super.key,
    required this.queryType,
    required this.reverse,
    required this.queryTypeEntries,
    required this.setQueryType,
    required this.setReverse,
  });

  final QueryType queryType;
  final bool reverse;
  final List<DropdownMenuEntry<QueryType>> queryTypeEntries;
  final void Function(QueryType) setQueryType;
  final void Function(bool) setReverse;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        TestsSearchMenu<QueryType>(
          queryOption: queryType,
          setQueryOption: setQueryType,
          queryOptionEntries: queryTypeEntries,
        ),
        Checkbox(
          semanticLabel: 'Reverse order',
          value: reverse,
          onChanged: (bool? reverse) {
            if (reverse == null) return;
            setReverse(reverse);
          },
        ),
      ],
    );
  }
}

class QuerySettings {
  QuerySettings({
    required this.limit,
    required this.queryType,
    required this.reverse,
  });

  int limit;
  QueryType queryType;
  bool reverse;
}

/// A UI for viewing different categories of tests from the Firestore.
///
///  MEANT TO BE WRAPPED BY `Home`.
/// IT'S NOT MEANT TO BE USED DIRECTLY IN A ROUTE.
class ViewTests extends StatefulWidget {
  const ViewTests({super.key});

  @override
  State<ViewTests> createState() => _ViewTestsState();
}

class _ViewTestsState extends State<ViewTests> {
  Widget? _child;

  Widget buildWithQuery({
    required QuerySettings querySettings,
    required List<Test?> tests,
  }) {
    return ListView.builder(
      itemCount: tests.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return SearchMenu(
            queryType: querySettings.queryType,
            reverse: querySettings.reverse,
            queryTypeEntries: List<DropdownMenuEntry<QueryType>>.from(
              QueryType.values.map<DropdownMenuEntry<QueryType>>(
                (QueryType queryType) => DropdownMenuEntry<QueryType>(
                  value: queryType,
                  label: queryType.label,
                  leadingIcon: queryType.leadingIcon,
                ),
              ),
            ),
            setQueryType: (QueryType queryType) => _downloadTestsAndReplaceChild(
              querySettings: QuerySettings(
                limit: querySettings.limit,
                queryType: queryType,
                reverse: querySettings.reverse,
              )
            ),
            setReverse: (bool reverse) => _downloadTestsAndReplaceChild(
              querySettings: QuerySettings(
                limit: querySettings.limit,
                queryType: querySettings.queryType,
                reverse: reverse,
              ),
            ),
          );
        }

        Test? test = tests[index - 1];
         if (test == null) {
          return const Text('Test not found!');
        }

        return TestCard(testModel: test);
      },
    );
  }

  Future<void> _downloadTestsAndReplaceChild({required QuerySettings querySettings}) async {
    List<Test?> tests = <Test?>[];

    TestQuery testQuery;

    switch (querySettings.queryType) {
      case QueryType.date: {
        testQuery = () => testsByDateCreated(limit: querySettings.limit, newest: !querySettings.reverse);
      }
      case QueryType.netUpvotes: {
        testQuery = () => testsByNetUpvotes(limit: querySettings.limit, most: !querySettings.reverse);
      }
      case QueryType.upvotes: {
        testQuery = () => testsByUpvotes(limit: querySettings.limit, most: !querySettings.reverse);
      }
      case QueryType.downvotes: {
        testQuery = () => testsByUpvotes(limit: querySettings.limit, most: !querySettings.reverse);
      }
    }

    try {
      tests = await testQuery();
    } on FirebaseException catch (error) {
      print('Error downloading tests: ${error.message ?? error.code}');
    } catch (error) {
      print('Error downloading tests: $error');
    }

    if (!mounted) return;

    setState(() {
      _child = buildWithQuery(querySettings: querySettings, tests: tests);
    });
  }

  @override
  Widget build(BuildContext context) {
    QuerySettings initialQuerySettings = QuerySettings(
      limit: 100,
      queryType: QueryType.date,
      reverse: true,
    );

    if (_child == null) {
      _downloadTestsAndReplaceChild(querySettings: initialQuerySettings);
      return buildWithQuery(querySettings: initialQuerySettings, tests: <Test?>[]);
    }
    try {
      return _child!;
    } catch (error) {
      print('Error reading `ViewTests` child: $error');
      return buildWithQuery(querySettings: initialQuerySettings, tests: <Test?>[]);
    }
  }
}
