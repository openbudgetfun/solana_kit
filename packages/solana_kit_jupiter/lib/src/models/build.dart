/// A raw instruction payload returned by the `/swap/v2/build` path.
class JupiterInstructionPayload {
  /// Creates an instruction payload.
  const JupiterInstructionPayload({
    required this.programId,
    required this.accounts,
    required this.data,
  });

  /// Builds an instruction payload from the Swap API JSON body.
  factory JupiterInstructionPayload.fromJson(Map<String, Object?> json) =>
      JupiterInstructionPayload(
        programId: json['programId'] as String?,
        accounts: (json['accounts'] as List<Object?>?)
            ?.cast<Map<String, Object?>>()
            .map(
              (account) => JupiterAccountMetaPayload(
                pubkey: account['pubkey'] as String?,
                isSigner: account['isSigner'] as bool?,
                isWritable: account['isWritable'] as bool?,
              ),
            )
            .toList(growable: false),
        data: json['data'] as String?,
      );

  /// The program that owns the instruction.
  final String? programId;

  /// The accounts of the instruction, in order.
  final List<JupiterAccountMetaPayload>? accounts;

  /// The base64-encoded instruction data.
  final String? data;
}

/// An account entry inside a [JupiterInstructionPayload].
class JupiterAccountMetaPayload {
  /// Creates an account meta.
  const JupiterAccountMetaPayload({
    required this.pubkey,
    required this.isSigner,
    required this.isWritable,
  });

  /// Builds an account entry from the Swap API JSON body.
  factory JupiterAccountMetaPayload.fromJson(Map<String, Object?> json) =>
      JupiterAccountMetaPayload(
        pubkey: json['pubkey'] as String?,
        isSigner: json['isSigner'] as bool?,
        isWritable: json['isWritable'] as bool?,
      );

  /// The base58 account address.
  final String? pubkey;

  /// Whether the account must sign the transaction.
  final bool? isSigner;

  /// Whether the transaction writes to the account.
  final bool? isWritable;
}

/// The raw instruction set returned by `GET /swap/v2/build`.
///
/// Unlike the managed `/order` + `/execute` path, the build path returns raw
/// instructions that the caller assembles, signs, and lands themselves.
class JupiterBuildResponse {
  /// Creates a build response.
  const JupiterBuildResponse({
    required this.computeBudgetInstructions,
    required this.setupInstructions,
    required this.swapInstruction,
    required this.cleanupInstruction,
    required this.addressLookupTableAddresses,
    this.addressesByLookupTableAddress,
    this.otherInstructions,
    this.tipInstruction,
    this.blockhashWithMetadata,
  });

  /// Builds a build response from the Swap API JSON body.
  factory JupiterBuildResponse.fromJson(Map<String, Object?> json) {
    final lookupTables =
        (json['addressesByLookupTableAddress'] as Map<String, Object?>?)?.map(
          (key, value) => MapEntry(
            key,
            (value! as List<Object?>).cast<String>().toList(growable: false),
          ),
        );
    return JupiterBuildResponse(
      computeBudgetInstructions:
          (json['computeBudgetInstructions'] as List<Object?>?)
              ?.cast<Map<String, Object?>>()
              .map(JupiterInstructionPayload.fromJson)
              .toList(growable: false),
      setupInstructions: (json['setupInstructions'] as List<Object?>?)
          ?.cast<Map<String, Object?>>()
          .map(JupiterInstructionPayload.fromJson)
          .toList(growable: false),
      swapInstruction: json['swapInstruction'] == null
          ? null
          : JupiterInstructionPayload.fromJson(
              json['swapInstruction']! as Map<String, Object?>,
            ),
      cleanupInstruction: json['cleanupInstruction'] == null
          ? null
          : JupiterInstructionPayload.fromJson(
              json['cleanupInstruction']! as Map<String, Object?>,
            ),
      addressLookupTableAddresses:
          (json['addressLookupTableAddresses'] as List<Object?>?)
              ?.cast<String>()
              .toList(growable: false) ??
          lookupTables?.keys.toList(growable: false),
      addressesByLookupTableAddress: lookupTables,
      otherInstructions: (json['otherInstructions'] as List<Object?>?)
          ?.cast<Map<String, Object?>>()
          .map(JupiterInstructionPayload.fromJson)
          .toList(growable: false),
      tipInstruction: json['tipInstruction'] == null
          ? null
          : JupiterInstructionPayload.fromJson(
              json['tipInstruction']! as Map<String, Object?>,
            ),
      blockhashWithMetadata: json['blockhashWithMetadata'] == null
          ? null
          : JupiterBlockhashWithMetadata.fromJson(
              json['blockhashWithMetadata']! as Map<String, Object?>,
            ),
    );
  }

  /// Compute budget instructions (limit and priority fee), in order.
  final List<JupiterInstructionPayload>? computeBudgetInstructions;

  /// Setup instructions, such as ATA creation and de-escalation, in order.
  final List<JupiterInstructionPayload>? setupInstructions;

  /// The swap instruction itself.
  final JupiterInstructionPayload? swapInstruction;

  /// The optional cleanup instruction that closes temporary accounts.
  final JupiterInstructionPayload? cleanupInstruction;

  /// Additional instructions required by the returned route.
  final List<JupiterInstructionPayload>? otherInstructions;

  /// The optional transaction tip instruction.
  final JupiterInstructionPayload? tipInstruction;

  /// Resolved lookup table accounts, in their on-chain index order.
  final Map<String, List<String>>? addressesByLookupTableAddress;

  /// The blockhash and expiry for assembling the transaction.
  final JupiterBlockhashWithMetadata? blockhashWithMetadata;

  /// The address lookup tables referenced by the instructions.
  ///
  /// Includes the keys of [addressesByLookupTableAddress] for v2 responses.
  final List<String>? addressLookupTableAddresses;
}

/// The recent blockhash and expiry returned by the Swap API v2 build path.
class JupiterBlockhashWithMetadata {
  /// Creates blockhash metadata.
  const JupiterBlockhashWithMetadata({
    required this.blockhash,
    required this.lastValidBlockHeight,
  });

  /// Builds metadata from the Swap API JSON body.
  factory JupiterBlockhashWithMetadata.fromJson(Map<String, Object?> json) =>
      JupiterBlockhashWithMetadata(
        blockhash: (json['blockhash']! as List<Object?>).cast<int>().toList(
          growable: false,
        ),
        lastValidBlockHeight: BigInt.parse('${json['lastValidBlockHeight']}'),
      );

  /// The recent blockhash bytes.
  final List<int> blockhash;

  /// The last block height at which this blockhash is valid.
  final BigInt lastValidBlockHeight;
}
