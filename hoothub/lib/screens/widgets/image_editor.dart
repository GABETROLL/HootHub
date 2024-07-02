import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

class ImageEditor extends StatelessWidget {
  const ImageEditor({
    super.key,
    this.imageData,
    required this.defaultImage,
    required this.asyncOnChange,
    required this.asyncOnImageNotRecieved,
    required this.onDelete,
  });

  final Uint8List? imageData;
  final Image defaultImage;
  final void Function(Uint8List newImage) asyncOnChange;
  final void Function() asyncOnImageNotRecieved;
  final void Function() onDelete;

  @override
  Widget build(BuildContext context) {
    Uint8List? imageDataPromoted = imageData;

    final Image image;

    if (imageDataPromoted == null) {
      image = defaultImage;
    } else {
      image = Image.memory(imageDataPromoted);
    }

    final List<Widget> children = <Widget>[
      Flexible(
        fit: FlexFit.loose,
        child: InkWell(
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
        ),
      ),
    ];

    if (imageDataPromoted != null) {
      children.add(
        IconButton(
          onPressed: onDelete,
            icon: const Icon(
            Icons.delete,
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}
