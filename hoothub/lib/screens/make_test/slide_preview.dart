// back-end
import 'package:hoothub/firebase/models/question.dart';
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
      Container(
        alignment: Alignment.centerLeft,
        color: primaryColor,
        child: Text(questionIndex.toString(), style: const TextStyle(color: white, fontSize: 40)),
      ),
      Text(question.question, style: const TextStyle(fontSize: 50)),
      questionImageWidget,
    ];

    return Column(children: children);
  }
}
