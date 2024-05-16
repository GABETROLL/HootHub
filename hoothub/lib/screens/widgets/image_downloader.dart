
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'info_downloader.dart';

/// Tries to download image using `downloadImage`,
/// then, if the `context` is still mounted, displays it.
///
/// While the image is downloading, tries to display
/// the image asset named `defaultImageAssetName`.
/// If displaying THIS image fails, displays the error
/// as a `Text`.
///
/// if something went wrong while downloading, and the `context`
/// is still mounted, or displaying the image went wrong,
/// this `Widget` displays the error as a `Text`.
///
/// `width` and `height` will be used, if provided.
/// `imageName` will be used for the error messages.
class ImageDownloader extends StatelessWidget {
  const ImageDownloader({
    super.key,
    required this.imageName,
    required this.downloadImage,
    required this.defaultImageAssetName,
    this.width,
    this.height,
  });

  final String imageName;
  final Future<Uint8List?> Function() downloadImage;
  final String defaultImageAssetName;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return InfoDownloader<Uint8List>(
      downloadName: imageName,
      downloadInfo: downloadImage,
      buildSuccess: (BuildContext context, Uint8List imageData) {
        return Image.memory(imageData, width: width, height: height);
      },
      buildLoading: (BuildContext context) {
        return Image.asset(defaultImageAssetName, width: width, height: height);
      },
    );
  }
}
