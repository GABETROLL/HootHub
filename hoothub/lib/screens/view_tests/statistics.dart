// back-end
import 'package:hoothub/firebase/models/test.dart';
// front-end
import 'package:flutter/material.dart';
import 'package:hoothub/screens/styles.dart';

class TestStatistics extends StatelessWidget {
  const TestStatistics({super.key, required this.testModel});

  final Test testModel;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: whiteOnPurpleTheme,
      child: Builder(
        builder: (BuildContext context) {
          final ThemeData themeData = Theme.of(context);

          final TextStyle textStyle = TextStyle(color: themeData.primaryColor);

          return ExpansionTile(
            title: const Text("Statistics", style: TextStyle(fontSize: smallHeadingFontSize),),
            children: <Widget>[
              Table(
                children: <TableRow>[
                  TableRow(
                    children: <Text>[
                      Text("Average Questions Score", style: textStyle),
                      Text("Average Points Score", style: textStyle),
                    ],
                  ),
                  TableRow(
                    children: <Text>[
                      Text(
                        "${testModel.netQuestionsAnsweredCorrect / testModel.userResults.length} / ${testModel.questions.length}",
                        style: textStyle
                      ),
                      Text("${testModel.netScore / testModel.userResults.length}", style: textStyle),
                    ],
                  ),
                ],
              ),
              // best user score
              // best user questions
              // BEST USER TIME???
            ],
          );
        }
      ),
    );
  }
}
