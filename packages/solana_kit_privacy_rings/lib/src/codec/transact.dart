import 'dart:typed_data';

import 'package:solana_kit_privacy_rings/src/bytes.dart';
import 'package:solana_kit_privacy_rings/src/exception.dart';

/// Groth16 proof carried by a `transact` instruction.
///
/// `a` and `c` are compressed G1 points (32 bytes). `b` is the raw
/// big-endian G2 point (128 bytes). `TransactProof` in
/// `program-libs/interface/src/instruction/instruction_data/transact.rs`.
class TransactProof {
  /// Creates a proof from the on-wire point bytes.
  TransactProof({
    required List<int> a,
    required List<int> b,
    required List<int> c,
  }) : a = copyBytes(a, 32, 'proof.a'),
       b = copyBytes(b, 128, 'proof.b'),
       c = copyBytes(c, 32, 'proof.c');

  /// A zero proof, used when a caller attaches the real proof later.
  ///
  /// The program rejects this value. It exists so a caller can fill the
  /// wire format before [TransactInstructionData.withProof] replaces it
  /// with the prover's proof.
  factory TransactProof.zeroed() => TransactProof(
    a: Uint8List(32),
    b: Uint8List(128),
    c: Uint8List(32),
  );

  /// Compressed G1 point `a`.
  final Uint8List a;

  /// Uncompressed G2 point `b`.
  final Uint8List b;

  /// Compressed G1 point `c`.
  final Uint8List c;
}

/// Root-history positions of one input tree. `TreeContext`.
class TreeContext {
  /// Creates a tree context.
  const TreeContext({
    required this.utxoTreeRootIndex,
    required this.nullifierTreeRootIndex,
  });

  /// UTXO-tree root history index. `0xffff` means no UTXO root.
  final int utxoTreeRootIndex;

  /// Nullifier-tree root history index.
  final int nullifierTreeRootIndex;
}

/// One spent input. `InputUtxo`.
class InputUtxo {
  /// Creates an input.
  InputUtxo({required List<int> nullifierHash, required this.treeIndex})
    : nullifierHash = copyBytes(nullifierHash, 32, 'nullifierHash') {
    if (treeIndex < 0 || treeIndex > 0xff) {
      throw PrivacyRingsException(
        'treeIndex is outside 0..255',
        code: 'integer_range',
      );
    }
  }

  /// Nullifier of the spent note.
  final Uint8List nullifierHash;

  /// Index into [TransactInstructionData.treeContexts].
  final int treeIndex;
}

/// Public SOL or SPL movement inside a `transact`.
sealed class InterfaceTransfer {
  const InterfaceTransfer(this.amount);

  /// Amount in base units. The program rejects zero.
  final BigInt amount;
}

/// SOL moving from a public balance into the pool.
class SolDepositTransfer extends InterfaceTransfer {
  /// Creates a SOL deposit leg.
  SolDepositTransfer(super.amount);
}

/// SOL moving from the pool to a public recipient.
class SolWithdrawalTransfer extends InterfaceTransfer {
  /// Creates a SOL withdrawal leg.
  SolWithdrawalTransfer(super.amount);
}

/// SPL or Token-2022 moving from a public account into the pool.
class SplDepositTransfer extends InterfaceTransfer {
  /// Creates an SPL deposit leg.
  SplDepositTransfer(super.amount, this.splInterfaceBump);

  /// Canonical bump of the mint's SPL interface PDA.
  final int splInterfaceBump;
}

/// SPL or Token-2022 moving from the pool to a public token account.
class SplWithdrawalTransfer extends InterfaceTransfer {
  /// Creates an SPL withdrawal leg.
  SplWithdrawalTransfer(super.amount, this.splInterfaceBump);

  /// Canonical bump of the mint's SPL interface PDA.
  final int splInterfaceBump;
}

/// How an output's owner tag is carried.
sealed class OwnerTag {
  const OwnerTag();
}

/// The 32-byte tag is embedded in the instruction.
class InlineOwnerTag extends OwnerTag {
  /// Creates an inline owner tag.
  InlineOwnerTag(List<int> value) : value = copyBytes(value, 32, 'ownerTag');

