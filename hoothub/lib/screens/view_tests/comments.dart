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
import 'package:hoothub/screens/widgets/user_author_button.dart';
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

        String? currentUserId = auth.currentUser?.uid;

        List<Widget> rowChildren = <Widget>[
          UserAuthorButton(
             userId: result.userId,
          ),
          const SizedBox(width: 10),    
        ];

        if (currentUserId != null && result.userId != null && result.userId == currentUserId) {
          rowChildren.add(
            IconButton(
              onPressed: () async {
                String deleteStatus = await deleteCommentWithId(testId, commentId);

                if (!(context.mounted)) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(deleteStatus)),
                );
              },
              icon: const Icon(Icons.delete),
            ),
          );
          rowChildren.add(const SizedBox(width: 10));
        }

        rowChildren.add(Text(result.comment));

        List<Widget> commentChildren = [
          CommentForm(
            onCommentSubmitted: (String comment) {
              replyToCommentWithId(commentId, comment);
            },
          ),
        ];

        for (String replyId in result.replyIds) {
          commentChildren.add(
            CommentTreeWidget(testId: testId, commentId: replyId),
          );
        }

        return ExpansionTile(
          title: Row(
            children: rowChildren,
          ),
          children: commentChildren,
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
        if (result == null) {
          return const SizedBox();
        }

        final Uint8List? currentUserImageData = result.$1;
        final String currentUsername = result.$2 ?? '[Username not found]';

        final Image currentUserImage = (
          currentUserImageData != null
          ? Image.memory(currentUserImageData)
          : Image.asset('assets/default_user_image.png')
        );

        final TextEditingController commentEditingController = TextEditingController();

        Color themePrimaryColor = Theme.of(context).primaryColor;

        return Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ConstrainedBox(
                constraints: userImageButtonConstraints,
                child: currentUserImage,
              ),
            ),
            Expanded(
              child: TextField(
                controller: commentEditingController,
                style: TextStyle(color: themePrimaryColor),
                cursorColor: themePrimaryColor,
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
        colorScheme: const ColorScheme.light(
          primary: white,
          onPrimary: primaryColor,
          background: primaryColor,
          onBackground: white,
          surface: white,
          onSurface: primaryColor,
        ),
        expansionTileTheme: const ExpansionTileThemeData(
          backgroundColor: primaryColor,
          collapsedBackgroundColor: primaryColor,
          iconColor: white,
          collapsedIconColor: white,
          textColor: white,
          collapsedTextColor: white,
          childrenPadding: EdgeInsetsDirectional.only(start: 20),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(color: white),
          hintStyle: TextStyle(color: white.withOpacity(0.75)),
          iconColor: white,
          prefixIconColor: white,
          suffixIconColor: white,
          focusColor: secondaryColor,
          hoverColor: white,
          outlineBorder: BorderSide(color: white.withOpacity(0.75)),
          errorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: white)),
          focusedErrorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
          disabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: white.withOpacity(0.75))),
          border: const OutlineInputBorder(borderSide: BorderSide(color: white)),
        ),
        elevatedButtonTheme: const ElevatedButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStatePropertyAll<Color>(primaryColor),
          )
        ),
      ),
      child: ExpansionTile(
        title: const Text('Comments'),
        children: _children,
      ),
    );
  }
}

