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
  });

  /// Builds a build response from the Swap API JSON body.
  factory JupiterBuildResponse.fromJson(Map<String, Object?> json) =>
      JupiterBuildResponse(
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
                .toList(growable: false),
      );

  /// Compute budget instructions (limit and priority fee), in order.
  final List<JupiterInstructionPayload>? computeBudgetInstructions;

  /// Setup instructions, such as ATA creation and de-escalation, in order.
  final List<JupiterInstructionPayload>? setupInstructions;

  /// The swap instruction itself.
  final JupiterInstructionPayload? swapInstruction;

  /// The optional cleanup instruction that closes temporary accounts.
  final JupiterInstructionPayload? cleanupInstruction;

  /// The address lookup tables referenced by the instructions.
  final List<String>? addressLookupTableAddresses;
}
