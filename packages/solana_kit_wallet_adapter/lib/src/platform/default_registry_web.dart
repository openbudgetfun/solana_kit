// coverage:ignore-file

import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:solana_kit_wallet_adapter/src/mobile_wallet.dart';
import 'package:solana_kit_wallet_standard/solana_kit_wallet_standard.dart';
import 'package:web/web.dart' as web;

/// Creates a registry backed by Wallet Standard browser events.
WalletRegistry createPlatformWalletRegistry({
  required WalletAppIdentity appIdentity,
  required String chain,
}) => BrowserWalletRegistry();

/// Discovers wallets registered on the browser `window`.
class BrowserWalletRegistry extends WalletRegistryController {
  final List<({JSObject raw, _BrowserWallet wallet})> _entries = [];
  JSFunction? _listener;
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    void handleEvent(web.Event event) {
      final detail = (event as web.CustomEvent).detail;
      if (detail == null || !detail.isA<JSFunction>()) return;
      (detail as JSFunction).callAsFunction(null, _api());
    }

    _listener = handleEvent.toJS;
    web.window.addEventListener(
      'wallet-standard:register-wallet',
      _listener,
    );
    web.window.dispatchEvent(
      web.CustomEvent(
        'wallet-standard:app-ready',
        web.CustomEventInit(detail: _api()),
      ),
    );
  }

  JSObject _api() {
    final api = JSObject();
    JSFunction registerWallet(JSObject raw) {
      final existing = _entries.where((entry) => entry.raw == raw).firstOrNull;
      if (existing != null) return (() {}).toJS;
      try {
        final wallet = _BrowserWallet(raw);
        _entries.add((raw: raw, wallet: wallet));
        register(wallet);
        return (() => _unregister(raw)).toJS;
      } on Object {
        return (() {}).toJS;
      }
    }

    api['register'] = registerWallet.toJS;
    return api;
  }

  void _unregister(JSObject raw) {
    final index = _entries.indexWhere((entry) => entry.raw == raw);
    if (index < 0) return;
    final entry = _entries.removeAt(index);
    unregister(entry.wallet);
  }

  @override
  Future<void> dispose() async {
    final listener = _listener;
    if (listener != null) {
      web.window.removeEventListener(
        'wallet-standard:register-wallet',
        listener,
      );
    }
    for (final entry in _entries) {
      entry.wallet.dispose();
    }
    _entries.clear();
    await super.dispose();
  }
}

class _BrowserWallet implements Wallet {
  _BrowserWallet(this.raw) {
    version = _string(raw, 'version');
    name = _string(raw, 'name');
    icon = WalletIcon(_string(raw, 'icon'));
    _refresh();
  }

  final JSObject raw;
  @override
  late final String version;

  @override
  late final String name;

  @override
  late final WalletIcon icon;
  List<String> _chains = const [];
  Map<String, WalletFeature> _features = const {};
  List<WalletAccount> _accounts = const [];
  final Map<String, JSObject> _accountObjects = {};
  void Function()? _eventUnsubscribe;

  @override
  List<String> get chains => _chains;

  @override
  Map<String, WalletFeature> get features => _features;

  @override
  List<WalletAccount> get accounts => _accounts;

  JSObject accountObject(WalletAccount account) {
    final rawAccount = _accountObjects[account.address];
    if (rawAccount != null) return rawAccount;
    throw const WalletStandardException(
      WalletStandardErrorCode.invalidRequest,
      'Wallet request contains an unauthorized account',
    );
  }

  void _refresh() {
    _chains = List.unmodifiable(_strings(raw, 'chains'));
    _accounts = _accountsFromRaw(_array<JSObject>(raw, 'accounts'));
    final rawFeatures = _object(raw, 'features');
    final features = <String, WalletFeature>{};
    for (final identifier in _keys(rawFeatures)) {
      final feature = rawFeatures[identifier];
      if (feature != null && feature.isA<JSObject>()) {
        features[identifier] = _feature(identifier, feature as JSObject);
      }
    }
    _features = Map.unmodifiable(features);
    _eventUnsubscribe?.call();
    _eventUnsubscribe =
        _features[StandardFeatureId.events] is StandardEventsFeature
        ? (_features[StandardFeatureId.events]! as StandardEventsFeature)
              .onChange(_handleChange)
        : null;
  }

  void _handleChange(StandardWalletChange change) {
    if (change.chains != null) _chains = List.unmodifiable(change.chains!);
    if (change.features != null) {
      _features = Map.unmodifiable(change.features!);
    }
    if (change.accounts != null) {
      _accounts = List.unmodifiable(change.accounts!);
    }
  }

