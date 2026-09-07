import 'dart:async';
import 'dart:js_interop';

import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:web/web.dart' as web;

web.HTMLIFrameElement? _associationFrame;

/// Launches the wallet app from the browser.
///
/// Custom-scheme association URLs (`solana-wallet:/v1/associate/local?...`)
/// are launched through a hidden iframe; app-link URLs (https) use
/// `window.location.assign`. A page-blur event within 3 seconds confirms
/// that the wallet app opened, mirroring the reference JS implementation.
///
/// Throws a [SolanaError] with code [SolanaErrorCode.mwaSessionTimeout] when
/// the launch is not confirmed within the 3-second window (no wallet is
/// installed or the user dismissed the chooser), matching upstream's
/// association timeout behavior.
Future<void> launchWalletIntent(Uri intentUri) {
  final completer = Completer<void>();
  final timeoutId = 0;

  late final web.EventListener handleBlur;
  handleBlur = ((web.Event event) {
    web.window.removeEventListener('blur', handleBlur);
    web.window.clearTimeout(timeoutId);
    if (!completer.isCompleted) {
      completer.complete();
    }
  }).toJS;

  if (intentUri.scheme == 'https') {
    // App link / universal link: let the browser navigate, which launches
    // the wallet when installed or falls back to the webpage otherwise.
    web.window.location.assign(intentUri.toString());
  } else {
    // Custom scheme (eg. `solana-wallet:`): launch through a hidden iframe.
    // Browsers silently ignore unsupported custom schemes, which is why the
    // blur detector rejects the launch after 3 seconds.
    final frame =
        _associationFrame ??=
            web.document.createElement('iframe') as web.HTMLIFrameElement
              ..style.display = 'none';
    web.document.body!.appendChild(frame);
    frame.contentWindow!.location.href = intentUri.toString();
  }

  web.window.addEventListener('blur', handleBlur);
  web.window.setTimeout(
    ((web.Event event) {
      web.window.removeEventListener('blur', handleBlur);
      if (!completer.isCompleted) {
        completer.completeError(SolanaError(SolanaErrorCode.mwaSessionTimeout));
      }
    }).toJS,
    3000.toJS,
  );

  return completer.future;
}