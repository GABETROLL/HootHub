import 'package:hoothub/firebase/models/question.dart';

import 'dart:typed_data';
import 'package:flutter/material.dart';

class SlidePreview extends StatelessWidget {
  const SlidePreview({
    super.key,
    required this.questionIndex,
    required this.question,
    required this.questionImage,
  });

  final int questionIndex;
  final Question question;
  final Uint8List? questionImage;

  @override
  Widget build(BuildContext context) {
    Image questionImageWidget = Image.asset('default_image.png');

    try {
      questionImageWidget = Image.memory(questionImage!);
    } catch (error) {
      print("`SlidePreview`: Error reading question #$questionIndex's Uint8List image: $error");
    }

    final List<Widget> children = <Widget>[
      Align(
        alignment: Alignment.centerLeft,
        child: Text(questionIndex.toString(), style: const TextStyle(fontSize: 40)),
      ),
      Text(question.question, style: const TextStyle(fontSize: 50)),
      questionImageWidget,
    ];

    return Column(children: children);
  }
}
