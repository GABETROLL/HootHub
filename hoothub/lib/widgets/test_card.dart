import 'package:flutter/material.dart';

class TestCard extends StatelessWidget {
  const TestCard({
    super.key,
    required this.testName,
    required this.username,
    this.testImageUrl,
    this.profileImageUrl,
  });

  final String testName;
  final String username;
  final String? testImageUrl;
  final String? profileImageUrl;

  @override
  Widget build(BuildContext context) {
    const double width = 760;
    const double testImageWidth = width / 2;
    const double userImageWidth = 60;

    final Image testImage = (
      testImageUrl != null
      ? Image.network(testImageUrl!)
      : Image.asset(
        'assets/default_image.png',
        width: testImageWidth,
      )
    );

    final Image defaultUserImage = (
      profileImageUrl != null
      ? Image.network(profileImageUrl!, width: userImageWidth)
      : Image.asset(
        'assets/default_user_image.png',
        width: userImageWidth
      )
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: width),
        child: Card(
          child: Column(
            children: [
              testImage,
              Text(testName, style: const TextStyle(fontSize: 60)),
              Row(
                children: [
                  defaultUserImage,
                  Text(username),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
