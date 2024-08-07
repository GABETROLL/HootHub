import 'package:hoothub/firebase/api/clients.dart';
import 'package:hoothub/firebase/api/images.dart';
import 'package:hoothub/firebase/models/user.dart';
import 'package:hoothub/firebase/models/user_scores.dart';

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hoothub/screens/styles.dart';
import 'package:hoothub/screens/widgets/image_editor.dart';
import 'view_user_tests.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({
    super.key,
    required this.user,
    required this.userImage,
    required this.userScores,
  });

  final UserModel user;
  final Uint8List? userImage;
  final UserScores? userScores;

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  Uint8List? _userImage;

  @override
  void initState() {
    super.initState();
    _userImage = widget.userImage;
  }

  @override
  Widget build(BuildContext context) {
    String? userIdPromoted = widget.user.id;
    String? currentUserId = auth.currentUser?.uid;

    final Widget userImageWidget;

    // If this user to display IS the current user,
    // let them edit/delete/upload their profile picture:
    if (currentUserId != null && userIdPromoted == currentUserId) {
      userImageWidget = ImageEditor(
        imageData: _userImage,
        defaultImage: Image.asset('assets/default_user_image.png'),
        asyncOnChange: (Uint8List newImage) async {
          if (!mounted) return;

          try {
            await uploadUserImage(currentUserId, newImage);          
          } catch (error) {
            if (!(context.mounted)) return;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Failed to upload you profile picture.")),
            );
          }

          setState(() {
            _userImage = newImage;
          });
        },
        asyncOnImageNotRecieved: () {
          if (!(context.mounted)) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Image not recieved!")),
          );
        },
        onDelete: () async {
          String deleteStatus = await deleteLoggedInUserImage();

          if (!(context.mounted)) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(deleteStatus)),
          );
        }
      );
    } else {
      Uint8List? userImagePromoted = _userImage;
      if (userImagePromoted != null) {
        userImageWidget = Image.memory(userImagePromoted);
      } else {
        userImageWidget = Image.asset('assets/default_user_image.png');
      }
    }

    UserScores? userScoresPromoted = widget.userScores;

    return Scaffold(
      appBar: AppBar(title: const Text('HootHub - View Profile')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: largeScreenWidth),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200, maxWidth: 200),
                      child: userImageWidget,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(widget.user.username, style: const TextStyle(fontSize: 70)),
                        Text('Created: ${widget.user.dateCreated.toDate()}', style: const TextStyle(fontSize: 40)),
                      ],
                    ),
                  ),
                ],
              ),
              // USER SCORES:
              Theme(
                data: whiteOnPurpleTheme,
                child: Card(
                  child: Column(
                    children: [
                      const Text("User's Statistics", style: TextStyle(fontSize: smallHeadingFontSize)),
                      userScoresPromoted == null
                      ? const Text("User scores not available...")
                      : Table(
                        children: <TableRow>[
                          TableRow(
                            children: <Widget>[
                              const Text("Total questions answered correct / Total questions answered"),
                              Text("${userScoresPromoted.netAnswerRatio.questionsAnsweredCorrect} / ${userScoresPromoted.netAnswerRatio.questionsAnswered}"),
                            ],
                          ),
                          TableRow(
                            children: <Widget>[
                              const Text("Best Point Score"),
                              Text("${userScoresPromoted.bestScore}"),
                            ],
                          ),
                          TableRow(
                            children: <Widget>[
                              const Text("Best Answer Score"),
                              Text("${userScoresPromoted.bestAnswerRatio.questionsAnsweredCorrect} / ${userScoresPromoted.bestAnswerRatio.questionsAnswered}"),
                            ],
                          ),
                          TableRow(
                            children: <Widget>[
                              const Text("Net Upvotes"),
                              Text("${userScoresPromoted.netUpvotes}"),
                            ],
                          ),
                          TableRow(
                            children: <Widget>[
                              const Text("Net Votes"),
                              Text("${userScoresPromoted.netUpvotes - userScoresPromoted.netDownvotes}"),
                            ],
                          ),
                          TableRow(
                            children: <Widget>[
                              const Text("Net Downvotes"),
                              Text("${userScoresPromoted.netDownvotes}"),
                            ],
                          ),
                          TableRow(
                            children: <Widget>[
                              const Text("Net Comments"),
                              Text("${userScoresPromoted.netComments}"),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: userIdPromoted != null
                  ? ViewUserTests(userId: userIdPromoted)
                  : const Center(child: Text("User doesn't have ID!")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
