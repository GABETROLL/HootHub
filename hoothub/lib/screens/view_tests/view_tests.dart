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

class SearchMenu extends StatefulWidget {
  const SearchMenu({
    super.key,
    required this.initialQuerySettings,
    required this.nameEditingController,
    required this.search,
  });

  final QuerySettings initialQuerySettings;
  final TextEditingController nameEditingController;
  final void Function(QuerySettings querySettings) search;

  @override
  State<SearchMenu> createState() => _SearchMenuState();
}

class _SearchMenuState extends State<SearchMenu> {
  late final QuerySettings _querySettings;

  @override
  void initState() {
    super.initState();
    _querySettings = widget.initialQuerySettings;
  }

  @override
  Widget build(BuildContext context) {
    const optionNameFontSize = TextStyle(fontSize: smallHeadingFontSize);

    return Row(
      children: <Widget>[
        DropdownMenu<QueryType>(
          label: const Text('Order by'),
          leadingIcon: const Icon(Icons.search),
          initialSelection: _querySettings.queryType,
          onSelected: (QueryType? queryType) {
            if (queryType == null) return;
            
            setState(() {
              _querySettings.queryType = queryType;
            });
          },
          dropdownMenuEntries: List<DropdownMenuEntry<QueryType>>.from(
            QueryType.values.map<DropdownMenuEntry<QueryType>>(
              (QueryType queryType) => DropdownMenuEntry<QueryType>(
                value: queryType,
                label: queryType.label,
                leadingIcon: queryType.leadingIcon,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Text('Reverse order', style: optionNameFontSize),
        Checkbox(
          semanticLabel: 'Reverse order',
          value: _querySettings.reverse,
          onChanged: (bool? reverse) {
            if (reverse == null) return;

            setState(() {
              _querySettings.reverse = reverse;
            });
          },
        ),
        const SizedBox(width: 10),
        // TODO: IMPLEMENT LIMIT SETTER
        const Text("Title:", style: optionNameFontSize),
        const SizedBox(width: 10),
        Expanded(child: TextField(controller: widget.nameEditingController)),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () => widget.search(_querySettings),
          child: const Text("Search"),
        ),
      ],
    );
  }
}

/// A UI for viewing different categories of tests from the Firestore.
///
///  MEANT TO BE WRAPPED BY `Home`.
/// IT'S NOT MEANT TO BE USED DIRECTLY IN A ROUTE.
class ViewTests extends StatefulWidget {
  const ViewTests({
    super.key,
    required this.testsFutureForQuerySettings,
  });

  final Future<List<Test?>> Function(QuerySettings querySettings, String name) testsFutureForQuerySettings;

  @override
  State<ViewTests> createState() => _ViewTestsState();
}

class _ViewTestsState extends State<ViewTests> {
  final QuerySettings initialQuerySettings = QuerySettings(
    limit: 100,
    queryType: QueryType.date,
    reverse: false,
  );
  final TextEditingController _nameEditingController = TextEditingController();
  late Future<List<Test?>> _tests;

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
    _tests = widget.testsFutureForQuerySettings(initialQuerySettings, _nameEditingController.text);
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

        return Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Column(
            children: [
              SearchMenu(
                initialQuerySettings: initialQuerySettings,
                nameEditingController: _nameEditingController,
                search: (QuerySettings querySettings) => setState(() {
                  _tests = widget.testsFutureForQuerySettings(querySettings, _nameEditingController.text);
                }),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: tests.length,
                  itemBuilder: (BuildContext context, int index) {
                    Test? testModel = tests[index];
                    if (testModel == null) {
                      return const Text('Test not found!');
                    }

                    Color testCardColor = themeColors[index % themeColors.length];

                    return TestCard(
                      testModel: testModel,
                      asyncSetTestModel: (Test newTestModel) => asyncRefreshTest(tests, index, newTestModel),
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
                          asyncRefreshTest(tests, index, refreshedTest);
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
                          asyncRefreshTest(tests, index, refreshedTest);
                        }
                      },
                      delete: () async {
                        // remove remotely

                        String? testIdPromoted = testModel.id;

                        final String status;

                        if (testIdPromoted == null) {
                          status = "Failed to delete test...";
                        } else {
                          status = await deleteTestWithId(testIdPromoted);
                        }

                        // show deleting status

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(status)),
                          );
                        }

                        // remove locally

                        if (mounted) {
                          setState(() {
                            tests.removeAt(index);
                          });
                        }
                      },
                      color: testCardColor
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      buildError: (BuildContext context, Object error) {
        print('Error loading tests: $error');
        return const Center(child: Text("There was an error querying the tests!"));
      },
    );
  }
}
