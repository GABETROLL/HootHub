import 'package:hoothub/firebase/api/clients.dart';
import 'package:hoothub/firebase/api/tests.dart';
import 'package:hoothub/firebase/models/test.dart';
import 'package:hoothub/firebase/api/images.dart';
// front-end
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hoothub/screens/styles.dart';
import 'comments.dart';
import 'user_author_button.dart';
import 'package:hoothub/screens/widgets/info_downloader.dart';
import 'questions_card.dart';

class TestCard extends StatelessWidget {
  const TestCard({
    super.key,
    required this.testModel,
    required this.asyncSetTestModel,
    required this.playSolo,
    required this.edit,
    required this.color,
  });

  final Test testModel;
  final void Function(Test newTestModel) asyncSetTestModel;
  final void Function() playSolo;
  final void Function() edit;
  final Color color;

  Future<void> onVote({ required BuildContext context, required bool up }) async {
    SaveTestResult voteResult = await voteOnTest(test: testModel, up: up);

    asyncSetTestModel(voteResult.updatedTest);

    if (voteResult.status != 'Ok' && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(voteResult.status)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String? testId = testModel.id;
    String? testAuthorId = testModel.userId;

    const double width = mediumScreenWidth;
    const double testImageWidth = width / 2;

    // We NEED the test to have a valid `id` and `userId`,
    // if we want to display its image, and author's image!
    if (!(testModel.isValid()) || testId == null || testAuthorId == null) {

      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: width),
          child: const Column(
            children: <Widget>[
              Text("Test is either invalid, has no ID or no user author ID... Very sorry!"),
              Text(":("),
            ],
          ),
        ),
      );
    }

    List<Widget> options = [
      ElevatedButton(
        onPressed: playSolo,
        child: const Text('Play solo'),
      ),
    ];

    String? currentUserId = auth.currentUser?.uid;

    // If a user is logged in, and they own this widget's `Test`,
    // we can allow them to edit it.
    bool userOwnsTest = (
      currentUserId != null
      && currentUserId == testAuthorId
    );

    if (userOwnsTest) {
      options.add(
        ElevatedButton(
          onPressed: edit,
          child: const Text('Edit'),
        ),
      );
    }

    return Theme(
      data: ThemeData(
        // WARNING: DO NOT USE `cardColor`, IT DOESN'T WORK!
        cardTheme: CardTheme(color: color),
        elevatedButtonTheme: const ElevatedButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStatePropertyAll(Colors.white),
            backgroundColor: MaterialStatePropertyAll(primaryColor),
          ),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: width),
          child: Card(
            child: Column(
              children: [
                // TEST IMAGE
                SizedBox(
                  width: testImageWidth,
                  child: InfoDownloader<Uint8List>(
                    downloadInfo: () => downloadTestImage(testId),
                    builder: (BuildContext context, Uint8List? imageData, bool downloaded) {
                      if (imageData != null) {
                        return Image.memory(imageData);
                      }
                      return Image.asset('default_image.png');
                    },
                    buildError: (BuildContext context, Object error) {
                      return Center(child: Text("Error loading or displaying test $testId's image: $error"));
                    },
                  ),
                ),
                // TEST TITLE
                Text(testModel.name, style: const TextStyle(fontSize: 60)),
                // TEST VOTING STUFF
                Row(
                  children: [
                    Column(
                      children: <Row>[
                        Row(
                          children: <Widget>[
                            IconButton(
                              onPressed: () => onVote(context: context, up: true),
                              icon: Icon(
                                Icons.arrow_upward,
                                color: (
                                  currentUserId != null && testModel.userUpvotedTest(currentUserId)
                                  ? Colors.purple
                                  : Colors.black
                                ),
                              ),
                            ),
                            Text(testModel.usersThatUpvoted.length.toString()),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            IconButton(
                              onPressed: () => onVote(context: context, up: false),
                              icon: Icon(
                                Icons.arrow_downward,
                                color: (
                                  currentUserId != null && testModel.userDownvotedTest(currentUserId)
                                  ? Colors.purple
                                  : Colors.black
                                ),
                              ),
                            ),
                            Text(testModel.usersThatDownvoted.length.toString()),
                          ],
                        ),
                      ],
                    ),
                    UserAuthorButton(userPostId: testId, userId: testAuthorId),
                  ],
                ),
                // TEST OPTIONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: options,
                ),
                // TEST QUESTIONS
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Theme(
                    data: outerTheme,
                    child: QuestionsCard(questions: testModel.questions),
                  ),
                ),
                // TEST COMMENTS
                // TODO: ONLY DISPLAY THEM ONCE THE PLAYER HAS FINISHED THE TEST,
                //  THROUGH THE FIREBASE SECURITY RULES, TO PREVENT CHEATING!
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Theme(
                    data: outerTheme,
                    child: Comments(testId: testId, comments: testModel.comments),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
