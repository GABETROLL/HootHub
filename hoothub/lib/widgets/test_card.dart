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
    const double userImageWidth = 60;

    final Image defaultImage = Image.asset('assets/default_image.png');
    final Image defaultUserImage = Image.asset('assets/default_user_image.png', width: userImageWidth);

    return Card(
        child: SizedBox(
          width: 760,
          child: Column(
            children: [
              (
                testImageUrl != null
                ? Image.network(testImageUrl!)
                : defaultImage
              ),
              Text(testName, style: const TextStyle(fontSize: 60)),
              Row(
                children: [
                  (
                    profileImageUrl != null
                      ? Image.network(profileImageUrl!, width: userImageWidth)
                      : defaultUserImage
                  ),
                  Text(username),
                ],
              ),
            ],
          ),
        ),
      );
  }
}
