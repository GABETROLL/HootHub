// back-end
import 'package:hoothub/firebase/models/test.dart';
import 'package:hoothub/firebase/api/tests.dart';
// front-end
import 'package:flutter/material.dart';
import 'package:hoothub/screens/widgets/info_downloader.dart';
import 'package:hoothub/screens/styles.dart';
import 'package:hoothub/screens/play_test_solo/play_test_solo.dart';
import 'package:hoothub/screens/make_test/make_test.dart';
import 'test_card.dart';


enum QueryType {
  date(label: 'Newest', leadingIcon: Icon(Icons.calendar_month)),
  netUpvotes(label: 'Most Net Upvotes', leadingIcon: Icon(Icons.arrow_upward)),
  upvotes(label: 'Most Upvotes', leadingIcon: Icon(Icons.arrow_upward)),
  downvotes(label: 'Most Downvotes', leadingIcon: Icon(Icons.arrow_downward));

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
      label: const Text('Order by'),
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
    required this.querySettings,
    required this.setQueryType,
    required this.setReverse,
    required this.setLimit,
  });

  final QuerySettings querySettings;
  final void Function(QueryType) setQueryType;
  final void Function(bool) setReverse;
  final void Function(int) setLimit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        TestsSearchMenu<QueryType>(
          queryOption: querySettings.queryType,
          setQueryOption: setQueryType,
          queryOptionEntries: List<DropdownMenuEntry<QueryType>>.from(
            QueryType.values.map<DropdownMenuEntry<QueryType>>(
              (QueryType queryType) => DropdownMenuEntry<QueryType>(
                value: queryType,
                label: queryType.label,
                leadingIcon: queryType.leadingIcon,
              ),
            ),
          ),
        ),
        Checkbox(
          semanticLabel: 'Reverse order',
          value: querySettings.reverse,
          onChanged: (bool? reverse) {
            if (reverse == null) return;
            setReverse(reverse);
          },
        ),
        const Text('Reverse order'),
        // TODO: IMPLEMENT LIMIT SETTER
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
  final QuerySettings _querySettings = QuerySettings(
    limit: 100,
    queryType: QueryType.date,
    reverse: false,
  );
  late Future<List<Test?>> _tests;

  Future<List<Test?>> testsFutureForQuerySettings() {
    switch (_querySettings.queryType) {
      case QueryType.date: {
        return testsByDateCreated(limit: _querySettings.limit, newest: !_querySettings.reverse);
      }
      case QueryType.netUpvotes: {
        return testsByNetUpvotes(limit: _querySettings.limit, most: !_querySettings.reverse);
      }
      case QueryType.upvotes: {
        return testsByUpvotes(limit: _querySettings.limit, most: !_querySettings.reverse);
      }
      case QueryType.downvotes: {
        return testsByDownvotes(limit: _querySettings.limit, most: !_querySettings.reverse);
      }
    }
  }

  /// refresh test in `_tests` after it has been played,
  /// so that the player can see their scores refresh
  /// immediately when returning
  ///
  /// `tests` SHOULD BE A REFERENCE TO `_tests`, AFTER IT'S COMPLETED.
  /// `newTestModel` will be, for example, the `Test` popped from `PlayTestSolo` AND `MakeTest`.
  void asyncRefreshTest(List<Test?> tests, int testIndex, Test newTestModel) {
    if (!mounted) return;

    setState(() {
      tests[testIndex] = newTestModel;
    });
  }

  @override
  void initState() {
    super.initState();
    _tests = testsFutureForQuerySettings();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: ADD DELETE BUTTON TO DELETE TESTS BELONGING TO THE CURRENT USER
    return InfoDownloader<List<Test?>>(
      key: UniqueKey(),
      downloadInfo: () => _tests,
      builder: (BuildContext context, List<Test?>? tests, bool downloaded) {
        if (tests == null) {
          return const Center(child: Text('Loading tests...'));
        }

        return ListView.builder(
          itemCount: tests.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return SearchMenu(
                querySettings: _querySettings,
                setQueryType: (QueryType queryType) => setState(() {
                  _querySettings.queryType = queryType;
                  _tests = testsFutureForQuerySettings();
                }),
                setReverse: (bool reverse) => setState(() {
                  _querySettings.reverse = reverse;
                  _tests = testsFutureForQuerySettings();
                }),
                setLimit: (int limit) => setState(() {
                  _querySettings.limit = limit;
                  _tests = testsFutureForQuerySettings();
                }),
              );
            }

            int testIndex = index - 1;

            Test? testModel = tests[testIndex];
            if (testModel == null) {
              return const Text('Test not found!');
            }

            Color testCardColor = themeColors[testIndex % themeColors.length];

            return TestCard(
              testModel: testModel,
              asyncSetTestModel: (Test newTestModel) => asyncRefreshTest(tests, testIndex, newTestModel),
              playSolo: () async {
                final Test? refreshedTest = await Navigator.push<Test>(
                  context,
                  MaterialPageRoute<Test>(
                    builder: (BuildContext context) => PlayTestSolo(
                      testModel: testModel,
                    ),
                  ),
                );

                // `refreshedTest` IS NULL, WHEN THE POPPED PAGE
                // HAS NO CHANGES TO MAKE.

                if (refreshedTest != null) {
                  asyncRefreshTest(tests, testIndex, refreshedTest);
                }
              },
              edit: () async {
                final Test? refreshedTest = await Navigator.push<Test>(
                  context,
                  MaterialPageRoute<Test>(
                    builder: (BuildContext context) => MakeTest(
                      testModel: testModel,
                    ),
                  ),
                );

                // `refreshedTest` IS NULL, WHEN THE POPPED PAGE
                // HAS NO CHANGES TO MAKE.

                if (refreshedTest != null) {
                  asyncRefreshTest(tests, testIndex, refreshedTest);
                }
              },
              color: testCardColor
            );
          },
        );
      },
      buildError: (BuildContext context, Object error) {
        return Center(child: Text('Error loading tests: $error'));
      },
    );
  }
}