  /// Tag bytes.
  final Uint8List value;
}

/// The tag is the account at [index] in the instruction account list.
class AccountOwnerTag extends OwnerTag {
  /// Creates an account-index owner tag.
  AccountOwnerTag(this.index) {
    if (index < 0 || index > 0xff) {
      throw PrivacyRingsException(
        'owner tag account index is outside 0..255',
        code: 'integer_range',
      );
    }
  }

  /// Index into the instruction's account list.
  final int index;
}

/// One output slot.
class TransactOutput {
  /// Creates an output slot.
  TransactOutput({
    required List<int> utxoHash,
    required this.ownerTag,
    List<int>? data,
  }) : utxoHash = copyBytes(utxoHash, 32, 'utxoHash'),
       data = data == null ? null : Uint8List.fromList(data) {
    if (this.data != null && this.data!.length > 0xffff) {
      throw PrivacyRingsException(
        'output data is longer than 65535 bytes',
        code: 'invalid_length',
      );
    }
  }

  /// Output commitment.
  final Uint8List utxoHash;

  /// Owner tag published with the commitment.
  final OwnerTag ownerTag;

  /// Optional ciphertext. Null marks a slot covered by an earlier bundle.
  final Uint8List? data;
}

/// A ciphertext that is not bound to an output commitment.
class TransactMessage {
  /// Creates a message.
  TransactMessage({required List<int> viewTag, required List<int> data})
    : viewTag = copyBytes(viewTag, 32, 'message.viewTag'),
      data = Uint8List.fromList(data) {
    if (this.data.length > 0xffff) {
      throw PrivacyRingsException(
        'message data is longer than 65535 bytes',
        code: 'invalid_length',
      );
    }
  }

  /// Indexer view tag.
  final Uint8List viewTag;

  /// Ciphertext bytes.
  final Uint8List data;
}

/// BSB22 commitment pair inside a circuit id.
class Bsb22Commitment {
  /// Creates a commitment pair.
  Bsb22Commitment({
    required List<int> commitment,
    required List<int> commitmentPok,
  }) : commitment = copyBytes(commitment, 32, 'commitment'),
       commitmentPok = copyBytes(commitmentPok, 32, 'commitmentPok');

  /// Commitment bytes.
  final Uint8List commitment;

  /// Proof-of-knowledge bytes.
  final Uint8List commitmentPok;
}

/// One cache write slot. `0xff, 0xff` is the unused sentinel.
class CacheWriteSlot {
  /// Creates a cache write slot.
  const CacheWriteSlot({required this.output, required this.slot});

  /// Output index.
  final int output;

  /// Cache slot.
  final int slot;
}

/// Cache selection carried by a cached circuit id.
class CacheAccess {
  /// Creates a cache selection. [writeSlots] must contain 16 entries.
  CacheAccess({
    required this.readBitmap,
    required List<CacheWriteSlot> writeSlots,
  }) : writeSlots = List<CacheWriteSlot>.unmodifiable(writeSlots) {
    if (readBitmap.isNegative || readBitmap.bitLength > 64) {
      throw PrivacyRingsException(
        'readBitmap is outside 0..2^64-1',
        code: 'integer_range',
      );
    }
    if (this.writeSlots.length != 16) {
      throw PrivacyRingsException(
        'cache writeSlots must contain 16 entries',
        code: 'invalid_length',
      );
    }
  }

  /// Bitmap of inputs read from the cache.
  final BigInt readBitmap;

  /// Sixteen write slots, unused ones set to `0xff, 0xff`.
  final List<CacheWriteSlot> writeSlots;
}

