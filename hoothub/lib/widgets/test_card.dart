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
    Image defaultImage = Image.asset('assets/default_image.png');

    return Card(
      child: Column(
        children: [
          (
            testImageUrl != null
              ? Image.network(testImageUrl!)
              : defaultImage
          ),
          Text(testName),
          Row(
            children: [
              (
                profileImageUrl != null
                  ? Image.network(profileImageUrl!)
                  : defaultImage
              ),
              Text(username),
            ],
          ),
        ],
      ),
    );
  }
}
