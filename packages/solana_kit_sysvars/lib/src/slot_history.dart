import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';

import 'package:solana_kit_sysvars/src/sysvar.dart';

/// The bitvector discriminator value.
const int bitvecDiscriminator = 1;

/// Max number of bits in the bitvector.
///
/// The Solana SDK defines a constant `MAX_ENTRIES` representing the maximum
/// number of bits that can be represented by the bitvector in the
/// `SlotHistory` sysvar. This value is 1024 * 1024 = 1,048,576.
const int bitvecNumBits = 1024 * 1024;

/// The length of the bitvector in 64-bit blocks.
///
/// At 64 bits per block, this is 1024 * 1024 / 64 = 16,384.
const int bitvecLength = bitvecNumBits ~/ 64;

/// The size in bytes of the SlotHistory sysvar account data.
///
/// Computed as:
/// - 1 byte for the discriminator
/// - 8 bytes for the bitvector length (u64)
/// - [bitvecLength] * 8 bytes for the bitvector data
/// - 8 bytes for the number of bits (u64)
/// - 8 bytes for the next slot (u64)
const int sysvarSlotHistorySize = 1 + 8 + bitvecLength * 8 + 8 + 8; // 131,097

/// A bitvector of slots present over the last epoch.
@immutable
class SysvarSlotHistory {
  /// Creates a new [SysvarSlotHistory].
  const SysvarSlotHistory({required this.bits, required this.nextSlot});

  /// A vector of 64-bit numbers which, when their bits are strung together,
  /// represent a record of non-skipped slots.
  ///
  /// The bit in position (slot % MAX_ENTRIES) is 0 if the slot was skipped
  /// and 1 otherwise, valid only when the candidate slot is less than
  /// [nextSlot] and greater than or equal to `MAX_ENTRIES - nextSlot`.
  final List<BigInt> bits;

  /// The number of the slot one newer than tracked by the bitvector.
  final BigInt nextSlot;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SysvarSlotHistory &&
          runtimeType == other.runtimeType &&
          nextSlot == other.nextSlot &&
          _listEquals(bits, other.bits);

  @override
  int get hashCode => Object.hash(Object.hashAll(bits), nextSlot);

  @override
  String toString() =>
      'SysvarSlotHistory(bits: [${bits.length} elements], '
      'nextSlot: $nextSlot)';
}

