// back-end
import 'package:hoothub/firebase/models/test.dart';
import 'package:hoothub/firebase/models/question.dart';
// front-end
import 'package:flutter/material.dart';
import '../make_test/make_test.dart';

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
  late bool _open;
  late List<bool> _questionsOpen;

  @override
  initState() {
    super.initState();
    _open = false;
    _questionsOpen = List.from(
      widget.questions.map<bool>(
        (Question question) => false
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Text('`ViewQuestions` has not yet been implemented!');
  }
}

class ViewTest extends StatelessWidget {
  const ViewTest({super.key, required this.testModel});

  final Test testModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(testModel.name),
      ),
      body: Column(
        children: [
          // test image here, test title, and username+userlogo
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () { },
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
                      builder: (BuildContext context) => MakeTest(testModel: testModel),
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
          ViewQuestions(questions: testModel.questions),
        ],
      )
    );
  }
}