/// `CircuitId` wire value.
///
/// Tags match `circuitTag` in `sdk-libs/ts/src/interface/codecs/index.ts`.
class CircuitId {
  /// Creates a circuit id.
  CircuitId({
    required this.kind,
    required this.inputs,
    required this.outputs,
    required this.publicAssetSlots,
    this.eddsa,
    this.anonymous,
    this.cacheAccess,
  }) {
    if (kind < 0 || kind > 0xffff) {
      throw PrivacyRingsException(
        'circuit kind is outside 0..65535',
        code: 'integer_range',
      );
    }
    for (final entry in {
      'inputs': inputs,
      'outputs': outputs,
      'publicAssetSlots': publicAssetSlots,
    }.entries) {
      if (entry.value < 0 || entry.value > 0xff) {
        throw PrivacyRingsException(
          '${entry.key} is outside 0..255',
          code: 'integer_range',
        );
      }
    }
  }

  /// Confidential Ed25519 signer, tag 0. No proof-data payload.
  factory CircuitId.confidentialSigner({
    required int inputs,
    required int outputs,
    required int publicAssetSlots,
  }) => CircuitId(
    kind: 0,
    inputs: inputs,
    outputs: outputs,
    publicAssetSlots: publicAssetSlots,
  );

  /// u16 tag.
  final int kind;

  /// Real and padding inputs the circuit shape publishes.
  final int inputs;

  /// Outputs the circuit shape publishes.
  final int outputs;

  /// Public asset slots. The protocol uses 3.
  final int publicAssetSlots;

  /// Present for tags 7 and 8.
  final ({Bsb22Commitment commitment, Uint8List ownerPk})? eddsa;

  /// Present for tags 3 and 6.
  final ({Bsb22Commitment commitment, Uint8List? defaultOwnerTag})? anonymous;

  /// Present for cached tags 4, 5, 6, and 8.
  final CacheAccess? cacheAccess;
}

/// `TransactIxData` without the leading instruction tag.
class TransactInstructionData {
  /// Creates transact instruction data.
  TransactInstructionData({
    required this.expiryUnixTs,
    required List<int> txViewingPk,
    required List<int> salt,
    required this.interfaceTransfers,
    required this.outputs,
    required this.messages,
    required List<int> privateTxHash,
    required this.circuit,
    required this.proof,
    required this.inputs,
    required this.treeContexts,
    List<int>? dataHash,
    List<int>? ringDataHash,
  }) : txViewingPk = copyBytes(txViewingPk, 33, 'txViewingPk'),
       salt = copyBytes(salt, 16, 'salt'),
       dataHash = dataHash == null ? null : copyBytes(dataHash, 32, 'dataHash'),
       ringDataHash = ringDataHash == null
           ? null
           : copyBytes(ringDataHash, 32, 'ringDataHash'),
       privateTxHash = copyBytes(privateTxHash, 32, 'privateTxHash') {
    if (expiryUnixTs.isNegative || expiryUnixTs.bitLength > 64) {
      throw PrivacyRingsException(
        'expiryUnixTs is outside 0..2^64-1',
        code: 'integer_range',
      );
    }
    if (interfaceTransfers.length > 32) {
      throw PrivacyRingsException(
        'more than 32 interface transfers',
        code: 'too_many_transfers',
      );
    }
    for (final transfer in interfaceTransfers) {
      if (transfer.amount.isNegative || transfer.amount.bitLength > 64) {
        throw PrivacyRingsException(
          'interface transfer amount is outside 0..2^64-1',
          code: 'integer_range',
        );
      }
      if (transfer.amount == BigInt.zero) {
        throw PrivacyRingsException(
          'interface transfer amount is zero',
          code: 'zero_transfer',
        );
      }
    }
  }

  /// Unix timestamp after which the transaction is expired.
  final BigInt expiryUnixTs;

  /// Tagged X25519 key shared by every output ciphertext.
  final Uint8List txViewingPk;

  /// Per-transaction encryption salt.
  final Uint8List salt;

  /// Public settlement legs.
  final List<InterfaceTransfer> interfaceTransfers;

  /// Optional external data digest.
  final Uint8List? dataHash;

  /// Optional ring data digest.
  final Uint8List? ringDataHash;

  /// Outputs in tree-append order.
  final List<TransactOutput> outputs;

  /// Ciphertexts not bound to an output.
  final List<TransactMessage> messages;

  /// Private transaction hash.
  final Uint8List privateTxHash;

  /// Circuit shape and proof-data payload.
  final CircuitId circuit;

