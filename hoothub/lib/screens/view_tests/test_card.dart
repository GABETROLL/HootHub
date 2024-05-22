import 'package:hoothub/firebase/api/clients.dart';
import 'package:hoothub/firebase/api/auth.dart';
import 'package:hoothub/firebase/api/tests.dart';
import 'package:hoothub/firebase/models/user.dart';
import 'package:hoothub/firebase/models/test.dart';
import 'package:hoothub/firebase/api/images.dart';
// front-end
import 'package:flutter/material.dart';
import 'package:hoothub/screens/play_test_solo/play_test_solo.dart';
import 'package:hoothub/screens/make_test/make_test.dart';
import 'package:hoothub/screens/widgets/info_downloader.dart';
import 'questions_card.dart';

class TestCard extends StatelessWidget {
  const TestCard({
    super.key,
    required this.testModel,
  });

  final Test testModel;

  Future<void> onVote({ required BuildContext context, required bool up }) async {
    String voteResult = await voteOnTest(test: testModel, up: up);

    if (voteResult != 'Ok' && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You're not logged in! Log in to ${up ? 'up' : 'down'}vote.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const double width = 760;
    const double testImageWidth = width / 2;
    const double userImageWidth = 60;

    // We NEED the test to have a valid `id` and `userId`,
    // if we want to display its image, and author's image!
    if (!(testModel.isValid()) || testModel.id == null || testModel.userId == null) {
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

    List<Widget> options = [
      ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => PlayTestSolo(
                testModel: testModel,
              ),
            ),
          );
        },
        child: const Text('Play solo'),
      ),
    ];

    String? currentUserId = auth.currentUser?.uid;

    // If a user is logged in, and they own this widget's `Test`,
    // we can allow them to edit it.
    bool userOwnsTest = false;
    try {
      userOwnsTest = (
        auth.currentUser != null
        && testModel.userId != null
        && auth.currentUser!.uid == testModel.userId
      );
    } catch (error) {
      // SOMEHOW ACCESSED NULL FIELDS. FOR NOW, JUST ASSUME THEY DON'T.
    }

    if (userOwnsTest) {
      options.add(
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => MakeTest(
                  testModel: testModel,
                ),
              ),
            );
          },
          child: const Text('Edit'),
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: width),
        child: Card(
          child: Column(
            children: [
              SizedBox(
                width: testImageWidth,
                child: InfoDownloader<String>(
                  downloadInfo: () => testImageDownloadUrl(testModel.id!),
                  buildSuccess: (BuildContext context, String imageUrl) {
                    return Image.network(imageUrl);
                  },
                  buildLoading: (BuildContext context) {
                    return Image.asset('default_image.png');
                  },
                  buildError: (BuildContext context, Object error) {
                    return Center(child: Text("Error loading or displaying test ${testModel.id}'s image: $error"));
                  },
                ),
              ),
              Text(testModel.name, style: const TextStyle(fontSize: 60)),
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
                                ? Colors.orange
                                : Colors.grey
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
                                ? Colors.blue
                                : Colors.grey
                              ),
                            ),
                          ),
                          Text(testModel.usersThatDownvoted.length.toString()),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    width: userImageWidth,
                    child: InfoDownloader<String>(
                      downloadInfo: () => userImageDownloadUrl(testModel.userId!),
                      buildSuccess: (BuildContext context, String imageUrl) {
                        return Image.network(imageUrl);
                      },
                      buildLoading: (BuildContext context) {
                        return Image.asset('default_user_image.png');
                      },
                      buildError: (BuildContext context, Object error) {
                        return Center(child: Text("Error loading or displaying user ${testModel.userId}'s image: $error"));
                      },
                    ),
                  ),
                  InfoDownloader<UserModel>(
                    downloadInfo: () => userWithId(testModel.userId!),
                    buildSuccess: (BuildContext context, UserModel testAuthor) {
                      return Text(testAuthor.username);
                    },
                    buildLoading: (BuildContext context) {
                      return const Text('Loading...');
                    },
                    buildError: (BuildContext context, Object error) {
                      return Text("Error loading or displaying user ${testModel.userId}'s username: $error");
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: options,
              ),
              QuestionsCard(questions: testModel.questions),
            ],
          ),
        ),
      ),
    );
  }
}
