// back-end
import 'dart:typed_data';
import 'package:hoothub/firebase/api/images.dart';
import 'package:hoothub/firebase/models/question.dart';
// front-end
import 'package:flutter/material.dart';
import 'package:hoothub/screens/styles.dart';
import 'package:hoothub/screens/widgets/info_downloader.dart';

class QuestionAnswerPreview extends StatelessWidget {
  const QuestionAnswerPreview({
    super.key,
    required this.answer,
    required this.answerIcon,
    required this.color,
  });

  final String answer;
  final Icon answerIcon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        answerIcon,
        Text(answer, style: TextStyle(color: color)),
      ],
    );
  }
}

class QuestionCard extends StatefulWidget {
  const QuestionCard({
    super.key,
    required this.testId,
    required this.questionIndex,
    required this.questionModel,
  });

  final String testId;
  final int questionIndex;
  final Question questionModel;

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  bool _correctAnswerRevealed = false;

  Widget buildWithQuestionImage(BuildContext context, Widget questionImage) {
    const separator = SizedBox(height: 8);

    List<Widget> questionChildren = [
      TextButton(
        onPressed: () => setState(() {
          _correctAnswerRevealed = !_correctAnswerRevealed;
        }),
        style: const ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(white),
          foregroundColor: MaterialStatePropertyAll(primaryColor),
        ),
        child: Text('${_correctAnswerRevealed ? 'Hide' : 'Reveal'} correct answer'),
      ),
      separator,
      questionImage,
      separator,
    ];

    for (final (int index, String answer) in widget.questionModel.answers.indexed) {
      final bool isCorrectAnswer = index == widget.questionModel.correctAnswer;
      final Icon questionPreviewIcon = (
        _correctAnswerRevealed
        ? (
          isCorrectAnswer
          ? Icon(Icons.check, color: (const HSVColor.fromAHSV(1, 120, 5 / 6, 5 / 6)).toColor())
          : Icon(Icons.close, color: (const HSVColor.fromAHSV(1, 0, 5 / 6, 5 / 6)).toColor())
        )
        : const Icon(null)
      );

      questionChildren.add(
        QuestionAnswerPreview(
          answer: answer,
          answerIcon: questionPreviewIcon,
          color: answerColor(index),
        ),
      );

      questionChildren.add(separator);
    }

    return ExpansionTile(
      title: Text(widget.questionModel.question, style: const TextStyle(fontSize: smallHeadingFontSize)),
      children: questionChildren,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InfoDownloader<Uint8List>(
      downloadInfo: () => downloadQuestionImage(widget.testId, widget.questionIndex),
      builder: (BuildContext context, Uint8List? questionImageData, bool downloaded) {
        final Widget questionImage = ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 100, maxHeight: 100),
          child: (
            downloaded
            ? (
              questionImageData != null
              ? Image.memory(questionImageData)
              : const SizedBox()
            )
            : (
              Image.asset('assets/default_image.png')
            )
          ),
        );

        return buildWithQuestionImage(context, questionImage);
      },
      buildError: (BuildContext context, Object error) {
        return buildWithQuestionImage(
          context,
          const Text("Failed to download question's image..."),
        );
      },
    );
  }
}

class QuestionsCard extends StatelessWidget {
  const QuestionsCard({
    super.key,
    required this.testId,
    required this.questions,
  });

  final String testId;
  final List<Question> questions;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: whiteOnPurpleTheme,
      child: ExpansionTile(
        title: const Text('Questions', style: TextStyle(fontSize: smallHeadingFontSize)),
        children: List<Widget>.from(
          questions.indexed.map<Widget>(
            ((int, Question) indexAndQuestion) => QuestionCard(testId: testId, questionIndex: indexAndQuestion.$1, questionModel: indexAndQuestion.$2),
          ),
        ),
      ),
    );
  }
}
