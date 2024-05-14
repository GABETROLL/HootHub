import 'package:hoothub/firebase/models/question.dart';
import 'package:flutter/material.dart';

class QuestionCard extends StatefulWidget {
  const QuestionCard({
    super.key,
    required this.question,
    required this.answers,
    required this.correctAnswer,
  });

  final String question;
  final List<String> answers;
  final int correctAnswer;

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}
class _QuestionCardState extends State<QuestionCard> {
  bool _open = false;
  bool _correctAnswerRevealed = false;

  @override
  Widget build(BuildContext context) {
    final List<Widget> questionChildren = [
      Row(
        children: [
          Text(widget.question),
          TextButton(
            onPressed: () => setState(() {
              _open = !_open;
              _correctAnswerRevealed = false;
              // Closing and opening the answers drawer should hide the correct answers again,
              // to prevent spoilers.
            }),
            child: Text(_open ? 'Close' : 'Open'),
          ),
        ],
      ),
    ];

    if (_open) {
      questionChildren.add(
        TextButton(
          onPressed: () => setState(() {
            _correctAnswerRevealed = !_correctAnswerRevealed;
          }),
          child: Text('${_correctAnswerRevealed ? 'Hide' : 'Reveal'} correct answer'),
        ),
      );

      for (final (int index, String answer) in widget.answers.indexed) {
        final List<Widget> answerChildren = [
          Text(answer),
        ];

        if (_correctAnswerRevealed) {
          final bool currentAnswerCorrect = index == widget.correctAnswer;

          answerChildren.insert(
            0,
            Icon(
              currentAnswerCorrect ? Icons.check : Icons.close,
              color: currentAnswerCorrect ? Colors.green : Colors.red
            ),
          );
        }

        questionChildren.add(
          Row(children: answerChildren),
        );
      }
    }

    return Column(children: questionChildren);
  }
}

class QuestionsCard extends StatefulWidget {
  const QuestionsCard({
    super.key,
    required this.questions,
  });

  final List<Question> questions;

  @override
  State<QuestionsCard> createState() => _QuestionsCardState();
}

class _QuestionsCardState extends State<QuestionsCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      Row(
        children: [
          const Text('Questions'),
          TextButton(
            onPressed: () => setState(() { _open = !_open; }),
            child: Text(_open ? 'Close' : 'Open'),
          ),
        ],
      ),
    ];

    if (_open) {
      for (final Question question in widget.questions) {
        children.add(
          QuestionCard(question: question.question, answers: question.answers, correctAnswer: question.correctAnswer),
        );
      }
    }

    return Column(children: children);
  }
}
