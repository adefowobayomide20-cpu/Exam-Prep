// Bridges the browser's native PWA install flow to Flutter. Chrome/Edge/
// Android fire `beforeinstallprompt` once the site qualifies as installable;
// we capture it (instead of letting the browser show its own mini-infobar)
// so the Flutter-side install button controls exactly when the native
// prompt appears.
(function () {
  let deferredPrompt = null;

  window.addEventListener('beforeinstallprompt', (event) => {
    event.preventDefault();
    deferredPrompt = event;
    window.dispatchEvent(new CustomEvent('pwa-install-available'));
  });

  window.addEventListener('appinstalled', () => {
    deferredPrompt = null;
    window.dispatchEvent(new CustomEvent('pwa-installed'));
  });

  window.pwaInstallAvailable = function () {
    return deferredPrompt !== null;
  };

  // Covers both the standard `display-mode: standalone` (Chrome/Edge/
  // Android, and desktop installs) and iOS Safari's `navigator.standalone`,
  // which is how a site launched from the home screen icon reports itself.
  window.pwaIsStandalone = function () {
    return window.matchMedia('(display-mode: standalone)').matches ||
      window.navigator.standalone === true;
  };

  // iOS Safari never fires `beforeinstallprompt` and has no programmatic
  // install API at all — the only path is the user manually using the
  // Share sheet's "Add to Home Screen", so the button there can only ever
  // show instructions, never trigger an install itself.
  window.pwaIsIosSafari = function () {
    const ua = window.navigator.userAgent;
    const isIos = /iPad|iPhone|iPod/.test(ua) ||
      (ua.includes('Macintosh') && navigator.maxTouchPoints > 1);
    const isSafari = /Safari/.test(ua) && !/CriOS|FxiOS|EdgiOS|OPiOS/.test(ua);
    return isIos && isSafari;
  };

  window.pwaTriggerInstall = async function () {
    if (!deferredPrompt) {
      return 'unavailable';
    }
    const promptEvent = deferredPrompt;
    deferredPrompt = null;
    promptEvent.prompt();
    const choice = await promptEvent.userChoice;
    return choice.outcome;
  };
})();
