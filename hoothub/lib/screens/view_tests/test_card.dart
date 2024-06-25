import 'package:hoothub/firebase/api/clients.dart';
import 'package:hoothub/firebase/api/auth.dart';
import 'package:hoothub/firebase/api/tests.dart';
import 'package:hoothub/firebase/models/user.dart';
import 'package:hoothub/firebase/models/test.dart';
import 'package:hoothub/firebase/api/images.dart';
// front-end
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hoothub/screens/styles.dart';
import 'package:hoothub/screens/user_profile/user_profile.dart';
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
    const double width = mediumScreenWidth;
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
        onPressed: playSolo,
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
                SizedBox(
                  width: testImageWidth,
                  child: InfoDownloader<Uint8List>(
                    downloadInfo: () => downloadTestImage(testModel.id!),
                    builder: (BuildContext context, Uint8List? imageData, bool downloaded) {
                      if (imageData != null) {
                        return Image.memory(imageData);
                      }
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
                    InfoDownloader<(Uint8List?, UserModel?)>(
                      downloadInfo: () async {
                        Uint8List? userImage = await downloadUserImage(testModel.userId!);
                        UserModel? userModel = await userWithId(testModel.userId!);

                        return (userImage, userModel);
                      },
                      builder: (BuildContext context, (Uint8List?, UserModel?)? result, bool downloaded) {
                        Uint8List? userImageData = result?.$1;
                        UserModel? userModel = result?.$2;

                        final String username;
                        final Image userImage;

                        void Function()? goToUserProfile;

                        if (downloaded) {
                          username = (
                            userModel != null
                            ? userModel.username
                            : "[Not found]"
                          );
                          userImage = (
                            userImageData != null
                            ? Image.memory(userImageData)
                            : Image.asset('assets/default_user_image.png')
                          );

                          if (userModel != null) {
                            goToUserProfile = () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) => UserProfile(user: userModel, userImage: userImageData),
                                ),
                              );
                            };
                          }
                        } else {
                          username = 'Loading...';
                          userImage = Image.asset('assets/default_user_image.png');
                        }

                        return InkWell(
                          onTap: goToUserProfile,
                          child: Row(
                            children: [
                              SizedBox(
                                width: userImageWidth,
                                child: userImage,
                              ),
                              Text(username),
                            ],
                          ),
                        );
                      },
                      buildError: (BuildContext context, Object error) {
                        print("Error displaying test ${testModel.id}'s author info, for `TestCard`: $error");
                        return const Text('[Error]');
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: options,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Theme(
                    data: outerTheme,
                    child: QuestionsCard(questions: testModel.questions),
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
