import 'package:hoothub/firebase/models/test.dart';
import 'package:hoothub/firebase/models/user.dart';
import 'package:hoothub/firebase/api/auth.dart';
// front-end
import 'package:flutter/material.dart';
import 'package:hoothub/screens/play_test_solo/play_test_solo.dart';
import 'package:hoothub/screens/make_test/make_test.dart';
import 'questions_card.dart';

class TestCard extends StatefulWidget {
  const TestCard({
    super.key,
    required this.testModel,
  });

  final Test testModel;

  @override
  State<TestCard> createState() => _TestCardState();
}

class _TestCardState extends State<TestCard> {
  UserModel? _testAuthor;

  @override
  void initState() {
    super.initState();

    // If the test model is not valid,
    // just display that.
    if (!(widget.testModel.isValid())) return;

    // Get the test's author's `UserModel`.
    //
    // We need it, to display the author's username
    // right underneath the test's name and image.
    try {
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
    } catch (error) {
      print('error initting state: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    const double width = 760;
    const double testImageWidth = width / 2;
    const double userImageWidth = 60;

    if (!(widget.testModel.isValid())) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: width),
          child: const Column(
            children: <Widget>[
              Text("The test you're trying to view seems to be invalid. I'm verry sorry!"),
              Text(":("),
            ],
          ),
        ),
      );
    }

    Image testImage = Image.asset(
      'assets/default_image.png',
      width: testImageWidth,
    );

    try {
      testImage = Image.network(widget.testModel.imageUrl!);
    } catch (error) {
      // What probably happened, is that `widget.testModel.imageUrl` was null.
    }

    Image userImage = Image.asset(
      'assets/default_user_image.png',
      width: userImageWidth
    );
    
    try {
      userImage = Image.network(_testAuthor!.profileImageUrl!, width: userImageWidth);
    } catch (error) {
      // What probably happened, is that `_testAuthor` was null,
      // or `_testAuthor!.profileImageUrl` was null.
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: width),
        child: Card(
          child: Column(
            children: [
              testImage,
              Text(widget.testModel.name, style: const TextStyle(fontSize: 60)),
              Row(
                children: [
                  userImage,
                  Text(_testAuthor?.username ?? '...'),
                ],
              ),
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
                ],
              ),
              QuestionsCard(questions: widget.testModel.questions),
            ],
          ),
        ),
      ),
    );
  }
}
