import 'package:hoothub/firebase/models/user.dart';

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'view_user_tests.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({
    super.key,
    required this.user,
    required this.userImage,
  });

  final UserModel user;
  final Uint8List? userImage;

  @override
  Widget build(BuildContext context) {
    Uint8List? userImagePromoted = userImage;
    String? userIdPromoted = user.id;

    return Scaffold(
      appBar: AppBar(title: const Text('HootHub - View Profile')),
      body: Column(
        children: [
          Row(
            children: [
              userImagePromoted != null ? Image.memory(userImagePromoted) : Image.asset('assets/default_user_image.png'),
              Column(
                children: [
                  Text(user.username, style: const TextStyle(fontSize: 100)),
                  Text('Created: ${user.dateCreated}'),
                ],
              ),
            ],
          ),
          // USER STATS HERE
          (
            userIdPromoted != null
            ? ViewUserTests(userId: userIdPromoted)
            : const Center(child: Text("`user` doesn't have ID!"))
          ),
        ],
      ),
    );
  }
}
