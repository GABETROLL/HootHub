// back-end
import 'package:hoothub/firebase/models/test.dart';
import 'package:hoothub/firebase/models/question.dart';
import 'package:hoothub/firebase/models/user.dart';
import 'package:hoothub/firebase/api/auth.dart';
// front-end
import 'package:flutter/material.dart';
import 'package:hoothub/widgets/test_card.dart';
import 'package:hoothub/screens/play_test_solo/play_test_solo.dart';
import 'package:hoothub/screens/make_test/make_test.dart';

class ViewQuestion extends StatefulWidget {
  const ViewQuestion({
    super.key,
    required this.question,
    required this.answers,
    required this.correctAnswer,
  });

  final String question;
  final List<String> answers;
  final int correctAnswer;

  @override
  State<ViewQuestion> createState() => _ViewQuestionState();
}
class _ViewQuestionState extends State<ViewQuestion> {
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

class ViewQuestions extends StatefulWidget {
  const ViewQuestions({
    super.key,
    required this.questions,
  });

  final List<Question> questions;

  @override
  State<ViewQuestions> createState() => _ViewQuestionsState();
}

class _ViewQuestionsState extends State<ViewQuestions> {
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
          ViewQuestion(question: question.question, answers: question.answers, correctAnswer: question.correctAnswer),
        );
      }
    }

    return Column(children: children);
  }
}

class ViewTest extends StatefulWidget {
  const ViewTest({
    super.key,
    required this.testModel,
  });

  final Test testModel;

  @override
  State<ViewTest> createState() => _ViewTestState();
}

class _ViewTestState extends State<ViewTest> {
  UserModel? _testAuthor;

  @override
  void initState() {
    super.initState();

    // If the test model is not valid,
    // this widget should only display this fact to the user,
    // and we don't need to bother fetching the author's `UserModel`.
    // (read below)
    if (!(widget.testModel.isValid())) return;

    // Get the test's author's `UserModel`.
    // The test doesn't store the model directly,
    // but it provides the user's ID.
    //
    // We need to get the user's model, so that we can display
    // the author's username right underneath the test's name and image.
    if (widget.testModel.userId != null) {
      userWithId(widget.testModel.userId!)
        .then(
          (UserModel? testAuthor) {
            setState(() {
              _testAuthor = testAuthor;
            });
          },
          onError: (error) {
            print('error initting state: $error');
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!(widget.testModel.isValid())) {
      const double textWidth = 760;

      return Scaffold(
        appBar: AppBar(
          title: const Text('HootHub'),
        ),
        body: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: textWidth,
              child: Text("The test you're trying to view seems to be invalid. I'm verry sorry!"),
            ),
            SizedBox(
              width: textWidth,
              child: Text(":("),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('HootHub'),
      ),
      body: ListView(
        children: [
          TestCard(
            testName: widget.testModel.name,
            username: _testAuthor?.username ?? '...',
            testImageUrl: widget.testModel.imageUrl,
            profileImageUrl: _testAuthor?.profileImageUrl,
          ),
          // Test Options
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => PlayTestSolo(
                        testModel: widget.testModel,
                      ),
                    ),
                  );
                },
                child: const Text('Play solo'),
              ),
              ElevatedButton(
                onPressed: () { },
                child: const Text('Host live'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => MakeTest(testModel: widget.testModel),
                    ),
                  );
                },
                child: const Text('Edit'),
              ),
              IconButton(
                onPressed: () { },
                icon: const Icon(Icons.share),
              ),
            ],
          ),
          ViewQuestions(questions: widget.testModel.questions),
        ],
      )
    );
  }
}