bool _listEquals(List<BigInt> a, List<BigInt> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Memoized codec instances.
FixedSizeEncoder<BigInt>? _memoizedU64Encoder;
FixedSizeDecoder<BigInt>? _memoizedU64Decoder;
FixedSizeEncoder<List<BigInt>>? _memoizedU64ArrayEncoder;
FixedSizeDecoder<List<BigInt>>? _memoizedU64ArrayDecoder;

FixedSizeEncoder<BigInt> _getMemoizedU64Encoder() {
  return _memoizedU64Encoder ??= getU64Encoder();
}

FixedSizeDecoder<BigInt> _getMemoizedU64Decoder() {
  return _memoizedU64Decoder ??= getU64Decoder();
}

FixedSizeEncoder<List<BigInt>> _getMemoizedU64ArrayEncoder() {
  if (_memoizedU64ArrayEncoder != null) return _memoizedU64ArrayEncoder!;
  final codec = getArrayCodec<BigInt>(
    getU64Codec(),
    size: const FixedArraySize(bitvecLength),
  );
  _memoizedU64ArrayEncoder =
      encoderFromCodec(codec) as FixedSizeEncoder<List<BigInt>>;
  return _memoizedU64ArrayEncoder!;
}

FixedSizeDecoder<List<BigInt>> _getMemoizedU64ArrayDecoder() {
  if (_memoizedU64ArrayDecoder != null) return _memoizedU64ArrayDecoder!;
  final codec = getArrayCodec<BigInt>(
    getU64Codec(),
    size: const FixedArraySize(bitvecLength),
  );
  _memoizedU64ArrayDecoder =
      decoderFromCodec(codec) as FixedSizeDecoder<List<BigInt>>;
  return _memoizedU64ArrayDecoder!;
}

/// Returns a fixed-size encoder for the [SysvarSlotHistory] sysvar.
FixedSizeEncoder<SysvarSlotHistory> getSysvarSlotHistoryEncoder() {
  return FixedSizeEncoder<SysvarSlotHistory>(
    fixedSize: sysvarSlotHistorySize,
    write: (SysvarSlotHistory value, Uint8List bytes, int currentOffset) {
      var o = currentOffset;
      // First byte is the bitvector discriminator.
      bytes[o] = bitvecDiscriminator;
      o += 1;
      // Next 8 bytes are the bitvector length.
      _getMemoizedU64Encoder().write(BigInt.from(bitvecLength), bytes, o);
      o += 8;
      // Next `bitvecLength * 8` bytes are the bitvector.
      _getMemoizedU64ArrayEncoder().write(value.bits, bytes, o);
      o += bitvecLength * 8;
      // Next 8 bytes are the number of bits.
      _getMemoizedU64Encoder().write(BigInt.from(bitvecNumBits), bytes, o);
      o += 8;
      // Next 8 bytes are the next slot.
      _getMemoizedU64Encoder().write(value.nextSlot, bytes, o);
      return o + 8;
    },
  );
}

/// Returns a fixed-size decoder for the [SysvarSlotHistory] sysvar.
FixedSizeDecoder<SysvarSlotHistory> getSysvarSlotHistoryDecoder() {
  return FixedSizeDecoder<SysvarSlotHistory>(
    fixedSize: sysvarSlotHistorySize,
    read: (Uint8List bytes, int currentOffset) {
      var o = currentOffset;
      // Byte length should be exact.
      if (bytes.length != sysvarSlotHistorySize) {
        throw SolanaError(SolanaErrorCode.codecsInvalidByteLength, {
          'actual': bytes.length,
          'expected': sysvarSlotHistorySize,
        });
      }
      // First byte is the bitvector discriminator.
      final discriminator = bytes[o];
      o += 1;
      if (discriminator != bitvecDiscriminator) {
        throw SolanaError(SolanaErrorCode.codecsEnumDiscriminatorOutOfRange, {
          'actual': discriminator,
          'expected': bitvecDiscriminator,
        });
      }
      // Next 8 bytes are the bitvector length.
      final (bitVecLength, offsetAfterLen) = _getMemoizedU64Decoder().read(
        bytes,
        o,
      );
      o = offsetAfterLen;
      if (bitVecLength != BigInt.from(bitvecLength)) {
        throw SolanaError(SolanaErrorCode.codecsInvalidNumberOfItems, {
          'actual': bitVecLength,
          'codecDescription': 'SysvarSlotHistoryCodec',
          'expected': bitvecLength,
        });
      }
      // Next `bitvecLength * 8` bytes are the bitvector.
      final (bits, offsetAfterBits) = _getMemoizedU64ArrayDecoder().read(
        bytes,
        o,
      );
      o = offsetAfterBits;
      // Next 8 bytes are the number of bits.
      final (numBits, offsetAfterNumBits) = _getMemoizedU64Decoder().read(
        bytes,
        o,
      );
      o = offsetAfterNumBits;
      if (numBits != BigInt.from(bitvecNumBits)) {
        throw SolanaError(SolanaErrorCode.codecsInvalidNumberOfItems, {
          'actual': numBits,
          'codecDescription': 'SysvarSlotHistoryCodec',
          'expected': bitvecNumBits,
        });
      }
      // Next 8 bytes are the next slot.
      final (nextSlot, offsetAfterNextSlot) = _getMemoizedU64Decoder().read(
        bytes,
        o,
      );
      return (
        SysvarSlotHistory(bits: bits, nextSlot: nextSlot),
        offsetAfterNextSlot,
      );
    },
  );
}

/// Returns a fixed-size codec for the [SysvarSlotHistory] sysvar.
FixedSizeCodec<SysvarSlotHistory, SysvarSlotHistory>
getSysvarSlotHistoryCodec() {
  return combineCodec(
        getSysvarSlotHistoryEncoder(),
        getSysvarSlotHistoryDecoder(),
      )
      as FixedSizeCodec<SysvarSlotHistory, SysvarSlotHistory>;
}

/// Fetches the `SlotHistory` sysvar account using the provided RPC client.
Future<SysvarSlotHistory> fetchSysvarSlotHistory(
  Rpc rpc, {
  FetchAccountConfig? config,
}) async {
  final account = await fetchEncodedSysvarAccount(
    rpc,
    sysvarSlotHistoryAddress,
    config: config,
  );
  assertAccountExists(account);
  final decoded = decodeAccount(
    (account as ExistingAccount<Uint8List>).account,
    getSysvarSlotHistoryDecoder(),
  );
  return decoded.data;
}
