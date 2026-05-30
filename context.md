## Summary

I've successfully added tests to improve coverage for the `solana_kit_transaction_messages` package. Here's what was done:

### Tests Added (5 files modified)

1. **`test/equality_test.dart`** - Major additions:
   - `DurableNonceConfig.toString()` test
   - `DurableNonceLifetimeConstraint` equality/hashCode/identity tests
   - `MessageHeader` equality/hashCode/identity/different-type tests
   - `CompiledInstruction` equality/hashCode tests with null/non-null accountIndices/data
   - `AddressTableLookup` equality/hashCode/identity tests
   - `V1InstructionHeader` equality/hashCode/identity tests

2. **`test/transaction_message_extensions_test.dart`** - Added `prependInstructions()` test

3. **`test/v1_transaction_config_test.dart`** - Added empty config and same config identity tests

4. **`test/compress_transaction_message_test.dart`** - Added test for instruction with `accounts: null`

5. **`test/decompile_message_test.dart`** - Added tests for out-of-bounds `programAddressIndex` error path and empty `staticAccounts` error path

### Results

- ✅ **180 tests passing**, 0 failures
- ✅ **No dart analyze errors** (only info-level `prefer_const` suggestions remain)
- 📄 Findings written to `/Users/ifiokjr/Developer/projects/solana_kit/context.md`
