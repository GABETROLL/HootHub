import 'package:hoothub/firebase/api/images.dart';
import 'package:hoothub/firebase/models/question.dart';

import 'package:flutter/material.dart';
import 'package:hoothub/screens/widgets/info_downloader.dart';

class SlidePreview extends StatelessWidget {
  const SlidePreview({
    super.key,
    required this.testId,
    required this.questionIndex,
    required this.question,
  });

  final String? testId;
  final int questionIndex;
  final Question question;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[
      Align(
        alignment: Alignment.centerLeft,
        child: Text(questionIndex.toString(), style: const TextStyle(fontSize: 40)),
      ),
      Text(question.question, style: const TextStyle(fontSize: 50)),
    ];

    if (testId != null) {
      children.add(
        InfoDownloader(
          downloadName: "Image of question #$questionIndex of test $testId",
          downloadInfo: () => questionImageDownloadUrl(testId!, questionIndex),
          buildSuccess: (BuildContext context, String imageUrl) {
            return Image.network(imageUrl, height: 100);
          },
          buildLoading: (BuildContext context) {
            return Image.asset('default_image.png', height: 100);
          },
        ),
      );
    }

    return Column(children: children);
  }
}
