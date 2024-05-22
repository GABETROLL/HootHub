import 'package:flutter/material.dart';

class InfoDownloader<T> extends StatefulWidget {
  const InfoDownloader({
    super.key,
    required this.downloadInfo,
    required this.buildSuccess,
    required this.buildLoading,
    required this.buildError,
  });

  final Future<T?> Function() downloadInfo;
  final Widget Function(BuildContext, T) buildSuccess;
  final Widget Function(BuildContext) buildLoading;
  final Widget Function(BuildContext, Object) buildError;

  @override
  State<InfoDownloader<T>> createState() => _InfoDownloaderState<T>();
}

class _InfoDownloaderState<T> extends State<InfoDownloader<T>> {
  T? _result;
  bool _triedDownloadingResult = false;

  // THROWS.
  Future<void> _fetchResult() async {
    T? result = await widget.downloadInfo();

    if (!mounted) return;

    setState(() {
      _result = result;
      _triedDownloadingResult = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    try {
      if (!_triedDownloadingResult) {
        _fetchResult();
      }

      if (_result != null) {
        return widget.buildSuccess(context, _result!);
      } else {
        return widget.buildLoading(context);
      }
    } catch (error) {
      return widget.buildError(context, error);
    }
  }
}