  WalletFeature _feature(String identifier, JSObject feature) {
    return switch (identifier) {
      StandardFeatureId.connect => _BrowserConnect(this, feature),
      StandardFeatureId.disconnect => _BrowserDisconnect(feature),
      StandardFeatureId.events => _BrowserEvents(this, feature),
      SolanaFeatureId.signTransaction => _BrowserSignTransaction(this, feature),
      SolanaFeatureId.signAndSendTransaction => _BrowserSignAndSendTransaction(
        this,
        feature,
      ),
      SolanaFeatureId.signAndSendAllTransactions => _BrowserSignAndSendAll(
        this,
        feature,
      ),
      SolanaFeatureId.signMessage => _BrowserSignMessage(this, feature),
      SolanaFeatureId.signIn => _BrowserSignIn(this, feature),
      SolanaFeatureId.signOffchainMessage => _BrowserSignOffchainMessage(
        this,
        feature,
      ),
      _ => _BrowserFeature(feature),
    };
  }

  WalletAccount _account(JSObject value) => WalletAccount(
    address: _string(value, 'address'),
    publicKey: _bytes(value, 'publicKey'),
    chains: _strings(value, 'chains'),
    features: _strings(value, 'features'),
    label: _optionalString(value, 'label'),
    icon: switch (_optionalString(value, 'icon')) {
      final value? => WalletIcon(value),
      null => null,
    },
  );

  List<WalletAccount> _accountsFromRaw(Iterable<JSObject> values) {
    _accountObjects.clear();
    return List.unmodifiable(
      values.map((value) {
        final account = _account(value);
        _accountObjects[account.address] = value;
        return account;
      }),
    );
  }

  void dispose() => _eventUnsubscribe?.call();
}

class _BrowserFeature implements WalletFeature {
  const _BrowserFeature(this.raw);
  final JSObject raw;

  @override
  String get version => _string(raw, 'version');
}

class _BrowserConnect extends _BrowserFeature
    implements StandardConnectFeature {
  const _BrowserConnect(this.wallet, super.raw);
  final _BrowserWallet wallet;

  @override
  Future<StandardConnectOutput> connect([
    StandardConnectInput input = const StandardConnectInput(),
  ]) async {
    final request = JSObject()..['silent'] = input.silent.toJS;
    final output = await _promiseObject(raw, 'connect', [request]);
    wallet._accounts = wallet._accountsFromRaw(
      _array<JSObject>(output, 'accounts'),
    );
    return StandardConnectOutput(wallet.accounts);
  }
}

class _BrowserDisconnect extends _BrowserFeature
    implements StandardDisconnectFeature {
  const _BrowserDisconnect(super.raw);

  @override
  Future<void> disconnect() async {
    await _promiseAny(raw, 'disconnect');
  }
}

class _BrowserEvents extends _BrowserFeature implements StandardEventsFeature {
  const _BrowserEvents(this.wallet, super.raw);
  final _BrowserWallet wallet;

  @override
  void Function() onChange(
    void Function(StandardWalletChange change) listener,
  ) {
    void handle(JSObject value) {
      Map<String, WalletFeature>? features;
      if (value.has('features')) {
        final rawFeatures = _object(value, 'features');
        features = {};
        for (final identifier in _keys(rawFeatures)) {
          final feature = rawFeatures[identifier];
          if (feature != null && feature.isA<JSObject>()) {
            features[identifier] = wallet._feature(
              identifier,
              feature as JSObject,
            );
          }
        }
      }
      final accounts = value.has('accounts')
          ? wallet._accountsFromRaw(_array<JSObject>(value, 'accounts'))
          : null;
      listener(
        StandardWalletChange(
          chains: value.has('chains') ? _strings(value, 'chains') : null,
          features: features,
          accounts: accounts,
        ),
      );
    }

    final off = raw.callMethod<JSFunction>(
      'on'.toJS,
      'change'.toJS,
      handle.toJS,
    );
    // A closure is required because Wasm does not support interop tear-offs.
    // ignore: unnecessary_lambdas
    return () => off.callAsFunction();
  }
}

mixin _TransactionVersions on _BrowserFeature {
  List<SolanaTransactionVersion> get supportedTransactionVersions =>
      _array<JSAny?>(raw, 'supportedTransactionVersions').map((value) {
        if (value != null &&
            value.isA<JSString>() &&
            (value as JSString).toDart == 'legacy') {
          return SolanaTransactionVersion.legacy;
        }
        return SolanaTransactionVersion.version0;
      }).toList();
}

