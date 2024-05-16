import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class InfoDownloader<T> extends StatefulWidget {
  const InfoDownloader({
    super.key,
    required this.downloadName,
    required this.downloadInfo,
    required this.buildSuccess,
    required this.buildLoading,
  });

  final String downloadName;
  final Future<T?> Function() downloadInfo;
  final Widget Function(BuildContext, T) buildSuccess;
  final Widget Function(BuildContext) buildLoading;

  @override
  State<InfoDownloader<T>> createState() => _InfoDownloaderState<T>();
}

class _InfoDownloaderState<T> extends State<InfoDownloader<T>> {
  T? _result;
  bool _triedDownloadingResult = false;

  Future<void> _fetchResult() async {
    T? result;

    try {
      result = await widget.downloadInfo();
    } on FirebaseException catch (error) {
      print('Error downloading ${widget.downloadName}: ${error.message ?? error.code}');
    } catch (error) {
      print('Error downloading ${widget.downloadName}: $error');
    }

    if (!mounted) return;

    setState(() {
      _result = result;
      _triedDownloadingResult = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_triedDownloadingResult) {
      _fetchResult();
    }

    if (_result != null) {
      try {
        return widget.buildSuccess(context, _result!);    
      } catch (error) {
        return widget.buildLoading(context);
      }
    } else {
      return widget.buildLoading(context);
    }
  }
}
