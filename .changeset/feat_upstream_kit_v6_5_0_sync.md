---
default: major
---

Sync with upstream @solana/kit v6.1.0 → v6.5.0 changes.

### solana_kit_errors (minor)

- Add new error codes: `failedToSendTransaction`, `failedToSendTransactions`, `signerWalletAccountCannotSignTransaction`, 8 new transaction error codes (`transactionCannotEncodeWithEmptyMessageBytes`, `transactionCannotDecodeEmptyTransactionBytes`, `transactionVersionZeroMustBeEncodedWithSignaturesFirst`, `transactionSignatureCountTooHighForTransactionBytes`, `transactionInvalidConfigMaskPriorityFeeBits`, `transactionInvalidNonceAccountIndex`, `transactionInvalidConfigValueKind`, `transactionInstructionHeadersPayloadsMismatch`), and 2 new codec error codes (`codecsInvalidPatternMatchValue`, `codecsInvalidPatternMatchBytes`).
- Capitalize all instruction error messages for consistency.
- Fix BORSH_IO_ERROR: remove stale `$encodedData` interpolation.
- Fix `instructionErrorUnknown` message: was empty, now `'The instruction failed with the error: $errorName'`.
- Update `transactionVersionNumberNotSupported` max supported version from 0 to 1.

### solana_kit_codecs_data_structures (minor)

- Add `getPatternMatchEncoder`, `getPatternMatchDecoder`, and `getPatternMatchCodec` functions for selecting codecs based on value/byte pattern matching.

### solana_kit_codecs_core (patch)

- Fix `containsBytes` to avoid unnecessary array slicing/cloning when using negative offsets matching the array length.
- Fix `addDecoderSentinel` to handle negative offsets properly.

### solana_kit_codecs_strings (patch)

- Fix `getBaseXDecoder` and `getBaseXResliceDecoder` to avoid unnecessary array slicing/cloning when using negative offsets matching the array length.

### solana_kit_signers (minor)

- Add `partiallySignTransactionWithSigners`, `signTransactionWithSigners`, and `signAndSendTransactionWithSigners` functions that accept a set of signers and a compiled `Transaction` directly, without requiring signers to be embedded in a transaction message.
- Add `assertContainsResolvableTransactionSendingSigner` to validate that a set of signers contains an unambiguously resolvable sending signer.
- The existing transaction message helpers now delegate to these new functions internally.

### solana_kit_instruction_plans (patch)

- Add `abortReason` and `transactionPlanResult` to the `instructionPlansFailedToExecuteTransactionPlan` error context.
