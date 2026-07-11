import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../data/pwa_install_controller.dart';

/// Wraps the whole app so an "Install" banner can float over any screen on
/// web. It only shows once the browser has actually fired
/// `beforeinstallprompt` (so tapping it always works) and never shows once
/// the page is running as the installed app — [PwaInstallController.isStandalone]
/// is what a site launched from the home screen / app-drawer icon reports.
class PwaInstallOverlay extends StatefulWidget {
  const PwaInstallOverlay({super.key, required this.child});

  final Widget child;

  @override
  State<PwaInstallOverlay> createState() => _PwaInstallOverlayState();
}

class _PwaInstallOverlayState extends State<PwaInstallOverlay> {
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      PwaInstallController.instance.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    if (kIsWeb) {
      PwaInstallController.instance.removeListener(_onControllerChanged);
    }
    super.dispose();
  }

  void _onControllerChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final controller = PwaInstallController.instance;
    final canShow = kIsWeb && !_dismissed && !controller.isStandalone;
    // iOS Safari never fires beforeinstallprompt, so there's no
    // `installAvailable` signal to key off there — show manual
    // instructions instead of a button that would do nothing. The explicit
    // `!isIosSafari` guard (on top of `installAvailable` already being
    // false there in practice) means a stale/incorrect signal can never
    // render a button on iOS that silently does nothing when tapped.
    final showInstallButton = canShow && controller.installAvailable && !controller.isIosSafari;
    final showIosInstructions = canShow && !showInstallButton && controller.isIosSafari;

    return Stack(
      children: [
        widget.child,
        if (showInstallButton || showIosInstructions)
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              top: false,
              child: Material(
                color: const Color(0xFF12203D),
                borderRadius: BorderRadius.circular(14),
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        showIosInstructions ? Icons.ios_share : Icons.install_mobile,
                        color: const Color(0xFFC8932A),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          showIosInstructions
                              ? 'Tap Share, then "Add to Home Screen" to install'
                              : 'Install Exam Coach for quicker access',
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                      if (showInstallButton)
                        TextButton(
                          onPressed: () => controller.promptInstall(),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFC8932A),
                          ),
                          child: const Text('Install'),
                        ),
                      IconButton(
                        onPressed: () => setState(() => _dismissed = true),
                        icon: const Icon(Icons.close, color: Colors.white70, size: 18),
                        tooltip: 'Dismiss',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
