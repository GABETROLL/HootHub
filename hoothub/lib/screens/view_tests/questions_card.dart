// back-end
import 'package:hoothub/firebase/models/question.dart';
// front-end
import 'package:flutter/material.dart';
import 'package:hoothub/screens/styles.dart';

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
    required this.questionModel,
  });

  final Question questionModel;

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  bool _correctAnswerRevealed = false;

  @override
  Widget build(BuildContext context) {
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
    }

    return ExpansionTile(
      title: Text(widget.questionModel.question),
      children: questionChildren,
    );
  }
}

class QuestionsCard extends StatelessWidget {
  const QuestionsCard({
    super.key,
    required this.questions,
  });

  final List<Question> questions;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        expansionTileTheme: const ExpansionTileThemeData(
          backgroundColor: primaryColor,
          collapsedBackgroundColor: primaryColor,
          iconColor: white,
          collapsedIconColor: white,
          textColor: white,
          collapsedTextColor: white,
          childrenPadding: EdgeInsetsDirectional.only(start: 20),
        ),
      ),
      child: ExpansionTile(
        title: const Text('Questions'),
        children: List<Widget>.from(
          questions.map<Widget>(
            (Question question) => QuestionCard(questionModel: question),
          ),
        ),
      ),
    );
  }
}
