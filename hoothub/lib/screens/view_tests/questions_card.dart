import 'package:hoothub/firebase/models/question.dart';
import 'package:flutter/material.dart';

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
        Row(children: answerChildren),
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
    return ExpansionTile(
      title: const Text('Questions'),
      children: List<Widget>.from(
        questions.map<Widget>(
          (Question question) => QuestionCard(questionModel: question),
        ),
      ),
    );
  }
}
