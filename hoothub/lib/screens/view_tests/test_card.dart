import 'package:hoothub/firebase/api/clients.dart';
import 'package:hoothub/firebase/api/auth.dart';
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
              InfoDownloader<String>(
                downloadName: "${testModel.id}'s test image download URL",
                downloadInfo: () => testImageDownloadUrl(testModel.id!),
                buildSuccess: (BuildContext context, String imageUrl) {
                  return Image.network(imageUrl, width: testImageWidth);
                },
                buildLoading: (BuildContext context) {
                  return Image.asset('default_image.png', width: testImageWidth);
                },
              ),
              Text(testModel.name, style: const TextStyle(fontSize: 60)),
              Row(
                children: [
                  InfoDownloader<String>(
                    downloadName: "${testModel.userId}'s user image download URL",
                    downloadInfo: () => userImageDownloadUrl(testModel.userId!),
                    buildSuccess: (BuildContext context, String imageUrl) {
                      return Image.network(imageUrl, width: userImageWidth);
                    },
                    buildLoading: (BuildContext context) {
                      return Image.asset('default_user_image.png', width: userImageWidth);
                    },
                  ),
                  InfoDownloader<UserModel>(
                    downloadName: "${testModel.userId}'s username",
                    downloadInfo: () => userWithId(testModel.userId!),
                    buildSuccess: (BuildContext context, UserModel testAuthor) {
                      return Text(testAuthor.username);
                    },
                    buildLoading: (BuildContext context) {
                      return const Text('Loading...');
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
