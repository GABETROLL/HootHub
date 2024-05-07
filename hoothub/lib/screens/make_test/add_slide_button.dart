import 'package:flutter/material.dart';

class AddSlideButton extends StatelessWidget {
  const AddSlideButton({super.key, required this.onPressed});

  final void Function() onPressed;

  @override
  Widget build(BuildContext context) => Center(
    child: ElevatedButton(
      onPressed: onPressed,
      child: const Text('Add question'),
    ),
  );
}