  /// Groth16 proof.
  final TransactProof proof;

  /// Spent notes.
  final List<InputUtxo> inputs;

  /// One context per input tree, in account order.
  final List<TreeContext> treeContexts;

  /// Returns a copy that uses [proof].
  TransactInstructionData withProof(TransactProof proof) {
    return TransactInstructionData(
      expiryUnixTs: expiryUnixTs,
      txViewingPk: txViewingPk,
      salt: salt,
      interfaceTransfers: interfaceTransfers,
      dataHash: dataHash,
      ringDataHash: ringDataHash,
      outputs: outputs,
      messages: messages,
      privateTxHash: privateTxHash,
      circuit: circuit,
      proof: proof,
      inputs: inputs,
      treeContexts: treeContexts,
    );
  }
}

void _writeInterfaceTransfer(ByteWriter writer, InterfaceTransfer value) {
  final (int tag, int? bump) = switch (value) {
    SolDepositTransfer() => (0, null),
    SolWithdrawalTransfer() => (1, null),
    SplDepositTransfer(:final splInterfaceBump) => (2, splInterfaceBump),
    SplWithdrawalTransfer(:final splInterfaceBump) => (3, splInterfaceBump),
  };
  writer
    ..u8(tag, 'interfaceTransfer.kind')
    ..u64(value.amount, 'interfaceTransfer.amount');
  if (bump != null) {
    writer.u8(bump, 'interfaceTransfer.splInterfaceBump');
  }
}

void _writeOwnerTag(ByteWriter writer, OwnerTag value) {
  switch (value) {
    case InlineOwnerTag(:final value):
      writer
        ..u8(0, 'ownerTag.kind')
        ..bytes(value, length: 32, name: 'ownerTag.value');
    case AccountOwnerTag(:final index):
      writer
        ..u8(1, 'ownerTag.kind')
        ..u8(index, 'ownerTag.index');
  }
}

void _writeBsb22(ByteWriter writer, Bsb22Commitment value) {
  writer
    ..bytes(value.commitment, length: 32, name: 'commitment')
    ..bytes(value.commitmentPok, length: 32, name: 'commitmentPok');
}

void _writeCircuit(ByteWriter writer, CircuitId value) {
  writer
    ..u16(value.kind, 'circuit.kind')
    ..u8(value.inputs, 'circuit.inputs')
    ..u8(value.outputs, 'circuit.outputs')
    ..u8(value.publicAssetSlots, 'circuit.publicAssetSlots');
  if (value.kind == 7 || value.kind == 8) {
    final eddsa = value.eddsa;
    if (eddsa == null) {
      throw PrivacyRingsException(
        'confidential EdDSA circuit is missing proof data',
        code: 'invalid_circuit',
      );
    }
    _writeBsb22(writer, eddsa.commitment);
    writer.bytes(eddsa.ownerPk, length: 32, name: 'ownerPk');
  }
  if (value.kind == 3 || value.kind == 6) {
    final anonymous = value.anonymous;
    if (anonymous == null) {
      throw PrivacyRingsException(
        'anonymous circuit is missing proof data',
        code: 'invalid_circuit',
      );
    }
    _writeBsb22(writer, anonymous.commitment);
    final tag = anonymous.defaultOwnerTag;
    writer
      ..u8(tag == null ? 0 : 1, 'defaultOwnerTag')
      ..bytes(tag ?? Uint8List(32), length: 32, name: 'defaultOwnerTag');
  }
  const cached = {4, 5, 6, 8};
  if (cached.contains(value.kind)) {
    final cache = value.cacheAccess;
    if (cache == null) {
      throw PrivacyRingsException(
        'cached circuit is missing cache access',
        code: 'invalid_circuit',
      );
    }
    writer.u64(cache.readBitmap, 'readBitmap');
    for (final slot in cache.writeSlots) {
      writer
        ..u8(slot.output, 'writeSlot.output')
        ..u8(slot.slot, 'writeSlot.slot');
    }
  }
}

