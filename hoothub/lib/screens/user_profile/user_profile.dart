import 'package:hoothub/firebase/models/user.dart';

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hoothub/screens/styles.dart';
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: largeScreenWidth),
          child: Column(
            children: [
              Row(
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300, maxHeight: 300),
                    child: userImagePromoted != null ? Image.memory(userImagePromoted) : Image.asset('assets/default_user_image.png'),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(user.username, style: const TextStyle(fontSize: 70)),
                        Text('Created: ${user.dateCreated.toDate()}', style: const TextStyle(fontSize: 40)),
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
