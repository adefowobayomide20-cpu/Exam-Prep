import 'package:flutter/material.dart';

/// Lets services with no [BuildContext] of their own (e.g. a tapped
/// notification arriving via a background FCM isolate) push a route from
/// wherever the app currently is.
final rootNavigatorKey = GlobalKey<NavigatorState>();