/// Encodes [value] the way `encodeTransactInstructionData` does.
Uint8List encodeTransactInstructionData(TransactInstructionData value) {
  final writer = ByteWriter()
    ..u64(value.expiryUnixTs, 'expiryUnixTs')
    ..bytes(value.txViewingPk, length: 33, name: 'txViewingPk')
    ..bytes(value.salt, length: 16, name: 'salt')
    ..u8(value.interfaceTransfers.length, 'interfaceTransfers.length');
  for (final transfer in value.interfaceTransfers) {
    _writeInterfaceTransfer(writer, transfer);
  }
  writer
    ..option(value.dataHash, (output, hash) {
      output.bytes(hash, length: 32, name: 'dataHash');
    })
    ..option(value.ringDataHash, (output, hash) {
      output.bytes(hash, length: 32, name: 'ringDataHash');
    })
    ..u8(value.outputs.length, 'outputs.length');
  for (final output in value.outputs) {
    writer.bytes(output.utxoHash, length: 32, name: 'output.utxoHash');
    _writeOwnerTag(writer, output.ownerTag);
    writer.option(output.data, (encoded, data) {
      encoded
        ..u16(data.length, 'output.data.length')
        ..bytes(data);
    });
  }
  writer.u8(value.messages.length, 'messages.length');
  for (final message in value.messages) {
    writer
      ..bytes(message.viewTag, length: 32, name: 'message.viewTag')
      ..u16(message.data.length, 'message.data.length')
      ..bytes(message.data);
  }
  writer.bytes(value.privateTxHash, length: 32, name: 'privateTxHash');
  _writeCircuit(writer, value.circuit);
  writer
    ..bytes(value.proof.a, length: 32, name: 'proof.a')
    ..bytes(value.proof.b, length: 128, name: 'proof.b')
    ..bytes(value.proof.c, length: 32, name: 'proof.c')
    ..u8(value.inputs.length, 'inputs.length');
  for (final input in value.inputs) {
    writer
      ..bytes(input.nullifierHash, length: 32, name: 'nullifierHash')
      ..u8(input.treeIndex, 'treeIndex');
  }
  writer.u8(value.treeContexts.length, 'treeContexts.length');
  for (final context in value.treeContexts) {
    writer
      ..u16(context.utxoTreeRootIndex, 'utxoTreeRootIndex')
      ..u16(context.nullifierTreeRootIndex, 'nullifierTreeRootIndex');
  }
  return writer.finish();
}

InterfaceTransfer _readInterfaceTransfer(ByteReader reader) {
  final kind = reader.u8('interfaceTransfer.kind');
  final amount = reader.u64('interfaceTransfer.amount');
  if (amount == BigInt.zero) {
    throw PrivacyRingsException(
      'interface transfer amount is zero',
      code: 'zero_transfer',
    );
  }
  return switch (kind) {
    0 => SolDepositTransfer(amount),
    1 => SolWithdrawalTransfer(amount),
    2 => SplDepositTransfer(amount, reader.u8('splInterfaceBump')),
    3 => SplWithdrawalTransfer(amount, reader.u8('splInterfaceBump')),
    _ => throw PrivacyRingsException(
      'unknown interface transfer kind $kind',
      code: 'invalid_discriminator',
    ),
  };
}

OwnerTag _readOwnerTag(ByteReader reader) {
  final kind = reader.u8('ownerTag.kind');
  if (kind == 0) return InlineOwnerTag(reader.bytes(32, 'ownerTag'));
  if (kind == 1) return AccountOwnerTag(reader.u8('ownerTag.index'));
  throw PrivacyRingsException(
    'unknown owner tag kind $kind',
    code: 'invalid_discriminator',
  );
}

Bsb22Commitment _readBsb22(ByteReader reader) {
  return Bsb22Commitment(
    commitment: reader.bytes(32, 'commitment'),
    commitmentPok: reader.bytes(32, 'commitmentPok'),
  );
}

