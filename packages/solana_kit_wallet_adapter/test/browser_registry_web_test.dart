@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:solana_kit_wallet_adapter/solana_kit_wallet_adapter.dart';
import 'package:solana_kit_wallet_standard/solana_kit_wallet_standard.dart';
import 'package:web/web.dart' as web;

void main() {
  test('discovers and operates a late Wallet Standard registration', () async {
    final fixture = _WalletFixture();
    final registry = createDefaultWalletRegistry(
      appIdentity: const WalletAppIdentity(name: 'Browser test'),
      chain: SolanaChainId.localnet,
    );
    await registry.initialize();

    web.window.dispatchEvent(
      web.CustomEvent(
        'wallet-standard:register-wallet',
        web.CustomEventInit(detail: fixture.register.toJS),
      ),
    );
    expect(registry.wallets, hasLength(1));
    final wallet = registry.wallets.single;
    expect(wallet.name, 'Browser test wallet');
    expect(wallet.chains, [SolanaChainId.localnet]);
    expect(wallet.accounts, isEmpty);

    final connect = wallet.feature<StandardConnectFeature>(
      StandardFeatureId.connect,
    )!;
    final connected = await connect.connect(
      const StandardConnectInput(silent: true),
    );
    expect(fixture.silent, isTrue);
    expect(connected.accounts.single.address, fixture.address);
    expect(wallet.accounts, connected.accounts);

    final signed = await wallet
        .feature<SolanaSignMessageFeature>(SolanaFeatureId.signMessage)!
        .signMessage([
          SolanaSignMessageInput(
            account: connected.accounts.single,
            message: Uint8List.fromList([1, 2, 3]),
          ),
        ]);
    expect(signed.single.signedMessage, [1, 2, 3]);
    expect(signed.single.signature, hasLength(64));

    var changed = false;
    final off = wallet
        .feature<StandardEventsFeature>(StandardFeatureId.events)!
        .onChange((change) => changed = change.accounts?.isEmpty ?? false);
    fixture.emitEmptyAccounts();
    expect(changed, isTrue);
    off();

    fixture.unregister();
    expect(registry.wallets, isEmpty);
    await registry.dispose();
  });
}

class _WalletFixture {
  _WalletFixture() {
    account
      ..['address'] = address.toJS
      ..['publicKey'] = Uint8List(32).toJS
      ..['chains'] = [SolanaChainId.localnet.toJS].toJS
      ..['features'] = [SolanaFeatureId.signMessage.toJS].toJS
      ..['label'] = 'Browser account'.toJS;

    final connect = JSObject()
      ..['version'] = '1.0.0'.toJS
      ..['connect'] = ((JSObject input) {
        silent = (input['silent']! as JSBoolean).toDart;
        final output = JSObject()..['accounts'] = [account].toJS;
        return Future<JSObject>.value(output).toJS;
      }).toJS;

    final events = JSObject()
      ..['version'] = '1.0.0'.toJS
      ..['on'] = ((JSString event, JSFunction callback) {
        changeListener = callback;
        return (() => changeListener = null).toJS;
      }).toJS;

    final signMessage = JSObject()
      ..['version'] = '1.1.0'.toJS
      ..['signMessage'] = ((JSObject input) {
        final output = JSObject()
          ..['signedMessage'] = input['message']
          ..['signature'] = Uint8List(64).toJS
          ..['signatureType'] = 'ed25519'.toJS;
        return Future<JSArray<JSObject>>.value([output].toJS).toJS;
      }).toJS;

    final features = JSObject()
      ..[StandardFeatureId.connect] = connect
      ..[StandardFeatureId.events] = events
      ..[SolanaFeatureId.signMessage] = signMessage;
    wallet
      ..['version'] = walletStandardVersion.toJS
      ..['name'] = 'Browser test wallet'.toJS
      ..['icon'] = _icon.toJS
      ..['chains'] = [SolanaChainId.localnet.toJS].toJS
      ..['features'] = features
      ..['accounts'] = <JSObject>[].toJS;
  }

  final JSObject account = JSObject();
  final String address = '11111111111111111111111111111111';
  JSFunction? changeListener;
  bool silent = false;
  JSFunction? _unregister;
  final JSObject wallet = JSObject();

  void register(JSObject api) {
    _unregister = api.callMethod<JSFunction>('register'.toJS, wallet);
  }

  void emitEmptyAccounts() {
    final change = JSObject()..['accounts'] = <JSObject>[].toJS;
    changeListener?.callAsFunction(null, change);
  }

  void unregister() => _unregister?.callAsFunction();
}

const _icon =
    'data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcv'
    'MjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxIDEiPjxyZWN0IHdpZHRoPSIxIiBoZWlnaHQ9'
    'IjEiLz48L3N2Zz4=';
