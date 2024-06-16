import 'package:flutter/material.dart';

class InfoDownloader<T> extends StatefulWidget {
  const InfoDownloader({
    super.key,
    required this.downloadInfo,
    required this.builder,
    required this.buildError,
  });

  final Future<T?> Function() downloadInfo;
  final Widget Function(BuildContext context, T? result, bool downloaded) builder;
  final Widget Function(BuildContext context, Object error) buildError;

  @override
  State<InfoDownloader<T>> createState() => _InfoDownloaderState<T>();
}

class _InfoDownloaderState<T> extends State<InfoDownloader<T>> {
  T? _result;
  Object? _error;
  bool _triedDownloadingResult = false;

  // PROBABLY DOESN'T THROW.
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
      } else {
        return widget.builder(context, _result, _triedDownloadingResult);
      }
    } catch (error) {
      return widget.buildError(context, error);
    }
  }
}