CircuitId _readCircuit(ByteReader reader) {
  final kind = reader.u16('circuit.kind');
  final inputs = reader.u8('circuit.inputs');
  final outputs = reader.u8('circuit.outputs');
  final publicAssetSlots = reader.u8('circuit.publicAssetSlots');
  ({Bsb22Commitment commitment, Uint8List ownerPk})? eddsa;
  ({Bsb22Commitment commitment, Uint8List? defaultOwnerTag})? anonymous;
  if (kind == 7 || kind == 8) {
    eddsa = (
      commitment: _readBsb22(reader),
      ownerPk: reader.bytes(32, 'ownerPk'),
    );
  }
  if (kind == 3 || kind == 6) {
    final commitment = _readBsb22(reader);
    final present = reader.flag('defaultOwnerTag');
    final bytes = reader.bytes(32, 'defaultOwnerTag');
    anonymous = (
      commitment: commitment,
      defaultOwnerTag: present ? bytes : null,
    );
  }
  CacheAccess? cache;
  if ({4, 5, 6, 8}.contains(kind)) {
    final bitmap = reader.u64('readBitmap');
    final slots = List<CacheWriteSlot>.generate(
      16,
      (_) =>
          CacheWriteSlot(output: reader.u8('output'), slot: reader.u8('slot')),
    );
    cache = CacheAccess(readBitmap: bitmap, writeSlots: slots);
  }
  return CircuitId(
    kind: kind,
    inputs: inputs,
    outputs: outputs,
    publicAssetSlots: publicAssetSlots,
    eddsa: eddsa,
    anonymous: anonymous,
    cacheAccess: cache,
  );
}

/// Decodes bytes produced by [encodeTransactInstructionData].
TransactInstructionData decodeTransactInstructionData(Uint8List bytes) {
  final reader = ByteReader(bytes);
  final expiry = reader.u64('expiryUnixTs');
  final txViewingPk = reader.bytes(33, 'txViewingPk');
  final salt = reader.bytes(16, 'salt');
  final transfers = List<InterfaceTransfer>.generate(
    reader.u8('interfaceTransfers.length'),
    (_) => _readInterfaceTransfer(reader),
  );
  final dataHash = reader.option(() => reader.bytes(32, 'dataHash'));
  final ringDataHash = reader.option(() => reader.bytes(32, 'ringDataHash'));
  final outputs = List<TransactOutput>.generate(reader.u8('outputs.length'), (
    _,
  ) {
    final hash = reader.bytes(32, 'utxoHash');
    final tag = _readOwnerTag(reader);
    final data = reader.option(
      () => reader.bytes(reader.u16('output.data.length'), 'output.data'),
    );
    return TransactOutput(utxoHash: hash, ownerTag: tag, data: data);
  });
  final messages = List<TransactMessage>.generate(
    reader.u8('messages.length'),
    (_) => TransactMessage(
      viewTag: reader.bytes(32, 'viewTag'),
      data: reader.bytes(reader.u16('message.length'), 'message'),
    ),
  );
  final privateTxHash = reader.bytes(32, 'privateTxHash');
  final circuit = _readCircuit(reader);
  final proof = TransactProof(
    a: reader.bytes(32, 'proof.a'),
    b: reader.bytes(128, 'proof.b'),
    c: reader.bytes(32, 'proof.c'),
  );
  final inputs = List<InputUtxo>.generate(
    reader.u8('inputs.length'),
    (_) => InputUtxo(
      nullifierHash: reader.bytes(32, 'nullifier'),
      treeIndex: reader.u8('treeIndex'),
    ),
  );
  final contexts = List<TreeContext>.generate(
    reader.u8('treeContexts.length'),
    (_) => TreeContext(
      utxoTreeRootIndex: reader.u16('utxoTreeRootIndex'),
      nullifierTreeRootIndex: reader.u16('nullifierTreeRootIndex'),
    ),
  );
  reader.done();
  return TransactInstructionData(
    expiryUnixTs: expiry,
    txViewingPk: txViewingPk,
    salt: salt,
    interfaceTransfers: transfers,
    dataHash: dataHash,
    ringDataHash: ringDataHash,
    outputs: outputs,
    messages: messages,
    privateTxHash: privateTxHash,
    circuit: circuit,
    proof: proof,
    inputs: inputs,
    treeContexts: contexts,
  );
}
