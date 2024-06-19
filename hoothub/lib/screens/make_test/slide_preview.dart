// front-end
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hoothub/screens/styles.dart';

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
  final Uint8List? questionImage;
  final void Function() deleteQuestion;

  @override
  Widget build(BuildContext context) {
    Uint8List? questionImageData = questionImage;

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
      (
        questionImageData != null 
        ? Image.memory(questionImageData)
        : Image.asset('default_image.png')
      ),
    ];

    return Column(children: children);
  }
}
