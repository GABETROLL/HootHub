// back-end
import 'dart:typed_data';
import 'package:hoothub/firebase/models/user.dart';
import 'package:hoothub/firebase/models/comment_tree.dart';
import 'package:hoothub/firebase/api/auth.dart';
import 'package:hoothub/firebase/api/clients.dart';
import 'package:hoothub/firebase/api/images.dart';
import 'package:hoothub/firebase/api/comments.dart';
// front-end
import 'package:flutter/material.dart';
import 'user_author_button.dart';
import 'package:hoothub/screens/widgets/info_downloader.dart';
import 'package:hoothub/screens/styles.dart';

class CommentTreeWidget extends StatelessWidget {
  const CommentTreeWidget({
    super.key,
    required this.testId,
    required this.commentId,
  });

  final String testId;
  final String commentId;

  @override
  Widget build(BuildContext context) {
    return InfoDownloader<CommentTree>(
      downloadInfo: () => commentWithId(commentId),
      builder: (BuildContext context, CommentTree? result, bool downloaded) {
        if (!downloaded) {
          return const Text('Loading...');
        }

        if (result == null) {
          return const Text('Comment not found!');
        }

        final List<Widget> titleChildren = <Widget>[
          UserAuthorButton(
            userPostId: commentId,
            userId: result.userId,
          ),
          Text(result.comment),
        ];

        return ExpansionTile(
          title: Row(
            children: titleChildren,
          ),
          children: List<CommentTreeWidget>.of(
            result.replyIds.map<CommentTreeWidget>(
              (String replyId) => CommentTreeWidget(
                testId: testId,
                commentId: replyId,
              ),
            ),
          ),
        );
      },
      buildError: (BuildContext context, Object error) {
        print("Error displaying test `$testId`'s comment `$commentId`: $error");
        return const Text('Error displaying comment!');
      },
    );
  }
}

class CommentForm extends StatelessWidget {
  const CommentForm({
    super.key,
    required this.onCommentSubmitted,
  });

  final void Function(String comment) onCommentSubmitted;

  @override
  Widget build(BuildContext context) {
    return InfoDownloader<(Uint8List?, String?)>(
      downloadInfo: () async {
        final String? currentUserId = auth.currentUser?.uid;

        if (currentUserId == null) return null;

        final UserModel? currentUserModel = await loggedInUser();

        final Uint8List? currentUserImage = await downloadUserImage(currentUserId);
        final String? currentUsername = currentUserModel?.username;

        return (currentUserImage, currentUsername);
      },
      builder: (BuildContext context, (Uint8List?, String?)? result, bool downloaded) {
        final Uint8List? currentUserImageData = result?.$1;
        final String currentUsername = result?.$2 ?? '[Username not found]';

        final Image currentUserImage = (
          currentUserImageData != null
          ? Image.memory(currentUserImageData)
          : Image.asset('assets/default_user_image.png')
        );

        final TextEditingController commentEditingController = TextEditingController();

        return Row(
          children: <Widget>[
            ConstrainedBox(
              constraints: userImageButtonConstraints,
              child: currentUserImage,
            ),
            Expanded(
              child: TextField(
                controller: commentEditingController,
                decoration: InputDecoration(
                  hintText: "Comment as '$currentUsername'...",
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => onCommentSubmitted(commentEditingController.text),
              child: const Text('Comment'),
            ),
          ],
        );
      },
      buildError: (BuildContext context, Object error) {
        print("Error downloading current user's (${auth.currentUser?.uid}'s) image: $error");
        return Image.asset('assets/default_user_image.png');
      },
    );
  }
}

class Comments extends StatefulWidget {
  const Comments({
    super.key,
    required this.testId,
    required this.comments,
  });

  final String testId;
  final List<String> comments;

  @override
  State<Comments> createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  late List<Widget> _children;

  void resetChildren() {
    _children = [
      CommentForm(
        onCommentSubmitted: (String comment) async {
          await commentOnTestWithId(widget.testId, comment);
          setState(() {
            resetChildren();
          });
        },
      ),
    ];

    for (String commentId in widget.comments) {
      _children.add(
        CommentTreeWidget(
          testId: widget.testId,
          commentId: commentId
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    resetChildren();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        expansionTileTheme: const ExpansionTileThemeData(
          backgroundColor: primaryColor,
          collapsedBackgroundColor: primaryColor,
          iconColor: white,
          collapsedIconColor: white,
          textColor: white,
          collapsedTextColor: white,
          childrenPadding: EdgeInsetsDirectional.only(start: 20),
        ),
      ),
      child:  ExpansionTile(
        title: const Text('Comments'),
        children: _children,
      ),
    );
  }
}

