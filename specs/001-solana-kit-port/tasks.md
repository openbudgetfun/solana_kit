# Tasks: Solana Kit Dart SDK — Full Port

**Input**: Design documents from `/specs/001-solana-kit-port/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/package-api-surface.md

**Tests**: Included — FR-012 requires porting all 380+ test files from the upstream SDK.

**Organization**: Tasks are grouped by user story. Due to the bottom-up dependency graph, US3 (codecs) must complete before US1 (transactions) can begin. Within each phase, packages follow the layer order from plan.md.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files/packages, no dependencies)
- **[Story]**: Which user story this task belongs to (US1–US5)
- File paths reference: TS source in `.repos/kit/packages/`, Dart target in `packages/`

## Path Conventions

- **TS source**: `.repos/kit/packages/{ts-package}/src/`
- **TS tests**: `.repos/kit/packages/{ts-package}/src/__tests__/`
- **Dart source**: `packages/solana_kit_{name}/lib/src/`
- **Dart tests**: `packages/solana_kit_{name}/test/`
- **Dart barrel**: `packages/solana_kit_{name}/lib/solana_kit_{name}.dart`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Verify workspace and reference repos are ready for implementation

- [x] T001 Verify all 37 scaffolded packages resolve with `dart pub get` in `packages/`
- [x] T002 Clone/update reference repos with `clone:repos` and verify `.repos/kit/` and `.repos/espresso-cash-public/` are present

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Layer 1 utility packages that all codec and higher-level packages depend on

**CRITICAL**: No user story work can begin until this phase is complete

- [x] T003 Implement `pipe()` function porting from `.repos/kit/packages/functional/src/` to `packages/solana_kit_functional/lib/src/`
- [x] T004 Port tests for solana_kit_functional from `.repos/kit/packages/functional/src/__tests__/` to `packages/solana_kit_functional/test/`
- [x] T005 [P] Implement deterministic JSON stringification porting from `.repos/kit/packages/fast-stable-stringify/src/` to `packages/solana_kit_fast_stable_stringify/lib/src/`
- [x] T006 [P] Port tests for solana_kit_fast_stable_stringify from `.repos/kit/packages/fast-stable-stringify/src/__tests__/` to `packages/solana_kit_fast_stable_stringify/test/`

**Checkpoint**: Foundation utilities ready — codec implementation can now begin

---

## Phase 3: User Story 3 — Encode and Decode Solana Data Structures (Priority: P2) Foundation

**Goal**: Provide a composable codec system supporting all Solana primitive types, strings, and data structures. Even though P2, codecs are the foundation for ALL other user stories and must be completed first.

**Independent Test**: `melos test --scope="solana_kit_codecs*" --scope="solana_kit_options"` — all codec packages pass their full ported test suites; encode/decode round-trips produce byte-identical output vs upstream TS SDK.

### solana_kit_codecs_core (~17 source files, ~28 test files)

- [x] T007 [US3] Port Codec/Encoder/Decoder interfaces and core types from `.repos/kit/packages/codecs-core/src/` to `packages/solana_kit_codecs_core/lib/src/`
- [x] T008 [US3] Port composition utilities (transformCodec, fixCodecSize, offsetCodec, padCodec, reverseCodec) in `packages/solana_kit_codecs_core/lib/src/`
- [x] T009 [US3] Port byte helpers (containsBytes, getEncodedSize) and createCodec/createEncoder/createDecoder in `packages/solana_kit_codecs_core/lib/src/`
- [x] T010 [US3] Update barrel export `packages/solana_kit_codecs_core/lib/solana_kit_codecs_core.dart`
- [x] T011 [US3] Port all 28 test files from `.repos/kit/packages/codecs-core/src/__tests__/` to `packages/solana_kit_codecs_core/test/`

### solana_kit_codecs_numbers (~17 source files, ~15 test files)

- [x] T012 [P] [US3] Port integer codecs (u8, u16, u32, u64, u128, i8–i128) from `.repos/kit/packages/codecs-numbers/src/` to `packages/solana_kit_codecs_numbers/lib/src/`
- [x] T013 [P] [US3] Port float codecs (f32, f64) and shortU16 codec in `packages/solana_kit_codecs_numbers/lib/src/`
- [x] T014 [US3] Update barrel export `packages/solana_kit_codecs_numbers/lib/solana_kit_codecs_numbers.dart`
- [x] T015 [US3] Port all 15 test files from `.repos/kit/packages/codecs-numbers/src/__tests__/` to `packages/solana_kit_codecs_numbers/test/`

### solana_kit_codecs_strings (~10 source files, ~8 test files)

- [x] T016 [P] [US3] Port string codecs (utf8, base58, base64, base16, base10, baseX) from `.repos/kit/packages/codecs-strings/src/` to `packages/solana_kit_codecs_strings/lib/src/`
- [x] T017 [US3] Update barrel export `packages/solana_kit_codecs_strings/lib/solana_kit_codecs_strings.dart`
- [x] T018 [US3] Port all 8 test files from `.repos/kit/packages/codecs-strings/src/__tests__/` to `packages/solana_kit_codecs_strings/test/`

### solana_kit_codecs_data_structures (~21 source files, ~38 test files)

- [x] T019 [US3] Port struct, array, tuple codecs from `.repos/kit/packages/codecs-data-structures/src/` to `packages/solana_kit_codecs_data_structures/lib/src/`
- [x] T020 [P] [US3] Port map, set, enum, discriminated union codecs in `packages/solana_kit_codecs_data_structures/lib/src/`
- [x] T021 [P] [US3] Port bool, nullable, constant, bitArray, unit, hiddenPrefix, hiddenSuffix codecs in `packages/solana_kit_codecs_data_structures/lib/src/`
- [x] T022 [US3] Update barrel export `packages/solana_kit_codecs_data_structures/lib/solana_kit_codecs_data_structures.dart`
- [x] T023 [US3] Port all 38 test files from `.repos/kit/packages/codecs-data-structures/src/__tests__/` to `packages/solana_kit_codecs_data_structures/test/`

### solana_kit_options (~6 source files, ~5 test files)

- [x] T024 [P] [US3] Port Option&lt;T&gt; sealed class (Some/None), utilities, and option codec from `.repos/kit/packages/options/src/` to `packages/solana_kit_options/lib/src/`
- [x] T025 [US3] Update barrel export `packages/solana_kit_options/lib/solana_kit_options.dart`
- [x] T026 [US3] Port all 5 test files from `.repos/kit/packages/options/src/__tests__/` to `packages/solana_kit_options/test/`

### solana_kit_codecs (umbrella re-export)

- [x] T027 [US3] Create umbrella re-export of all codec packages in `packages/solana_kit_codecs/lib/solana_kit_codecs.dart`

**Checkpoint**: All codec packages implemented and tested. Developers can encode/decode all Solana data types. `melos test --scope="solana_kit_codecs*"` passes.

---

## Phase 4: User Story 1 — Build and Send a Solana Transaction (Priority: P1) MVP

**Goal**: Enable developers to create, sign, and send Solana transactions using addresses, keys, instructions, and signers — the core SDK workflow.

**Independent Test**: A developer can import the SDK, create a transfer transaction, sign it with a generated keypair, and compile it to wire format. Integration test against local validator confirms on-chain execution.

### solana_kit_addresses (~7 source files, ~6 test files)

- [x] T028 [US1] Port Address extension type, base58 codec, validation from `.repos/kit/packages/addresses/src/` to `packages/solana_kit_addresses/lib/src/`
- [x] T029 [US1] Port PDA computation (getProgramDerivedAddress, findProgramDerivedAddress, createAddressWithSeed) in `packages/solana_kit_addresses/lib/src/`
- [x] T030 [US1] Port isOnCurve validation in `packages/solana_kit_addresses/lib/src/`
- [x] T031 [US1] Update barrel export `packages/solana_kit_addresses/lib/solana_kit_addresses.dart`
- [x] T032 [US1] Port all 6 test files from `.repos/kit/packages/addresses/src/__tests__/` to `packages/solana_kit_addresses/test/`

### solana_kit_keys (~10 source files, ~10 test files)

- [x] T033 [US1] Port Ed25519 key generation, signing, verification from `.repos/kit/packages/keys/src/` to `packages/solana_kit_keys/lib/src/` using `cryptography` package
- [x] T034 [US1] Port Signature extension type and signature codec in `packages/solana_kit_keys/lib/src/`
- [x] T035 [US1] Update barrel export `packages/solana_kit_keys/lib/solana_kit_keys.dart`
- [x] T036 [US1] Port all 10 test files from `.repos/kit/packages/keys/src/__tests__/` to `packages/solana_kit_keys/test/`

### solana_kit_instructions (~4 source files, ~2 test files)

- [x] T037 [P] [US1] Port IInstruction, IAccountMeta, AccountRole from `.repos/kit/packages/instructions/src/` to `packages/solana_kit_instructions/lib/src/`
- [x] T038 [US1] Update barrel export `packages/solana_kit_instructions/lib/solana_kit_instructions.dart`
- [x] T039 [US1] Port all 2 test files from `.repos/kit/packages/instructions/src/__tests__/` to `packages/solana_kit_instructions/test/`

### solana_kit_programs (~2 source files, ~2 test files)

- [x] T040 [P] [US1] Port isProgramError, getProgramErrorMessage from `.repos/kit/packages/programs/src/` to `packages/solana_kit_programs/lib/src/`
- [x] T041 [US1] Update barrel export `packages/solana_kit_programs/lib/solana_kit_programs.dart`
- [x] T042 [US1] Port all 2 test files from `.repos/kit/packages/programs/src/__tests__/` to `packages/solana_kit_programs/test/`

### solana_kit_transaction_messages (~38 source files, ~22 test files)

- [x] T043 [US1] Port TransactionMessage type and creation from `.repos/kit/packages/transaction-messages/src/` to `packages/solana_kit_transaction_messages/lib/src/`
- [x] T044 [US1] Port fee payer, blockhash lifetime, durable nonce lifetime setters in `packages/solana_kit_transaction_messages/lib/src/`
- [x] T045 [US1] Port instruction append/prepend, address lookup table support in `packages/solana_kit_transaction_messages/lib/src/`
- [x] T046 [US1] Port message compilation and decompilation in `packages/solana_kit_transaction_messages/lib/src/`
- [x] T047 [US1] Update barrel export `packages/solana_kit_transaction_messages/lib/solana_kit_transaction_messages.dart`
- [x] T048 [US1] Port all 22 test files from `.repos/kit/packages/transaction-messages/src/__tests__/` to `packages/solana_kit_transaction_messages/test/`

### solana_kit_transactions (~15 source files, ~17 test files)

- [x] T049 [US1] Port Transaction type, compilation, wire format from `.repos/kit/packages/transactions/src/` to `packages/solana_kit_transactions/lib/src/`
- [x] T050 [US1] Port signing, size calculation, base64 wire encoding in `packages/solana_kit_transactions/lib/src/`
- [x] T051 [US1] Port signature extraction and full-signature assertion in `packages/solana_kit_transactions/lib/src/`
- [x] T052 [US1] Update barrel export `packages/solana_kit_transactions/lib/solana_kit_transactions.dart`
- [x] T053 [US1] Port all 17 test files from `.repos/kit/packages/transactions/src/__tests__/` to `packages/solana_kit_transactions/test/`

### solana_kit_signers (~22 source files, ~33 test files)

- [x] T054 [US1] Port signer interfaces (TransactionSigner, MessageSigner, TransactionPartialSigner, TransactionModifyingSigner, TransactionSendingSigner) from `.repos/kit/packages/signers/src/` to `packages/solana_kit_signers/lib/src/`
- [x] T055 [US1] Port KeyPairSigner, NoopSigner implementations in `packages/solana_kit_signers/lib/src/`
- [x] T056 [US1] Port signer utilities (createKeyPairSignerFromKeyPair, isTransactionSigner, assertIsTransactionSigner) in `packages/solana_kit_signers/lib/src/`
- [x] T057 [US1] Update barrel export `packages/solana_kit_signers/lib/solana_kit_signers.dart`
- [x] T058 [US1] Port all 33 test files from `.repos/kit/packages/signers/src/__tests__/` to `packages/solana_kit_signers/test/`

### solana_kit_offchain_messages (~26 source files, ~11 test files)

- [ ] T059 [P] [US1] Port offchain message v0/v1 encoding/decoding from `.repos/kit/packages/offchain-message/src/` to `packages/solana_kit_offchain_messages/lib/src/`
- [ ] T060 [US1] Update barrel export `packages/solana_kit_offchain_messages/lib/solana_kit_offchain_messages.dart`
- [ ] T061 [US1] Port all 11 test files from `.repos/kit/packages/offchain-message/src/__tests__/` to `packages/solana_kit_offchain_messages/test/`

**Checkpoint**: Full transaction lifecycle implemented. Developers can create keypairs, build transactions, sign them, and compile to wire format. `melos test --scope="solana_kit_addresses" --scope="solana_kit_keys" --scope="solana_kit_instructions" --scope="solana_kit_programs" --scope="solana_kit_transaction_messages" --scope="solana_kit_transactions" --scope="solana_kit_signers"` passes.

---

## Phase 5: User Story 2 — Query Solana State via RPC (Priority: P2)

**Goal**: Provide strongly-typed HTTP RPC client with all 40+ Solana JSON-RPC methods, account fetching/decoding, and high-level account utilities.

**Independent Test**: `melos test --scope="solana_kit_rpc*" --scope="solana_kit_accounts" --scope="solana_kit_sysvars"` — all RPC and account packages pass; typed RPC calls return correctly structured responses.

### solana_kit_rpc_spec_types (~7 source files, ~3 test files)

- [ ] T062 [US2] Port RpcRequest, RpcResponse, RpcPlan types from `.repos/kit/packages/rpc-spec-types/src/` to `packages/solana_kit_rpc_spec_types/lib/src/`
- [ ] T063 [US2] Update barrel export `packages/solana_kit_rpc_spec_types/lib/solana_kit_rpc_spec_types.dart`
- [ ] T064 [US2] Port all 3 test files from `.repos/kit/packages/rpc-spec-types/src/__tests__/` to `packages/solana_kit_rpc_spec_types/test/`

### solana_kit_rpc_types (~20 source files, ~11 test files)

- [ ] T065 [P] [US2] Port Commitment, Lamports, UnixTimestamp, Blockhash, TransactionVersion types from `.repos/kit/packages/rpc-types/src/` to `packages/solana_kit_rpc_types/lib/src/`
- [ ] T066 [US2] Port TokenAmount, AccountInfoBase, SimulatedTransactionAccountInfo and remaining types in `packages/solana_kit_rpc_types/lib/src/`
- [ ] T067 [US2] Update barrel export `packages/solana_kit_rpc_types/lib/solana_kit_rpc_types.dart`
- [ ] T068 [US2] Port all 11 test files from `.repos/kit/packages/rpc-types/src/__tests__/` to `packages/solana_kit_rpc_types/test/`

### solana_kit_rpc_spec (~4 source files, ~6 test files)

- [ ] T069 [US2] Port createJsonRpcApi, Rpc&lt;T&gt;, RpcTransport from `.repos/kit/packages/rpc-spec/src/` to `packages/solana_kit_rpc_spec/lib/src/`
- [ ] T070 [US2] Update barrel export `packages/solana_kit_rpc_spec/lib/solana_kit_rpc_spec.dart`
- [ ] T071 [US2] Port all 6 test files from `.repos/kit/packages/rpc-spec/src/__tests__/` to `packages/solana_kit_rpc_spec/test/`

### solana_kit_rpc_parsed_types (~10 source files, ~8 test files)

- [ ] T072 [P] [US2] Port parsed account types (token, stake, vote, etc.) from `.repos/kit/packages/rpc-parsed-types/src/` to `packages/solana_kit_rpc_parsed_types/lib/src/`
- [ ] T073 [US2] Update barrel export `packages/solana_kit_rpc_parsed_types/lib/solana_kit_rpc_parsed_types.dart`
- [ ] T074 [US2] Port all 8 test files from `.repos/kit/packages/rpc-parsed-types/src/__tests__/` to `packages/solana_kit_rpc_parsed_types/test/`

### solana_kit_rpc_transformers (~16 source files, ~7 test files)

- [ ] T075 [US2] Port request/response transformers and BigInt upcast/downcast from `.repos/kit/packages/rpc-transformers/src/` to `packages/solana_kit_rpc_transformers/lib/src/`
- [ ] T076 [US2] Update barrel export `packages/solana_kit_rpc_transformers/lib/solana_kit_rpc_transformers.dart`
- [ ] T077 [US2] Port all 7 test files from `.repos/kit/packages/rpc-transformers/src/__tests__/` to `packages/solana_kit_rpc_transformers/test/`

### solana_kit_rpc_transport_http (~9 source files, ~10 test files)

- [ ] T078 [P] [US2] Port HTTP transport using `http` package from `.repos/kit/packages/rpc-transport-http/src/` to `packages/solana_kit_rpc_transport_http/lib/src/`
- [ ] T079 [US2] Update barrel export `packages/solana_kit_rpc_transport_http/lib/solana_kit_rpc_transport_http.dart`
- [ ] T080 [US2] Port all 10 test files from `.repos/kit/packages/rpc-transport-http/src/__tests__/` to `packages/solana_kit_rpc_transport_http/test/`

### solana_kit_rpc_api (~107 source files, ~61 test files)

- [ ] T081 [US2] Port getAccountInfo, getBalance, getBlock, getBlockCommitment, getBlockHeight methods from `.repos/kit/packages/rpc-api/src/` to `packages/solana_kit_rpc_api/lib/src/`
- [ ] T082 [US2] Port getBlockProduction, getBlocks, getBlocksWithLimit, getBlockTime, getClusterNodes methods in `packages/solana_kit_rpc_api/lib/src/`
- [ ] T083 [US2] Port getEpochInfo, getEpochSchedule, getFeeForMessage, getFirstAvailableBlock, getGenesisHash methods in `packages/solana_kit_rpc_api/lib/src/`
- [ ] T084 [US2] Port getHealth, getHighestSnapshotSlot, getIdentity, getInflationGovernor, getInflationRate, getInflationReward methods in `packages/solana_kit_rpc_api/lib/src/`
- [ ] T085 [US2] Port getLargestAccounts, getLatestBlockhash, getLeaderSchedule, getMaxRetransmitSlot, getMaxShredInsertSlot methods in `packages/solana_kit_rpc_api/lib/src/`
- [ ] T086 [US2] Port getMinimumBalanceForRentExemption, getMultipleAccounts, getProgramAccounts methods in `packages/solana_kit_rpc_api/lib/src/`
- [ ] T087 [US2] Port getRecentPerformanceSamples, getRecentPrioritizationFees, getSignaturesForAddress, getSignatureStatuses methods in `packages/solana_kit_rpc_api/lib/src/`
- [ ] T088 [US2] Port getSlot, getSlotLeader, getSlotLeaders, getStakeActivation, getStakeMinimumDelegation methods in `packages/solana_kit_rpc_api/lib/src/`
- [ ] T089 [US2] Port getSupply, getTokenAccountBalance, getTokenAccountsByDelegate, getTokenAccountsByOwner methods in `packages/solana_kit_rpc_api/lib/src/`
- [ ] T090 [US2] Port getTokenLargestAccounts, getTokenSupply, getTransaction, getTransactionCount methods in `packages/solana_kit_rpc_api/lib/src/`
- [ ] T091 [US2] Port getVersion, getVoteAccounts, isBlockhashValid, minimumLedgerSlot, requestAirdrop, sendTransaction, simulateTransaction in `packages/solana_kit_rpc_api/lib/src/`
- [ ] T092 [US2] Update barrel export `packages/solana_kit_rpc_api/lib/solana_kit_rpc_api.dart`
- [ ] T093 [US2] Port all 61 test files from `.repos/kit/packages/rpc-api/src/__tests__/` to `packages/solana_kit_rpc_api/test/`

### solana_kit_rpc (~8 source files, ~6 test files)

- [ ] T094 [US2] Port createSolanaRpc, createSolanaRpcFromTransport, cluster URLs from `.repos/kit/packages/rpc/src/` to `packages/solana_kit_rpc/lib/src/`
- [ ] T095 [US2] Update barrel export `packages/solana_kit_rpc/lib/solana_kit_rpc.dart`
- [ ] T096 [US2] Port all 6 test files from `.repos/kit/packages/rpc/src/__tests__/` to `packages/solana_kit_rpc/test/`

### solana_kit_accounts (~10 source files, ~9 test files)

- [ ] T097 [US2] Port fetchEncodedAccount, fetchEncodedAccounts, decodeAccount, parseAccount from `.repos/kit/packages/accounts/src/` to `packages/solana_kit_accounts/lib/src/`
- [ ] T098 [US2] Port Account&lt;T&gt;, MaybeAccount&lt;T&gt;, EncodedAccount types and assertion utilities in `packages/solana_kit_accounts/lib/src/`
- [ ] T099 [US2] Update barrel export `packages/solana_kit_accounts/lib/solana_kit_accounts.dart`
- [ ] T100 [US2] Port all 9 test files from `.repos/kit/packages/accounts/src/__tests__/` to `packages/solana_kit_accounts/test/`

### solana_kit_sysvars (~13 source files, ~12 test files)

- [ ] T101 [P] [US2] Port Clock, EpochSchedule, Rent, and remaining sysvar types from `.repos/kit/packages/sysvars/src/` to `packages/solana_kit_sysvars/lib/src/`
- [ ] T102 [US2] Update barrel export `packages/solana_kit_sysvars/lib/solana_kit_sysvars.dart`
- [ ] T103 [US2] Port all 12 test files from `.repos/kit/packages/sysvars/src/__tests__/` to `packages/solana_kit_sysvars/test/`

### solana_kit_program_client_core (~5 source files, ~7 test files)

- [ ] T104 [P] [US2] Port base program client utilities from `.repos/kit/packages/program-client-core/src/` to `packages/solana_kit_program_client_core/lib/src/`
- [ ] T105 [US2] Update barrel export `packages/solana_kit_program_client_core/lib/solana_kit_program_client_core.dart`
- [ ] T106 [US2] Port all 7 test files from `.repos/kit/packages/program-client-core/src/__tests__/` to `packages/solana_kit_program_client_core/test/`

**Checkpoint**: Full RPC client operational. Developers can query all 40+ Solana RPC methods with typed responses, fetch and decode accounts, and read sysvars. `melos test --scope="solana_kit_rpc*" --scope="solana_kit_accounts" --scope="solana_kit_sysvars" --scope="solana_kit_program_client_core"` passes.

---

## Phase 6: User Story 4 — Subscribe to Real-Time Solana Events (Priority: P3)

**Goal**: Enable WebSocket-based subscriptions for account changes, slot updates, and transaction confirmations with auto-ping and coalescing.

**Independent Test**: `melos test --scope="solana_kit_subscribable" --scope="solana_kit_rpc_subscriptions*" --scope="solana_kit_transaction_confirmation" --scope="solana_kit_instruction_plans"` — all subscription and confirmation packages pass.

### solana_kit_subscribable (~5 source files, ~5 test files)

- [ ] T107 [US4] Port DataPublisher, async iterable helpers from `.repos/kit/packages/subscribable/src/` to `packages/solana_kit_subscribable/lib/src/`
- [ ] T108 [US4] Update barrel export `packages/solana_kit_subscribable/lib/solana_kit_subscribable.dart`
- [ ] T109 [US4] Port all 5 test files from `.repos/kit/packages/subscribable/src/__tests__/` to `packages/solana_kit_subscribable/test/`

### solana_kit_rpc_subscriptions_api (~11 source files, ~21 test files)

- [ ] T110 [US4] Port all subscription method definitions (accountNotifications, blockNotifications, logsNotifications, etc.) from `.repos/kit/packages/rpc-subscriptions-api/src/` to `packages/solana_kit_rpc_subscriptions_api/lib/src/`
- [ ] T111 [US4] Update barrel export `packages/solana_kit_rpc_subscriptions_api/lib/solana_kit_rpc_subscriptions_api.dart`
- [ ] T112 [US4] Port all 21 test files from `.repos/kit/packages/rpc-subscriptions-api/src/__tests__/` to `packages/solana_kit_rpc_subscriptions_api/test/`

### solana_kit_rpc_subscriptions_channel_websocket (~3 source files, ~3 test files)

- [ ] T113 [P] [US4] Port WebSocket channel using `web_socket_channel` from `.repos/kit/packages/rpc-subscriptions-channel-websocket/src/` to `packages/solana_kit_rpc_subscriptions_channel_websocket/lib/src/`
- [ ] T114 [US4] Update barrel export `packages/solana_kit_rpc_subscriptions_channel_websocket/lib/solana_kit_rpc_subscriptions_channel_websocket.dart`
- [ ] T115 [US4] Port all 3 test files from `.repos/kit/packages/rpc-subscriptions-channel-websocket/src/__tests__/` to `packages/solana_kit_rpc_subscriptions_channel_websocket/test/`

### solana_kit_rpc_subscriptions (~14 source files, ~9 test files)

- [ ] T116 [US4] Port createSolanaRpcSubscriptions, autopinger, coalescer from `.repos/kit/packages/rpc-subscriptions/src/` to `packages/solana_kit_rpc_subscriptions/lib/src/`
- [ ] T117 [US4] Update barrel export `packages/solana_kit_rpc_subscriptions/lib/solana_kit_rpc_subscriptions.dart`
- [ ] T118 [US4] Port all 9 test files from `.repos/kit/packages/rpc-subscriptions/src/__tests__/` to `packages/solana_kit_rpc_subscriptions/test/`

### solana_kit_transaction_confirmation (~10 source files, ~9 test files)

- [ ] T119 [US4] Port confirmation strategies (blockheight, nonce, signature, timeout) from `.repos/kit/packages/transaction-confirmation/src/` to `packages/solana_kit_transaction_confirmation/lib/src/`
- [ ] T120 [US4] Update barrel export `packages/solana_kit_transaction_confirmation/lib/solana_kit_transaction_confirmation.dart`
- [ ] T121 [US4] Port all 9 test files from `.repos/kit/packages/transaction-confirmation/src/__tests__/` to `packages/solana_kit_transaction_confirmation/test/`

### solana_kit_instruction_plans (~8 source files, ~15 test files)

- [ ] T122 [P] [US4] Port InstructionPlan, TransactionPlan, execution utilities from `.repos/kit/packages/instruction-plans/src/` to `packages/solana_kit_instruction_plans/lib/src/`
- [ ] T123 [US4] Update barrel export `packages/solana_kit_instruction_plans/lib/solana_kit_instruction_plans.dart`
- [ ] T124 [US4] Port all 15 test files from `.repos/kit/packages/instruction-plans/src/__tests__/` to `packages/solana_kit_instruction_plans/test/`

**Checkpoint**: Real-time subscriptions and transaction confirmation operational. Developers can subscribe to account changes, slot updates, and await transaction confirmation. All subscription-related tests pass.

---

## Phase 7: User Story 5 — Publish Packages to pub.dev (Priority: P4)

**Goal**: Create a comprehensive publishing guide documenting the process for versioning and publishing all 37 packages.

**Independent Test**: Following the guide, `melos exec -- dart pub publish --dry-run` succeeds for all packages without errors.

- [ ] T125 [US5] Write publishing guide documenting dependency-order publishing strategy in `docs/publishing-guide.md`
- [ ] T126 [US5] Document knope changeset workflow and melos publish process in `docs/publishing-guide.md`
- [ ] T127 [US5] Document pre-publish checklist per package (readme, changelog, LICENSE, remove workspace resolution, add caret constraints, run pana) in `docs/publishing-guide.md`
- [ ] T128 [US5] Document 37-package concerns (namespace reservation, rate limits, verified publisher, rollback procedures) in `docs/publishing-guide.md`
- [ ] T129 [US5] Validate all 37 packages pass `dart pub publish --dry-run` and document any issues

**Checkpoint**: Publishing guide complete and validated. Maintainer can follow the guide for a successful dry-run publish of all packages.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Finalization packages and cross-package validation

- [ ] T130 [P] Implement solana_kit_test_matchers with Solana-specific test assertions in `packages/solana_kit_test_matchers/lib/src/`
- [ ] T131 Create umbrella re-export package `packages/solana_kit/lib/solana_kit.dart` re-exporting all 36 other packages
- [ ] T132 Run `melos analyze` across all 37 packages and fix any warnings
- [ ] T133 Run `melos test` across all 37 packages and verify all tests pass
- [ ] T134 Run `dprint check` and fix any formatting issues across entire codebase
- [ ] T135 Validate quickstart.md code examples compile and run correctly
- [ ] T136 Verify byte-identical codec output vs upstream TS SDK for representative test vectors

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 — BLOCKS all user stories
- **US3 Codecs (Phase 3)**: Depends on Phase 2 — BLOCKS US1, US2, US4
- **US1 Transactions (Phase 4)**: Depends on Phase 3 (codecs complete)
- **US2 RPC (Phase 5)**: Depends on Phase 3 (codecs) and Phase 4 (addresses, keys needed for typed RPC responses)
- **US4 Subscriptions (Phase 6)**: Depends on Phase 5 (RPC foundation) and Phase 4 (signers for confirmation)
- **US5 Publishing (Phase 7)**: Depends on Phases 3–6 (all packages implemented)
- **Polish (Phase 8)**: Depends on all prior phases

### User Story Dependencies

- **US3 (P2 — Codecs)**: No user story dependencies. Must complete first due to being foundational.
- **US1 (P1 — Transactions)**: Depends on US3 (codecs for address/signature encoding)
- **US2 (P2 — RPC)**: Depends on US3 (codecs) and partially on US1 (addresses, keys)
- **US4 (P3 — Subscriptions)**: Depends on US2 (RPC foundation) and US1 (signers for confirmation)
- **US5 (P4 — Publishing)**: Depends on all implementation being complete

### Within Each User Story

- Port source files before tests (source must exist for tests to import)
- Port lower-dependency packages before higher-dependency packages
- Barrel exports updated after source files are complete
- Tests ported and passing before marking package as complete

### Parallel Opportunities

- T003/T004 and T005/T006 — functional and fast_stable_stringify are independent
- T012/T013 and T016 — codecs_numbers and codecs_strings are independent (both depend only on codecs_core)
- T024 — options depends only on codecs_core, can parallel with numbers/strings
- T037/T039 and T040/T042 — instructions and programs are independent
- T059/T061 — offchain_messages independent of transaction_messages
- T065/T068, T072/T074, T078/T080 — rpc_types, rpc_parsed_types, rpc_transport_http are partially independent
- T101/T103 and T104/T106 — sysvars and program_client_core are independent
- T107/T109, T113/T115, T122/T124 — subscribable, websocket channel, instruction_plans are partially independent

---

## Parallel Example: User Story 3 (Codecs)

```bash
# After codecs_core (T007–T011) is complete, launch in parallel:
Task: "Port integer/float codecs in packages/solana_kit_codecs_numbers/" (T012–T015)
Task: "Port string codecs in packages/solana_kit_codecs_strings/" (T016–T018)
Task: "Port Option type in packages/solana_kit_options/" (T024–T026)

