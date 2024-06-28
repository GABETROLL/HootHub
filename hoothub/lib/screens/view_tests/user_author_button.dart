import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:hoothub/firebase/models/user.dart';
import 'package:hoothub/firebase/api/auth.dart';
import 'package:hoothub/firebase/api/images.dart';

import 'package:flutter/material.dart';
import 'package:hoothub/screens/widgets/info_downloader.dart';
import 'package:hoothub/screens/user_profile/user_profile.dart';
import 'package:hoothub/screens/styles.dart';

class UserAuthorButton extends StatelessWidget {
  const UserAuthorButton({
    super.key,
    required this.userPostId,
    required this.userId,
  });

  final String userPostId;
  final String? userId;

  @override
  Widget build(BuildContext context) {
    return InfoDownloader<(Uint8List?, UserModel?)>(
      downloadInfo: () async {
        String? userIdPromoted = userId;

        Uint8List? userImage = userIdPromoted != null ? await downloadUserImage(userIdPromoted) : null;
        UserModel? userModel = userIdPromoted != null ? await userWithId(userIdPromoted) : null;

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

        Row resultIcon = Row(
          children: <Widget>[
            ConstrainedBox(
              constraints: userImageButtonConstraints,
              child: userImage,
            ),
            Text(username),
          ],
        );

        return InkWell(
          onTap: goToUserProfile,
          child: resultIcon,
        );
      },
      buildError: (BuildContext context, Object error) {
        print("Error displaying `$userPostId`'s author, `$userId`: $error");
        return const Text('[Error]');
      },
    );
  }
}
