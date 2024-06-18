import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageEditor extends StatelessWidget {
  const ImageEditor({
    super.key,
    this.imageData,
    required this.asyncOnChange,
    required this.asyncOnImageNotRecieved,
  });

  final Uint8List? imageData;
  final void Function(Uint8List newImage) asyncOnChange;
  final void Function() asyncOnImageNotRecieved;

  @override
  Widget build(BuildContext context) {
    Image image;

    try {
      image = Image.memory(imageData!);
    } catch (error) {
      image = Image.asset('default_image.png');
    }

    return InkWell(
      onTap: () async {
        final ImagePicker imagePicker = ImagePicker();
        final XFile? newImageFile = await imagePicker.pickImage(source: ImageSource.gallery);

        if (newImageFile == null) {
          if (!(context.mounted)) return;

          asyncOnImageNotRecieved();
          return;
        }

        final Uint8List newImageData = await newImageFile.readAsBytes();

        asyncOnChange(newImageData);
      },
      child: image,
    );
  }
}
