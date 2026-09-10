import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

// TODO: replace both with your real Google AdSense values once your site is
// approved (see the setup walkthrough): the client ID is your
// "ca-pub-XXXXXXXXXXXXXXXX" publisher ID, the slot ID comes from the ad
// unit you create in the AdSense dashboard.
const _adSenseClient = 'REPLACE_WITH_YOUR_ADSENSE_CLIENT_ID';
const _adSenseSlot = 'REPLACE_WITH_YOUR_ADSENSE_SLOT_ID';

int _viewCounter = 0;

/// Embeds a Google AdSense unit via a platform view, since Flutter web
/// renders to a canvas/WASM surface rather than the DOM — there's no way to
/// place a real ad "inside" the canvas the way you would with a normal
/// website, so this carves out an actual DOM element for AdSense's script
/// to fill. Requires the AdSense loader `<script>` tag already present in
/// web/index.html. See ad_banner.dart for why this file is only ever
/// compiled into the web build.
class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewCounter += 1;
    _viewType = 'adsense-banner-$_viewCounter';
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final container = web.document.createElement('div') as web.HTMLDivElement;

      final ins = web.document.createElement('ins') as web.HTMLElement;
      ins.className = 'adsbygoogle';
      ins.style.display = 'block';
      ins.setAttribute('data-ad-client', _adSenseClient);
      ins.setAttribute('data-ad-slot', _adSenseSlot);
      ins.setAttribute('data-ad-format', 'auto');
      ins.setAttribute('data-full-width-responsive', 'true');
      container.append(ins);

      // A freshly-created <script> only executes if it's inserted as an
      // actual element (not via innerHTML) — this is the standard snippet
      // AdSense's own docs have publishers place after each ad unit.
      final script = web.document.createElement('script') as web.HTMLScriptElement;
      script.text = '(adsbygoogle = window.adsbygoogle || []).push({});';
      container.append(script);

      return container;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: HtmlElementView(viewType: _viewType),
    );
  }
}
