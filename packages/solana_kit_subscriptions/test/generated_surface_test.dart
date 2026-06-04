import 'dart:typed_data';

import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:solana_kit_subscriptions/solana_kit_subscriptions.dart';
import 'package:test/test.dart';

const a1 = Address('11111111111111111111111111111111');
const a2 = Address('11111111111111111111111111111111');
const a3 = Address('11111111111111111111111111111111');
const a4 = Address('11111111111111111111111111111111');
const a5 = Address('11111111111111111111111111111111');
const a6 = Address('11111111111111111111111111111111');
const a7 = Address('11111111111111111111111111111111');
const a8 = Address('11111111111111111111111111111111');

void main() {
  group('program metadata', () {
    test('exports the canonical subscriptions program address', () {
      expect(
        subscriptionsProgramAddress,
        const Address('De1egAFMkMWZSN5rYXRj9CAdheBamobVNubTsi9avR44'),
      );
      expect(SubscriptionsAccount.values, hasLength(6));
      expect(SubscriptionsInstruction.values, hasLength(14));
    });
  });

  group('generated types', () {
    test('round-trips every struct and enum codec', () {
      for (final discriminator in AccountDiscriminator.values) {
        _roundTrip(getAccountDiscriminatorCodec(), discriminator);
      }

      _roundTrip(getPlanTermsCodec(), _planTerms);
      _roundTrip(getPlanDataCodec(), _planData);
      _roundTrip(getHeaderCodec(), _header);
      _roundTrip(getCreateFixedDelegationDataCodec(), _fixedData);
      _roundTrip(getCreateRecurringDelegationDataCodec(), _recurringData);
      _roundTrip(getSubscribeDataCodec(), _subscribeData);
      _roundTrip(getTransferDataCodec(), _transferData);
      _roundTrip(getUpdatePlanDataCodec(), _updatePlanData);

      expect(
        getPlanStatusCodec().decode(
          getPlanStatusCodec().encode(PlanStatus.sunset),
        ),
        PlanStatus.sunset,
      );
      expect(
        getPlanStatusCodec().decode(
          getPlanStatusCodec().encode(PlanStatus.active),
        ),
        PlanStatus.active,
      );

      _expectValueObject(
        _planTerms,
        _planTermsClone,
        _planTermsAlt,
        'PlanTerms',
      );
      _expectValueObject(_planData, _planDataClone, _planDataAlt, 'PlanData');
      _expectValueObject(_header, _headerClone, _headerAlt, 'Header');
      _expectValueObject(
        _fixedData,
        _fixedDataClone,
        _fixedDataAlt,
        'CreateFixedDelegationData',
      );
      _expectValueObject(
        _recurringData,
        _recurringDataClone,
        _recurringDataAlt,
        'CreateRecurringDelegationData',
      );
      _expectValueObject(
        _subscribeData,
        _subscribeDataClone,
        _subscribeDataAlt,
        'SubscribeData',
      );
      _expectValueObject(
        _transferData,
        _transferDataClone,
        _transferDataAlt,
        'TransferData',
      );
      _expectValueObject(
        _updatePlanData,
        _updatePlanDataClone,
        _updatePlanDataAlt,
        'UpdatePlanData',
      );
    });
  });

  group('generated accounts', () {
    test('round-trips every account codec and decoder helper', () {
      _roundTripAccount(
        getEventAuthorityCodec(),
        const EventAuthority(),
        decodeEventAuthority,
      );
      _roundTripAccount(
        getFixedDelegationCodec(),
        _fixedDelegation,
        decodeFixedDelegation,
      );
      _roundTripAccount(getPlanCodec(), _plan, decodePlan);
      _roundTripAccount(
        getRecurringDelegationCodec(),
        _recurringDelegation,
        decodeRecurringDelegation,
      );
      _roundTripAccount(
        getSubscriptionAuthorityCodec(),
        _subscriptionAuthority,
        decodeSubscriptionAuthority,
      );
      _roundTripAccount(
        getSubscriptionDelegationCodec(),
        _subscriptionDelegation,
        decodeSubscriptionDelegation,
      );

      expect(const EventAuthority(), equals(const EventAuthority()));
      expect(const EventAuthority().hashCode, 0);
      expect(const EventAuthority().toString(), 'EventAuthority()');
      // Intentionally non-const to cover the generated empty constructor.
      // ignore: prefer_const_constructors
      final eventAuthority = EventAuthority();
      // ignore: prefer_const_constructors
      expect(eventAuthority, equals(EventAuthority()));
      _expectValueObject(
        _fixedDelegation,
        _fixedDelegationClone,
        _fixedDelegationAlt,
        'FixedDelegation',
      );
      _expectValueObject(_plan, _planClone, _planAlt, 'Plan');
      _expectValueObject(
        _recurringDelegation,
        _recurringDelegationClone,
        _recurringDelegationAlt,
        'RecurringDelegation',
      );
      _expectValueObject(
        _subscriptionAuthority,
        _subscriptionAuthorityClone,
        _subscriptionAuthorityAlt,
        'SubscriptionAuthority',
      );
      _expectValueObject(
        _subscriptionDelegation,
        _subscriptionDelegationClone,
        _subscriptionDelegationAlt,
        'SubscriptionDelegation',
      );
    });
  });

  group('generated instruction data', () {
    test('round-trips every instruction data codec', () {
      _roundTrip(
        getInitSubscriptionAuthorityInstructionDataCodec(),
        const InitSubscriptionAuthorityInstructionData(),
      );
      _roundTrip(
        getCreateFixedDelegationInstructionDataCodec(),
        CreateFixedDelegationInstructionData(fixedDelegation: _fixedData),
      );
      _roundTrip(
        getCreateRecurringDelegationInstructionDataCodec(),
        CreateRecurringDelegationInstructionData(
          recurringDelegation: _recurringData,
        ),
      );
      _roundTrip(
        getRevokeDelegationInstructionDataCodec(),
        const RevokeDelegationInstructionData(),
      );
      _roundTrip(
        getTransferFixedInstructionDataCodec(),
        TransferFixedInstructionData(transferData: _transferData),
      );
      _roundTrip(
        getTransferRecurringInstructionDataCodec(),
        TransferRecurringInstructionData(transferData: _transferData),
      );
      _roundTrip(
        getCloseSubscriptionAuthorityInstructionDataCodec(),
        const CloseSubscriptionAuthorityInstructionData(),
      );
      _roundTrip(
        getCreatePlanInstructionDataCodec(),
        CreatePlanInstructionData(planData: _planData),
      );
      _roundTrip(
        getUpdatePlanInstructionDataCodec(),
        UpdatePlanInstructionData(updatePlanData: _updatePlanData),
      );
      _roundTrip(
        getDeletePlanInstructionDataCodec(),
        const DeletePlanInstructionData(),
      );
      _roundTrip(
        getTransferSubscriptionInstructionDataCodec(),
        TransferSubscriptionInstructionData(transferData: _transferData),
      );
      _roundTrip(
        getSubscribeInstructionDataCodec(),
        SubscribeInstructionData(subscribeData: _subscribeData),
      );
      _roundTrip(
        getCancelSubscriptionInstructionDataCodec(),
        const CancelSubscriptionInstructionData(),
      );
      _roundTrip(
        getResumeSubscriptionInstructionDataCodec(),
        const ResumeSubscriptionInstructionData(),
      );
    });

    test('builds and parses every instruction', () {
      final instructions = <(Instruction, Object)>[
        (
          getInitSubscriptionAuthorityInstruction(
            programAddress: subscriptionsProgramAddress,
            owner: a1,
            subscriptionAuthority: a2,
            tokenMint: a3,
            userAta: a4,
            systemProgram: a5,
            tokenProgram: a6,
          ),
          const InitSubscriptionAuthorityInstructionData(),
        ),
        (
          getCreateFixedDelegationInstruction(
            programAddress: subscriptionsProgramAddress,
            delegator: a1,
            subscriptionAuthority: a2,
            delegationAccount: a3,
            delegatee: a4,
            systemProgram: a5,
            fixedDelegation: _fixedData,
          ),
          CreateFixedDelegationInstructionData(fixedDelegation: _fixedData),
        ),
        (
          getCreateRecurringDelegationInstruction(
            programAddress: subscriptionsProgramAddress,
            delegator: a1,
            subscriptionAuthority: a2,
            delegationAccount: a3,
            delegatee: a4,
            systemProgram: a5,
            recurringDelegation: _recurringData,
          ),
          CreateRecurringDelegationInstructionData(
            recurringDelegation: _recurringData,
          ),
        ),
        (
          getRevokeDelegationInstruction(
            programAddress: subscriptionsProgramAddress,
            authority: a1,
            delegationAccount: a2,
          ),
          const RevokeDelegationInstructionData(),
        ),
        (
          getTransferFixedInstruction(
            programAddress: subscriptionsProgramAddress,
            delegationPda: a1,
            subscriptionAuthority: a2,
            delegatorAta: a3,
            receiverAta: a4,
            tokenMint: a5,
            tokenProgram: a6,
            delegatee: a7,
            eventAuthority: a8,
            selfProgram: subscriptionsProgramAddress,
            transferData: _transferData,
          ),
          TransferFixedInstructionData(transferData: _transferData),
        ),
        (
          getTransferRecurringInstruction(
            programAddress: subscriptionsProgramAddress,
            delegationPda: a1,
            subscriptionAuthority: a2,
            delegatorAta: a3,
            receiverAta: a4,
            tokenMint: a5,
            tokenProgram: a6,
            delegatee: a7,
            eventAuthority: a8,
            selfProgram: subscriptionsProgramAddress,
            transferData: _transferData,
          ),
          TransferRecurringInstructionData(transferData: _transferData),
        ),
        (
          getCloseSubscriptionAuthorityInstruction(
            programAddress: subscriptionsProgramAddress,
            user: a1,
            subscriptionAuthority: a2,
          ),
          const CloseSubscriptionAuthorityInstructionData(),
        ),
        (
          getCreatePlanInstruction(
            programAddress: subscriptionsProgramAddress,
            merchant: a1,
            planPda: a2,
            tokenMint: a3,
            systemProgram: a4,
            tokenProgram: a5,
            planData: _planData,
          ),
          CreatePlanInstructionData(planData: _planData),
        ),
        (
          getUpdatePlanInstruction(
            programAddress: subscriptionsProgramAddress,
            owner: a1,
            planPda: a2,
            updatePlanData: _updatePlanData,
          ),
          UpdatePlanInstructionData(updatePlanData: _updatePlanData),
        ),
        (
          getDeletePlanInstruction(
            programAddress: subscriptionsProgramAddress,
            owner: a1,
            planPda: a2,
          ),
          const DeletePlanInstructionData(),
        ),
        (
          getTransferSubscriptionInstruction(
            programAddress: subscriptionsProgramAddress,
            subscriptionPda: a1,
            planPda: a2,
            subscriptionAuthority: a3,
            delegatorAta: a4,
            receiverAta: a5,
            caller: a6,
            tokenMint: a7,
            tokenProgram: a8,
            eventAuthority: a1,
            selfProgram: subscriptionsProgramAddress,
            transferData: _transferData,
          ),
          TransferSubscriptionInstructionData(transferData: _transferData),
        ),
        (
          getSubscribeInstruction(
            programAddress: subscriptionsProgramAddress,
            subscriber: a1,
            merchant: a2,
            planPda: a3,
            subscriptionPda: a4,
            subscriptionAuthorityPda: a5,
            systemProgram: a6,
            eventAuthority: a7,
            selfProgram: subscriptionsProgramAddress,
            subscribeData: _subscribeData,
          ),
          SubscribeInstructionData(subscribeData: _subscribeData),
        ),
        (
          getCancelSubscriptionInstruction(
            programAddress: subscriptionsProgramAddress,
            subscriber: a1,
            planPda: a2,
            subscriptionPda: a3,
            eventAuthority: a4,
            selfProgram: subscriptionsProgramAddress,
          ),
          const CancelSubscriptionInstructionData(),
        ),
        (
          getResumeSubscriptionInstruction(
            programAddress: subscriptionsProgramAddress,
            subscriber: a1,
            planPda: a2,
            subscriptionPda: a3,
            eventAuthority: a4,
            selfProgram: subscriptionsProgramAddress,
          ),
          const ResumeSubscriptionInstructionData(),
        ),
      ];

      for (final (instruction, _) in instructions) {
        expect(instruction.programAddress, subscriptionsProgramAddress);
        expect(instruction.accounts, isNotEmpty);
        expect(instruction.data, isNotNull);
      }

      expect(
        parseInitSubscriptionAuthorityInstruction(
          instructions[0].$1,
        ).discriminator,
        0,
      );
      expect(
        parseCreateFixedDelegationInstruction(
          instructions[1].$1,
        ).fixedDelegation,
        _fixedData,
      );
      expect(
        parseCreateRecurringDelegationInstruction(
          instructions[2].$1,
        ).recurringDelegation,
        _recurringData,
      );
      expect(
        parseRevokeDelegationInstruction(instructions[3].$1).discriminator,
        3,
      );
      expect(
        parseTransferFixedInstruction(instructions[4].$1).transferData,
        _transferData,
      );
      expect(
        parseTransferRecurringInstruction(instructions[5].$1).transferData,
        _transferData,
      );
      expect(
        parseCloseSubscriptionAuthorityInstruction(
          instructions[6].$1,
        ).discriminator,
        6,
      );
      expect(
        getPlanDataCodec().encode(
          parseCreatePlanInstruction(instructions[7].$1).planData,
        ),
        getPlanDataCodec().encode(_planData),
      );
      expect(
        getUpdatePlanDataCodec().encode(
          parseUpdatePlanInstruction(instructions[8].$1).updatePlanData,
        ),
        getUpdatePlanDataCodec().encode(_updatePlanData),
      );
      expect(parseDeletePlanInstruction(instructions[9].$1).discriminator, 9);
      expect(
        parseTransferSubscriptionInstruction(instructions[10].$1).transferData,
        _transferData,
      );
      expect(
        parseSubscribeInstruction(instructions[11].$1).subscribeData,
        _subscribeData,
      );
      expect(
        parseCancelSubscriptionInstruction(instructions[12].$1).discriminator,
        12,
      );
      expect(
        parseResumeSubscriptionInstruction(instructions[13].$1).discriminator,
        13,
      );
    });
  });

  group('generated errors', () {
    test('looks up known and unknown errors', () {
      expect(isSubscriptionsError(subscriptionsErrorNotSigner), isTrue);
      expect(
        getSubscriptionsErrorMessage(subscriptionsErrorNotSigner),
        'Account must be a signer',
      );
      expect(isSubscriptionsError(-1), isFalse);
      expect(getSubscriptionsErrorMessage(-1), isNull);
    });
  });

  group('generated PDAs', () {
    test('derives every PDA', () async {
      final values = await Future.wait([
        findEventAuthorityPda(programAddress: subscriptionsProgramAddress),
        findFixedDelegationPda(
          programAddress: subscriptionsProgramAddress,
          seeds: FixedDelegationSeeds(
            subscriptionAuthority: a1,
            delegator: a2,
            delegatee: a3,
            nonce: BigInt.one,
          ),
        ),
        findRecurringDelegationPda(
          programAddress: subscriptionsProgramAddress,
          seeds: RecurringDelegationSeeds(
            subscriptionAuthority: a1,
            delegator: a2,
            delegatee: a3,
            nonce: BigInt.two,
          ),
        ),
        findPlanPda(
          programAddress: subscriptionsProgramAddress,
          seeds: PlanSeeds(owner: a1, planId: BigInt.one),
        ),
        findSubscriptionAuthorityPda(
          programAddress: subscriptionsProgramAddress,
          seeds: const SubscriptionAuthoritySeeds(user: a1, tokenMint: a2),
        ),
        findSubscriptionDelegationPda(
          programAddress: subscriptionsProgramAddress,
          seeds: const SubscriptionDelegationSeeds(planPda: a1, subscriber: a2),
        ),
      ]);

      for (final (address, bump) in values) {
        expect(address, isA<Address>());
        expect(bump, inInclusiveRange(0, 255));
      }
    });
  });
}

