import 'package:hoothub/firebase/models/question.dart';
import 'package:flutter/material.dart';
import 'package:hoothub/screens/styles.dart';

class QuestionCard extends StatefulWidget {
  const QuestionCard({
    super.key,
    required this.questionModel,
    this.startPadding = 20,
  });

  final Question questionModel;
  final double startPadding;

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  bool _correctAnswerRevealed = false;

  @override
  Widget build(BuildContext context) {
    final padding = EdgeInsetsDirectional.only(start: widget.startPadding);

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
      final List<Widget> answerChildren = [
        Text(answer),
      ];

      if (_correctAnswerRevealed) {
        final bool currentAnswerCorrect = index == widget.questionModel.correctAnswer;

        answerChildren.insert(
          0,
          Icon(
            currentAnswerCorrect ? Icons.check : Icons.close,
            color: currentAnswerCorrect ? Colors.green : Colors.red
          ),
        );
      }

      questionChildren.add(
        Padding(
          padding: padding,
          child: Row(children: answerChildren),
        ),
      );
    }

    return Padding(
      padding: padding,
      child: ExpansionTile(
        title: Text(widget.questionModel.question),
        children: questionChildren,
      ),
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
        ),
      ),
      child: ExpansionTile(
        title: const Text('Questions'),
        children: List<Widget>.from(
          questions.map<Widget>(
            (Question question) => Padding(
              padding: const EdgeInsetsDirectional.only(start: 20),
              child: QuestionCard(questionModel: question),
            ),
          ),
        ),
      ),
    );
  }
}
