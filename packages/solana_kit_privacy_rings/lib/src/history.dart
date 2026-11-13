import 'dart:typed_data';

import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

import 'package:solana_kit_privacy_rings/src/exception.dart';
import 'package:solana_kit_privacy_rings/src/rpc/types.dart';

/// One page and the token that fetches the next one.
///
/// `Page` in `crates/solana_kit_privacy_rings/src/history.rs`. An empty
/// [paginationToken] ends the walk, the same as a missing token.
class HistoryPage<T> {
  /// Creates a page of [items].
  const HistoryPage({required this.items, this.paginationToken});

  /// Items on this page.
  final List<T> items;

  /// Continuation token. Null or empty ends the walk.
  final String? paginationToken;
}

/// Concatenates pages until the token runs out.
///
/// [nextPage] receives the previous token, or null for the first page.
/// The walk throws `history_truncated` when [maxPages] is exhausted and a
/// token remains, so a caller cannot treat a partial history as complete.
/// `maxPages` below 1 throws `invalid_request`. This is `collect_pages`.
Future<List<T>> collectPages<T>(
  Future<HistoryPage<T>> Function(String? token) nextPage, {
  required int maxPages,
}) async {
  if (maxPages < 1) {
    throw PrivacyRingsException(
      'maxPages must be at least 1',
      code: 'invalid_request',
    );
  }
  final items = <T>[];
  String? token;
  for (var page = 0; page < maxPages; page++) {
    final result = await nextPage(token);
    items.addAll(result.items);
    final next = result.paginationToken;
    if (next == null || next.isEmpty) return items;
    token = next;
  }
  throw PrivacyRingsException(
    'history still had a page after $maxPages pages',
    code: 'history_truncated',
  );
}

/// Decodes the base58 nullifiers published on shielded events.
///
/// `spent_nullifiers`. A nullifier that is not 32 decoded bytes throws
/// `invalid_length`. Duplicate values are returned once, in byte order.
List<Uint8List> spentNullifiers(List<ShieldedTransaction> events) {
  final spent = <String, Uint8List>{};
  for (final event in events) {
    for (final text in event.nullifiers) {
      final bytes = _nullifier(text);
      spent[_key(bytes)] = bytes;
    }
  }
  final values = spent.values.toList()..sort(_compare);
  return values;
}

Uint8List _nullifier(String text) {
  late List<int> decoded;
  try {
    decoded = getBase58Encoder().encode(text);
  } on Object {
    throw PrivacyRingsException(
      'nullifier is not base58',
      code: 'invalid_length',
    );
  }
  if (decoded.length != 32) {
    throw PrivacyRingsException(
      'nullifier is ${decoded.length} bytes, it takes 32',
      code: 'invalid_length',
    );
  }
  return Uint8List.fromList(decoded);
}

String _key(List<int> bytes) =>
    bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();

int _compare(List<int> left, List<int> right) {
  final length = left.length < right.length ? left.length : right.length;
  for (var i = 0; i < length; i++) {
    final order = left[i].compareTo(right[i]);
    if (order != 0) return order;
  }
  // Duplicates are removed before the sort, so equal keys are not compared.
  // coverage:ignore-start
  return left.length.compareTo(right.length);
  // coverage:ignore-end
}