# After codecs_numbers completes, then:
Task: "Port data structure codecs in packages/solana_kit_codecs_data_structures/" (T019–T023)
```

## Parallel Example: User Story 1 (Transactions)

```bash
# After addresses (T028–T032) and keys (T033–T036) complete, launch in parallel:
Task: "Port instructions in packages/solana_kit_instructions/" (T037–T039)
Task: "Port programs in packages/solana_kit_programs/" (T040–T042)
Task: "Port offchain messages in packages/solana_kit_offchain_messages/" (T059–T061)

# Then sequentially:
Task: "Port transaction messages in packages/solana_kit_transaction_messages/" (T043–T048)
Task: "Port transactions in packages/solana_kit_transactions/" (T049–T053)
Task: "Port signers in packages/solana_kit_signers/" (T054–T058)
```

---

## Implementation Strategy

### MVP First (US3 + US1)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (functional + fast_stable_stringify)
3. Complete Phase 3: US3 — Codecs (all 6 codec packages)
4. **STOP and VALIDATE**: All codec tests pass, encode/decode round-trips work
5. Complete Phase 4: US1 — Transactions (addresses through signers)
6. **STOP and VALIDATE**: Full transaction lifecycle works end-to-end

### Incremental Delivery

1. Setup + Foundational → Utilities ready
2. Add US3 (Codecs) → Test independently → Codec system operational
3. Add US1 (Transactions) → Test independently → Transaction building works
4. Add US2 (RPC) → Test independently → Chain queries work
5. Add US4 (Subscriptions) → Test independently → Real-time events work
6. Add US5 (Publishing) → Validated dry-run → Ready for pub.dev
7. Polish → All checks pass → Release candidate

### Per-Package PR Strategy

Each package or small group of related packages is implemented as a separate PR:

- PR title follows emoji conventional commit format: `EMOJI TYPE(package_name): description`
- Includes changeset file in `.changeset/`
- Must pass all 6 CI checks (analyze, test, format, Secrets Detection, PR Title, Changeset Required)
- Tests ported alongside implementation (not as separate PRs)

Suggested PR groupings:

- PR 1: functional + fast_stable_stringify (Layer 1)
- PR 2: codecs_core + codecs_numbers (Layer 2a)
- PR 3: codecs_strings + codecs_data_structures (Layer 2b)
- PR 4: options + codecs umbrella (Layer 2c)
- PR 5: addresses + keys (Layer 3)
- PR 6: instructions + programs (Layer 5)
- PR 7: transaction_messages + offchain_messages (Layer 6)
- PR 8: transactions + signers (Layer 7)
- PR 9: rpc_spec_types + rpc_types + rpc_spec (Layer 4a)
- PR 10: rpc_parsed_types + rpc_transformers + rpc_transport_http (Layer 4b)
- PR 11: rpc_api (Layer 8 — large, own PR)
- PR 12: rpc + accounts + sysvars + program_client_core (Layer 8+9)
- PR 13: subscribable + rpc_subscriptions_api + rpc_subscriptions_channel_websocket + rpc_subscriptions (Layer 8)
- PR 14: transaction_confirmation + instruction_plans (Layer 9)
- PR 15: test_matchers + solana_kit umbrella + publishing guide (Layer 10)

---

## Notes

- [P] tasks = different packages/files, no dependencies on incomplete tasks in same phase
- [Story] label maps task to specific user story for traceability
- Each user story is independently testable at its checkpoint
- TS source paths assume `.repos/kit/` is cloned and up-to-date
- ~500 source files and ~380 test files total across all packages
- Layer 0 (errors + lints) is already implemented — not included in tasks
- The largest single package is rpc_api with ~107 source and ~61 test files — broken into 11 implementation tasks
