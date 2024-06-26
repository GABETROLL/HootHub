import 'package:hoothub/firebase/api/clients.dart';
import 'package:hoothub/firebase/api/images.dart';
import 'package:hoothub/firebase/models/user.dart';

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
  });

  final UserModel user;
  final Uint8List? userImage;

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
      );
    } else {
      Uint8List? userImagePromoted = _userImage;

      if (userImagePromoted != null) {
        userImageWidget = Image.memory(userImagePromoted);
      } else {
        userImageWidget = Image.asset('assets/default_user_image.png');
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('HootHub - View Profile')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: largeScreenWidth),
          child: Column(
            children: [
              Row(
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300, maxHeight: 300),
                    child: userImageWidget,
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
              // USER STATS HERE
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