class _BrowserSignTransaction extends _BrowserFeature
    with _TransactionVersions
    implements SolanaSignTransactionFeature {
  const _BrowserSignTransaction(this.wallet, super.raw);
  final _BrowserWallet wallet;

  @override
  Future<List<SolanaSignTransactionOutput>> signTransaction(
    List<SolanaSignTransactionInput> inputs,
  ) async {
    final outputs = await _promiseObjects(
      raw,
      'signTransaction',
      inputs.map((input) => _transactionInput(wallet, input)).toList(),
    );
    return outputs
        .map(
          (output) =>
              SolanaSignTransactionOutput(_bytes(output, 'signedTransaction')),
        )
        .toList();
  }
}

class _BrowserSignAndSendTransaction extends _BrowserFeature
    with _TransactionVersions
    implements SolanaSignAndSendTransactionFeature {
  const _BrowserSignAndSendTransaction(this.wallet, super.raw);
  final _BrowserWallet wallet;

  @override
  Future<List<SolanaSignAndSendTransactionOutput>> signAndSendTransaction(
    List<SolanaSignAndSendTransactionInput> inputs,
  ) async {
    final outputs = await _promiseObjects(
      raw,
      'signAndSendTransaction',
      inputs.map((input) => _transactionInput(wallet, input)).toList(),
    );
    return outputs
        .map(
          (output) =>
              SolanaSignAndSendTransactionOutput(_bytes(output, 'signature')),
        )
        .toList();
  }
}

class _BrowserSignAndSendAll extends _BrowserFeature
    with _TransactionVersions
    implements SolanaSignAndSendAllTransactionsFeature {
  const _BrowserSignAndSendAll(this.wallet, super.raw);
  final _BrowserWallet wallet;

  @override
  Future<List<SolanaSignAndSendAllResult>> signAndSendAllTransactions(
    List<SolanaSignAndSendTransactionInput> inputs, {
    SolanaSignAndSendAllMode mode = SolanaSignAndSendAllMode.parallel,
  }) async {
    final request = JSObject()
      ..['transactions'] = inputs
          .map((input) => _transactionInput(wallet, input))
          .toList()
          .toJS
      ..['mode'] = mode.name.toJS;
    final outputs = await _promiseObjects(raw, 'signAndSendAllTransactions', [
      request,
    ]);
    return outputs.map((output) {
      if (_string(output, 'status') == 'fulfilled') {
        return SolanaSignAndSendAllSuccess(
          SolanaSignAndSendTransactionOutput(
            _bytes(_object(output, 'value'), 'signature'),
          ),
        );
      }
      return SolanaSignAndSendAllFailure(
        output['reason'].dartify() ?? 'Wallet rejected the transaction',
      );
    }).toList();
  }
}

class _BrowserSignMessage extends _BrowserFeature
    implements SolanaSignMessageFeature {
  const _BrowserSignMessage(this.wallet, super.raw);
  final _BrowserWallet wallet;

  @override
  Future<List<SolanaSignMessageOutput>> signMessage(
    List<SolanaSignMessageInput> inputs,
  ) async {
    final requests = inputs.map((input) {
      return JSObject()
        ..['account'] = wallet.accountObject(input.account)
        ..['message'] = input.message.toJS;
    }).toList();
    final outputs = await _promiseObjects(raw, 'signMessage', requests);
    return outputs
        .map(
          (output) => SolanaSignMessageOutput(
            signedMessage: _bytes(output, 'signedMessage'),
            signature: _bytes(output, 'signature'),
            signatureType: _optionalString(output, 'signatureType'),
          ),
        )
        .toList();
  }
}

class _BrowserSignIn extends _BrowserFeature implements SolanaSignInFeature {
  const _BrowserSignIn(this.wallet, super.raw);
  final _BrowserWallet wallet;

  @override
  Future<List<SolanaSignInOutput>> signIn(
    List<SolanaSignInInput> inputs,
  ) async {
    final requests = inputs.map((input) {
      final value = JSObject();
      _setString(value, 'domain', input.domain);
      _setString(value, 'address', input.address);
      _setString(value, 'statement', input.statement);
      _setString(value, 'uri', input.uri);
      _setString(value, 'version', input.version);
      _setString(value, 'chainId', input.chainId);
      _setString(value, 'nonce', input.nonce);
      _setString(value, 'issuedAt', input.issuedAt);
      _setString(value, 'expirationTime', input.expirationTime);
      _setString(value, 'notBefore', input.notBefore);
      _setString(value, 'requestId', input.requestId);
      if (input.resources != null) {
        value['resources'] = input.resources!
            .map((item) => item.toJS)
            .toList()
            .toJS;
      }
      return value;
    }).toList();
    final outputs = await _promiseObjects(raw, 'signIn', requests);
    return outputs
        .map(
          (output) => SolanaSignInOutput(
            account: wallet._account(_object(output, 'account')),
            signedMessage: _bytes(output, 'signedMessage'),
            signature: _bytes(output, 'signature'),
            signatureType: _optionalString(output, 'signatureType'),
          ),
        )
        .toList();
  }
}