final _planTerms = PlanTerms(
  amount: BigInt.from(42),
  periodHours: BigInt.from(24),
  createdAt: BigInt.from(1000),
);
final _planTermsClone = PlanTerms(
  amount: BigInt.from(42),
  periodHours: BigInt.from(24),
  createdAt: BigInt.from(1000),
);
final _planTermsAlt = PlanTerms(
  amount: BigInt.from(43),
  periodHours: BigInt.from(24),
  createdAt: BigInt.from(1000),
);
final _planData = PlanData(
  planId: BigInt.one,
  mint: a1,
  terms: _planTerms,
  endTs: BigInt.from(2000),
  destinations: const [a1, a2, a3, a4],
  pullers: const [a5, a6, a7, a8],
  metadataUri: 'https://example.com/plan',
);
final _planDataClone = PlanData(
  planId: BigInt.one,
  mint: a1,
  terms: _planTerms,
  endTs: BigInt.from(2000),
  destinations: const [a1, a2, a3, a4],
  pullers: const [a5, a6, a7, a8],
  metadataUri: 'https://example.com/plan',
);
final _planDataAlt = PlanData(
  planId: BigInt.two,
  mint: a1,
  terms: _planTerms,
  endTs: BigInt.from(2000),
  destinations: const [a1, a2, a3, a4],
  pullers: const [a5, a6, a7, a8],
  metadataUri: 'https://example.com/plan',
);
final _header = Header(
  discriminator: 1,
  version: 1,
  bump: 255,
  delegator: a1,
  delegatee: a2,
  payer: a3,
  initId: BigInt.from(9),
);
final _headerClone = Header(
  discriminator: 1,
  version: 1,
  bump: 255,
  delegator: a1,
  delegatee: a2,
  payer: a3,
  initId: BigInt.from(9),
);
final _headerAlt = Header(
  discriminator: 2,
  version: 1,
  bump: 255,
  delegator: a1,
  delegatee: a2,
  payer: a3,
  initId: BigInt.from(9),
);
final _fixedData = CreateFixedDelegationData(
  nonce: BigInt.one,
  amount: BigInt.from(50),
  expiryTs: BigInt.from(5000),
  expectedSubscriptionAuthorityInitId: BigInt.from(7),
);
final _fixedDataClone = CreateFixedDelegationData(
  nonce: BigInt.one,
  amount: BigInt.from(50),
  expiryTs: BigInt.from(5000),
  expectedSubscriptionAuthorityInitId: BigInt.from(7),
);
final _fixedDataAlt = CreateFixedDelegationData(
  nonce: BigInt.two,
  amount: BigInt.from(50),
  expiryTs: BigInt.from(5000),
  expectedSubscriptionAuthorityInitId: BigInt.from(7),
);
final _recurringData = CreateRecurringDelegationData(
  nonce: BigInt.two,
  amountPerPeriod: BigInt.from(10),
  periodLengthS: BigInt.from(3600),
  startTs: BigInt.from(100),
  expiryTs: BigInt.from(5000),
  expectedSubscriptionAuthorityInitId: BigInt.from(8),
);
final _recurringDataClone = CreateRecurringDelegationData(
  nonce: BigInt.two,
  amountPerPeriod: BigInt.from(10),
  periodLengthS: BigInt.from(3600),
  startTs: BigInt.from(100),
  expiryTs: BigInt.from(5000),
  expectedSubscriptionAuthorityInitId: BigInt.from(8),
);
final _recurringDataAlt = CreateRecurringDelegationData(
  nonce: BigInt.one,
  amountPerPeriod: BigInt.from(10),
  periodLengthS: BigInt.from(3600),
  startTs: BigInt.from(100),
  expiryTs: BigInt.from(5000),
  expectedSubscriptionAuthorityInitId: BigInt.from(8),
);
final _subscribeData = SubscribeData(
  planId: BigInt.one,
  planBump: 254,
  expectedMint: a1,
  expectedAmount: BigInt.from(42),
  expectedPeriodHours: BigInt.from(24),
  expectedCreatedAt: BigInt.from(1000),
  expectedSubscriptionAuthorityInitId: BigInt.from(7),
);
final _subscribeDataClone = SubscribeData(
  planId: BigInt.one,
  planBump: 254,
  expectedMint: a1,
  expectedAmount: BigInt.from(42),
  expectedPeriodHours: BigInt.from(24),
  expectedCreatedAt: BigInt.from(1000),
  expectedSubscriptionAuthorityInitId: BigInt.from(7),
);
final _subscribeDataAlt = SubscribeData(
  planId: BigInt.two,
  planBump: 254,
  expectedMint: a1,
  expectedAmount: BigInt.from(42),
  expectedPeriodHours: BigInt.from(24),
  expectedCreatedAt: BigInt.from(1000),
  expectedSubscriptionAuthorityInitId: BigInt.from(7),
);
final _transferData = TransferData(
  amount: BigInt.from(11),
  delegator: a1,
  mint: a2,
);
final _transferDataClone = TransferData(
  amount: BigInt.from(11),
  delegator: a1,
  mint: a2,
);
final _transferDataAlt = TransferData(
  amount: BigInt.from(12),
  delegator: a1,
  mint: a2,
);
final _updatePlanData = UpdatePlanData(
  status: 0,
  endTs: BigInt.from(3000),
  pullers: const [a1, a2, a3, a4],
  metadataUri: 'https://example.com/updated',
);
final _updatePlanDataClone = UpdatePlanData(
  status: 0,
  endTs: BigInt.from(3000),
  pullers: const [a1, a2, a3, a4],
  metadataUri: 'https://example.com/updated',
);
final _updatePlanDataAlt = UpdatePlanData(
  status: 1,
  endTs: BigInt.from(3000),
  pullers: const [a1, a2, a3, a4],
  metadataUri: 'https://example.com/updated',
);

