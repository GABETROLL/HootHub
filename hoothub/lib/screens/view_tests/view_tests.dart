// back-end
import 'package:hoothub/firebase/models/test.dart';
import 'package:hoothub/firebase/api/tests.dart';
// front-end
import 'package:flutter/material.dart';
import 'package:hoothub/screens/widgets/info_downloader.dart';
import 'test_card.dart';

enum QueryType {
  date(label: 'Date', leadingIcon: Icon(Icons.calendar_month));

  const QueryType({
    required this.label,
    required this.leadingIcon,
  });

  final String label;
  final Widget leadingIcon;
}

/// A UI for viewing different categories of tests from the Firestore.
///
///  MEANT TO BE WRAPPED BY `Home`.
/// IT'S NOT MEANT TO BE USED DIRECTLY IN A ROUTE.
class ViewTests extends StatefulWidget {
  ViewTests({
    super.key,
  });

  final queryTypeEntries = List<DropdownMenuEntry<QueryType>>.from(
    QueryType.values.map<DropdownMenuEntry<QueryType>>(
      (QueryType queryType) => DropdownMenuEntry<QueryType>(
        value: queryType,
        label: queryType.label,
        leadingIcon: queryType.leadingIcon,
      ),
    ),
  );

  final orderByEntries = <DropdownMenuEntry<bool>>[
    const DropdownMenuEntry<bool>(
      value: true,
      label: 'Newest First',
      leadingIcon: Icon(Icons.arrow_downward),
    ),
    const DropdownMenuEntry(
      value: false,
      label: 'Oldest First',
      leadingIcon: Icon(Icons.arrow_upward),
    ),
  ];

  @override
  State<ViewTests> createState() => _ViewTestsState();
}

class _ViewTestsState extends State<ViewTests> {
  int _limit = 100;
  bool _newest = true;
  QueryType _queryType = QueryType.date;

  static const testNotFoundCard = Text('Test not found!');

  Widget buildSearchMenu(BuildContext context) {
    return Row(
      children: <Widget>[
        DropdownMenu<QueryType>(
          label: const Text('Search by'),
          leadingIcon: const Icon(Icons.search),
          initialSelection: _queryType,
          onSelected: (QueryType? queryType) {
            if (queryType != null) {
              setState(() {
                _queryType = queryType;
              });
            }
          },
          dropdownMenuEntries: widget.queryTypeEntries,
        ),
        DropdownMenu<bool>(
          label: const Text('Order by'),
          leadingIcon: const Icon(Icons.compare_arrows),
          initialSelection: _newest,
          onSelected: (bool? newest) {
            if (newest != null) {
              setState(() {
                _newest = newest;
              });
            }
          },
          dropdownMenuEntries: widget.orderByEntries,
        ),
      ],
    );
  }

  TestQuery query() {
    switch (_queryType) {
      case QueryType.date: {
        return () => testsByDateCreated(limit: _limit, newest: _newest);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InfoDownloader<List<Test?>>(
        downloadName: 'Tests',
        downloadInfo: () => query()(),
        buildSuccess: (BuildContext context, List<Test?> tests) {
          // TODO: MAYBE USE SOME TYPE OF STREAM-BUILT LISTVIEW?

          return ListView.builder(
            itemCount: tests.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return buildSearchMenu(context);
              }

              Test? testForCard = tests[index - 1];
              if (testForCard != null) {
                try {
                  return TestCard(testModel: testForCard);
                } catch (error) {
                  return testNotFoundCard;
                }

              } else {
                return testNotFoundCard;
              }
            }
          );
        },
        buildLoading: (BuildContext context) {
          return const Center(
            child: Text('Loading tests...', style: TextStyle(fontSize: 100)),
          );
        },
      ),
    );
  }
}
