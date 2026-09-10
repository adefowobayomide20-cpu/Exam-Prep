import 'dart:async';

import 'package:flutter/material.dart';

/// Shows a small non-dismissible spinner while [task] runs, then closes it
/// and returns the result — used around fetching a deferred question bank,
/// which is instant once loaded earlier in the session but can take a
/// moment the first time it's needed.
Future<T> showLoadingWhile<T>(BuildContext context, Future<T> Function() task) async {
  final navigator = Navigator.of(context, rootNavigator: true);
  unawaited(
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: SizedBox(width: 44, height: 44, child: CircularProgressIndicator()),
      ),
    ),
  );
  try {
    return await task();
  } finally {
    navigator.pop();
  }
}