final _fixedDelegation = FixedDelegation(
  header: _header,
  subscriptionAuthority: a4,
  mint: a5,
  amount: BigInt.from(50),
  expiryTs: BigInt.from(5000),
);
final _fixedDelegationClone = FixedDelegation(
  header: _header,
  subscriptionAuthority: a4,
  mint: a5,
  amount: BigInt.from(50),
  expiryTs: BigInt.from(5000),
);
final _fixedDelegationAlt = FixedDelegation(
  header: _header,
  subscriptionAuthority: a4,
  mint: a5,
  amount: BigInt.from(51),
  expiryTs: BigInt.from(5000),
);
final _plan = Plan(
  discriminator: 2,
  owner: a1,
  bump: 1,
  status: 1,
  data: _planData,
);
final _planClone = Plan(
  discriminator: 2,
  owner: a1,
  bump: 1,
  status: 1,
  data: _planData,
);
final _planAlt = Plan(
  discriminator: 3,
  owner: a1,
  bump: 1,
  status: 1,
  data: _planData,
);
final _recurringDelegation = RecurringDelegation(
  header: _header,
  subscriptionAuthority: a3,
  mint: a4,
  currentPeriodStartTs: BigInt.from(100),
  periodLengthS: BigInt.from(3600),
  expiryTs: BigInt.from(5000),
  amountPerPeriod: BigInt.from(10),
  amountPulledInPeriod: BigInt.from(5),
);
final _recurringDelegationClone = RecurringDelegation(
  header: _header,
  subscriptionAuthority: a3,
  mint: a4,
  currentPeriodStartTs: BigInt.from(100),
  periodLengthS: BigInt.from(3600),
  expiryTs: BigInt.from(5000),
  amountPerPeriod: BigInt.from(10),
  amountPulledInPeriod: BigInt.from(5),
);
final _recurringDelegationAlt = RecurringDelegation(
  header: _header,
  subscriptionAuthority: a3,
  mint: a4,
  currentPeriodStartTs: BigInt.from(101),
  periodLengthS: BigInt.from(3600),
  expiryTs: BigInt.from(5000),
  amountPerPeriod: BigInt.from(10),
  amountPulledInPeriod: BigInt.from(5),
);
final _subscriptionAuthority = SubscriptionAuthority(
  discriminator: 3,
  user: a1,
  tokenMint: a2,
  payer: a3,
  bump: 7,
  initId: BigInt.from(8),
);
final _subscriptionAuthorityClone = SubscriptionAuthority(
  discriminator: 3,
  user: a1,
  tokenMint: a2,
  payer: a3,
  bump: 7,
  initId: BigInt.from(8),
);
final _subscriptionAuthorityAlt = SubscriptionAuthority(
  discriminator: 4,
  user: a1,
  tokenMint: a2,
  payer: a3,
  bump: 7,
  initId: BigInt.from(8),
);
final _subscriptionDelegation = SubscriptionDelegation(
  header: _header,
  terms: _planTerms,
  amountPulledInPeriod: BigInt.from(4),
  currentPeriodStartTs: BigInt.from(100),
  expiresAtTs: BigInt.from(5000),
);
final _subscriptionDelegationClone = SubscriptionDelegation(
  header: _header,
  terms: _planTerms,
  amountPulledInPeriod: BigInt.from(4),
  currentPeriodStartTs: BigInt.from(100),
  expiresAtTs: BigInt.from(5000),
);
final _subscriptionDelegationAlt = SubscriptionDelegation(
  header: _header,
  terms: _planTerms,
  amountPulledInPeriod: BigInt.from(5),
  currentPeriodStartTs: BigInt.from(100),
  expiresAtTs: BigInt.from(5000),
);

void _expectValueObject(
  Object value,
  Object clone,
  Object other,
  String typeName,
) {
  expect(value, equals(clone));
  expect(value == other, isFalse);
  expect(value.hashCode, isA<int>());
  expect(value.toString(), contains(typeName));
}

void _roundTrip<T>(Codec<T, T> codec, T value) {
  final encoded = codec.encode(value) as List<int>;
  final decoded = codec.decode(Uint8List.fromList(encoded));
  expect(codec.encode(decoded), encoded);
}

void _roundTripAccount<T>(
  Codec<T, T> codec,
  T value,
  Account<T> Function(EncodedAccount) decode,
) {
  final data = codec.encode(value);
  final encoded = Account<Uint8List>(
    address: a1,
    data: data,
    executable: false,
    lamports: Lamports(BigInt.one),
    programAddress: subscriptionsProgramAddress,
    space: BigInt.from(data.length),
  );
  final decoded = decode(encoded);
  expect(codec.encode(decoded.data), data);
  expect(decoded.address, a1);
}
