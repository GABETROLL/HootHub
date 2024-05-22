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
  Object? _error;
  bool _triedDownloadingResult = false;

  // THROWS.
  Future<void> _fetchResult() async {
    T? result;
    Object? error;

    try {
      result = await widget.downloadInfo();
    } catch (e) {
      error = e;
    }

    if (!mounted) return;

    setState(() {
      _result = result;
      _error = error;
      _triedDownloadingResult = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_triedDownloadingResult) {
      _fetchResult();
    }

    try {
      if (_error != null) {
        return widget.buildError(context, _error!);
      } else if (_result != null) {
        return widget.buildSuccess(context, _result!);
      } else {
        return widget.buildLoading(context);
      }
    } catch (error) {
        return widget.buildError(context, error);
    }
  }
}
