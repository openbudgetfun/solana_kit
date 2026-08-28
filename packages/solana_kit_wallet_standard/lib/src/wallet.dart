import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_wallet_standard/src/identifiers.dart';

/// A versioned capability exposed by a wallet.
abstract interface class WalletFeature {
  /// The semantic version of this feature contract.
  String get version;
}

/// A validated Wallet Standard icon data URI.
class WalletIcon {
  /// Parses an icon containing base64 SVG, WebP, PNG, or GIF data.
  factory WalletIcon(String dataUri) {
    final match = _pattern.firstMatch(dataUri);
    if (match == null) {
      throw FormatException('Invalid Wallet Standard icon data URI', dataUri);
    }
    final bytes = base64.decode(match.group(2)!);
    return WalletIcon._(dataUri, match.group(1)!, Uint8List.fromList(bytes));
  }

  const WalletIcon._(this.dataUri, this.mimeSubtype, this.bytes);

  static final _pattern = RegExp(
    r'^data:image/(svg\+xml|webp|png|gif);base64,([A-Za-z0-9+/]*={0,2})$',
  );

  /// The original data URI.
  final String dataUri;

  /// The image MIME subtype.
  final String mimeSubtype;

  /// Decoded image bytes.
  final Uint8List bytes;

  /// The complete MIME type.
  String get mimeType => 'image/$mimeSubtype';

  @override
  String toString() => dataUri;
}

/// An immutable account authorized by a Wallet Standard wallet.
class WalletAccount {
  /// Creates an account and validates its public metadata.
  WalletAccount({
    required this.address,
    required Uint8List publicKey,
    required List<String> chains,
    required List<String> features,
    this.label,
    this.icon,
  }) : publicKey = Uint8List.fromList(publicKey),
       chains = List.unmodifiable(chains),
       features = List.unmodifiable(features) {
    if (address.isEmpty) throw ArgumentError.value(address, 'address');
    if (publicKey.length != 32) {
      throw ArgumentError.value(publicKey.length, 'publicKey.length');
    }
    _validateIdentifiers(chains, 'chains');
    _validateIdentifiers(features, 'features');
  }

  /// The canonical display address for this account.
  final String address;

  /// The 32-byte public key.
  final Uint8List publicKey;

  /// Chains supported by the account.
  final List<String> chains;

  /// Feature identifiers supported by the account.
  final List<String> features;

  /// An optional human-readable account label.
  final String? label;

  /// An optional account icon.
  final WalletIcon? icon;
}

/// A wallet exposed to an application through Wallet Standard.
abstract interface class Wallet {
  /// The implemented Wallet Standard version.
  String get version;

  /// The wallet's canonical display name.
  String get name;

  /// The wallet's canonical icon.
  WalletIcon get icon;

  /// Chains supported by the wallet.
  List<String> get chains;

  /// Versioned features keyed by canonical identifier.
  Map<String, WalletFeature> get features;

  /// Accounts the application is currently authorized to use.
  List<WalletAccount> get accounts;
}

/// Type-safe feature inspection helpers.
extension WalletFeatureLookup on Wallet {
  /// Returns the feature named [identifier] when it has type [T].
  T? feature<T extends WalletFeature>(String identifier) {
    final value = features[identifier];
    return value is T ? value : null;
  }

  /// Whether the wallet exposes [identifier].
  bool supports(String identifier) => features.containsKey(identifier);
}

void _validateIdentifiers(List<String> identifiers, String name) {
  for (final identifier in identifiers) {
    if (!isWalletStandardIdentifier(identifier)) {
      throw ArgumentError.value(identifier, name);
    }
  }
}