class _BrowserSignOffchainMessage extends _BrowserFeature
    implements SolanaSignOffchainMessageFeature {
  const _BrowserSignOffchainMessage(this.wallet, super.raw);
  final _BrowserWallet wallet;

  @override
  List<int> get supportedMessageVersions => _array<JSNumber>(
    raw,
    'supportedMessageVersions',
  ).map((value) => value.toDartInt).toList();

  @override
  Future<List<SolanaSignOffchainMessageOutput>> signOffchainMessage(
    List<SolanaSignOffchainMessageInput> inputs,
  ) async {
    final requests = inputs.map((input) {
      return JSObject()
        ..['account'] = wallet.accountObject(input.account)
        ..['message'] = input.message.toJS
        ..['requiredSigners'] = input.requiredSigners
            .map((item) => item.toJS)
            .toList()
            .toJS;
    }).toList();
    final outputs = await _promiseObjects(raw, 'signOffchainMessage', requests);
    return outputs
        .map(
          (output) => SolanaSignOffchainMessageOutput(
            signedOffchainMessage: _bytes(output, 'signedOffchainMessage'),
            signature: _bytes(output, 'signature'),
            signatureType: _optionalString(output, 'signatureType'),
          ),
        )
        .toList();
  }
}

JSObject _transactionInput(
  _BrowserWallet wallet,
  SolanaSignTransactionInput input,
) {
  final value = JSObject()
    ..['account'] = wallet.accountObject(input.account)
    ..['transaction'] = input.transaction.toJS;
  _setString(value, 'chain', input.chain);
  final options = input.options;
  if (options != null) {
    final rawOptions = JSObject();
    _setString(
      rawOptions,
      'preflightCommitment',
      options.preflightCommitment?.name,
    );
    if (options.minContextSlot != null) {
      rawOptions['minContextSlot'] = options.minContextSlot!.toJS;
    }
    if (options is SolanaSignAndSendTransactionOptions) {
      _setString(rawOptions, 'commitment', options.commitment?.name);
      if (options.skipPreflight != null) {
        rawOptions['skipPreflight'] = options.skipPreflight!.toJS;
      }
      if (options.maxRetries != null) {
        rawOptions['maxRetries'] = options.maxRetries!.toJS;
      }
    }
    value['options'] = rawOptions;
  }
  return value;
}

Future<JSAny?> _promiseAny(
  JSObject target,
  String method, [
  List<JSAny?> arguments = const [],
]) =>
    target.callMethodVarArgs<JSPromise<JSAny?>>(method.toJS, arguments).toDart;

Future<JSObject> _promiseObject(
  JSObject target,
  String method, [
  List<JSAny?> arguments = const [],
]) => target
    .callMethodVarArgs<JSPromise<JSObject>>(method.toJS, arguments)
    .toDart;

Future<List<JSObject>> _promiseObjects(
  JSObject target,
  String method,
  List<JSObject> arguments,
) async {
  final output = await target
      .callMethodVarArgs<JSPromise<JSArray<JSObject>>>(
        method.toJS,
        arguments,
      )
      .toDart;
  return output.toDart;
}

List<String> _keys(JSObject value) =>
    _objectKeys(value).toDart.map((item) => item.toDart).toList();

List<T> _array<T extends JSAny?>(JSObject value, String property) =>
    (value[property]! as JSArray<T>).toDart;

JSObject _object(JSObject value, String property) =>
    value[property]! as JSObject;

String _string(JSObject value, String property) =>
    (value[property]! as JSString).toDart;

String? _optionalString(JSObject value, String property) {
  final item = value[property];
  return item != null && item.isA<JSString>()
      ? (item as JSString).toDart
      : null;
}

List<String> _strings(JSObject value, String property) =>
    _array<JSString>(value, property).map((item) => item.toDart).toList();

Uint8List _bytes(JSObject value, String property) =>
    Uint8List.fromList((value[property]! as JSUint8Array).toDart);

void _setString(JSObject value, String property, String? item) {
  if (item != null) value[property] = item.toJS;
}

@JS('Object.keys')
external JSArray<JSString> _objectKeys(JSObject value);
