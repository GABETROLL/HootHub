// front-end
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hoothub/screens/styles.dart';
import 'package:hoothub/screens/widgets/info_downloader.dart';

class SlidePreview extends StatelessWidget {
  const SlidePreview({
    super.key,
    required this.questionIndex,
    required this.question,
    required this.questionImage,
    required this.deleteQuestion,
  });

  final int questionIndex;
  final String question;
  final Future<Uint8List?> questionImage;
  final void Function() deleteQuestion;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[
      Container(
        alignment: Alignment.centerLeft,
        color: primaryColor,
        // TODO: Or use `Card` for the theme colors!!!
        child: Row(
          children: <Widget>[
            IconButton(
              color: white,
              onPressed: deleteQuestion,
              icon: const Icon(Icons.delete),
            ),
            Expanded(
              child: Text(
                questionIndex.toString(),
                style: const TextStyle(color: white, fontSize: 40),
              ),
            ),
          ],
        ),
      ),
      Text(question, style: const TextStyle(fontSize: 50)),
      InfoDownloader<Uint8List>(
        downloadInfo: () => questionImage,
        builder: (BuildContext context, Uint8List? result, bool downloaded) {
          Image questionImageWidget = Image.asset('default_image.png');

          if (result != null) {
            questionImageWidget = Image.memory(result);
          }

          return questionImageWidget;
        },
        buildError: (BuildContext context, Object error) {
          return Text("Error loading and displaying question #$questionIndex's image: $error");
        },
      ),
    ];

    return Column(children: children);
  }
}
