import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/deep_link_service.dart';
import '../../widgets/slide_up_route.dart';
import 'duel_join_page.dart';

/// Mounted once near the app root (alongside [IncomingChallengeListener]):
/// watches for duel invite links (examcoach.com.ng/duel/<code>) opened
/// while signed in, and pushes straight into [DuelJoinPage] to join.
class DuelDeepLinkListener extends StatefulWidget {
  const DuelDeepLinkListener({super.key, required this.child});

  final Widget child;

  @override
  State<DuelDeepLinkListener> createState() => _DuelDeepLinkListenerState();
}

class _DuelDeepLinkListenerState extends State<DuelDeepLinkListener> {
  StreamSubscription<String>? _sub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pending = DeepLinkService.instance.pendingCode;
      if (pending != null) _openJoinPage(pending);
    });
    _sub = DeepLinkService.instance.duelCodeStream.listen(_openJoinPage);
  }

  void _openJoinPage(String code) {
    DeepLinkService.instance.consumePendingCode();
    Navigator.of(context, rootNavigator: true).push(
      SlideUpRoute(builder: (_) => DuelJoinPage(initialCode: code)),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
