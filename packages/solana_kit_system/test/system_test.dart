import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_system/solana_kit_system.dart'
    hide SystemInstruction, systemProgramAddress;
import 'package:solana_kit_system/src/generated/programs/system.dart'
    as system_program
    show systemProgramAddress;
import 'package:test/test.dart';

void main() {
  group('program constants', () {
    test('systemProgramAddress is correct', () {
      expect(
        system_program.systemProgramAddress,
        const Address('11111111111111111111111111111111'),
      );
    });
  });

  group('CreateAccount instruction', () {
    test('builds and parses correctly', () {
      const payer = Address('11111111111111111111111111111111');
      const newAccount = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');
      const owner = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');

      final ix = getCreateAccountInstruction(
        payer: payer,
        newAccount: newAccount,
        lamports: BigInt.from(1461600),
        space: BigInt.from(82),
        programOwner: owner,
      );

      expect(ix.programAddress, system_program.systemProgramAddress);
      final accounts = ix.accounts!;
      expect(accounts, hasLength(2));
      expect(accounts[0].role, AccountRole.writableSigner);
      expect(accounts[1].role, AccountRole.writableSigner);

      final parsed = parseCreateAccountInstruction(ix);
      expect(parsed.lamports, BigInt.from(1461600));
      expect(parsed.space, BigInt.from(82));
      expect(parsed.programOwner, owner);
    });
  });

  group('TransferSol instruction', () {
    test('builds and parses correctly', () {
      const from = Address('11111111111111111111111111111111');
      const to = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');

      final ix = getTransferSolInstruction(
        programAddress: system_program.systemProgramAddress,
        source: from,
        destination: to,
        amount: BigInt.from(1000000),
      );

      expect(ix.programAddress, system_program.systemProgramAddress);
      final accounts = ix.accounts!;
      expect(accounts, hasLength(2));
      expect(accounts[0].role, AccountRole.writableSigner);
      expect(accounts[1].role, AccountRole.writable);

      final parsed = parseTransferSolInstruction(ix);
      expect(parsed.amount, BigInt.from(1000000));
    });
  });

  group('Assign instruction', () {
    test('builds and parses correctly', () {
      const account = Address('11111111111111111111111111111111');
      const owner = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');

      final ix = getAssignInstruction(
        instructionProgramAddress: system_program.systemProgramAddress,
        account: account,
        programAddress: owner,
      );

      expect(ix.programAddress, system_program.systemProgramAddress);
      final accounts = ix.accounts!;
      expect(accounts, hasLength(1));
      expect(accounts[0].role, AccountRole.writableSigner);

      final parsed = parseAssignInstruction(ix);
      expect(parsed.programAddress, owner);
    });
  });

  group('Allocate instruction', () {
    test('builds and parses correctly', () {
      const account = Address('11111111111111111111111111111111');

      final ix = getAllocateInstruction(
        programAddress: system_program.systemProgramAddress,
        newAccount: account,
        space: BigInt.from(200),
      );

      expect(ix.programAddress, system_program.systemProgramAddress);
      final accounts = ix.accounts!;
      expect(accounts, hasLength(1));

      final parsed = parseAllocateInstruction(ix);
      expect(parsed.space, BigInt.from(200));
    });
  });

  group('With-seed instructions', () {
    test('build and parse correctly', () {
      const account = Address('11111111111111111111111111111111');
      const base = Address('11111111111111111111111111111112');
      const owner = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');
      const seed = 'vault';

      final assign = getAssignWithSeedInstruction(
        instructionProgramAddress: system_program.systemProgramAddress,
        account: account,
        baseAccount: base,
        base: base,
        seed: seed,
        programAddress: owner,
      );
      expect(assign.accounts![0].role, AccountRole.writable);
      expect(assign.accounts![1].role, AccountRole.readonlySigner);
      final parsedAssign = parseAssignWithSeedInstruction(assign);
      expect(parsedAssign.base, base);
      expect(parsedAssign.seed, seed);
      expect(parsedAssign.programAddress, owner);

      final allocate = getAllocateWithSeedInstruction(
        instructionProgramAddress: system_program.systemProgramAddress,
        newAccount: account,
        baseAccount: base,
        base: base,
        seed: seed,
        space: BigInt.from(512),
        programAddress: owner,
      );
      expect(allocate.accounts![0].role, AccountRole.writable);
      expect(allocate.accounts![1].role, AccountRole.readonlySigner);
      final parsedAllocate = parseAllocateWithSeedInstruction(allocate);
      expect(parsedAllocate.base, base);
      expect(parsedAllocate.seed, seed);
      expect(parsedAllocate.space, BigInt.from(512));
      expect(parsedAllocate.programAddress, owner);

      final transfer = getTransferSolWithSeedInstruction(
        programAddress: system_program.systemProgramAddress,
        source: account,
        baseAccount: base,
        destination: owner,
        amount: BigInt.from(42),
        fromSeed: seed,
        fromOwner: owner,
      );
      expect(transfer.accounts, hasLength(3));
      expect(transfer.accounts![0].role, AccountRole.writable);
      expect(transfer.accounts![1].role, AccountRole.readonlySigner);
      expect(transfer.accounts![2].role, AccountRole.writable);
      final parsedTransfer = parseTransferSolWithSeedInstruction(transfer);
      expect(parsedTransfer.amount, BigInt.from(42));
      expect(parsedTransfer.fromSeed, seed);
      expect(parsedTransfer.fromOwner, owner);
    });
  });

  group('Nonce account codec', () {
    test('encodes, decodes, and formats nonce accounts', () {
      const authority = Address('11111111111111111111111111111111');
      const blockhash = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');

      final nonce = Nonce(
        version: NonceVersion.current,
        state: NonceState.initialized,
        authority: authority,
        blockhash: blockhash,
        lamportsPerSignature: BigInt.from(5000),
      );

      final encoded = getNonceEncoder().encode(nonce);
      final decoded = getNonceDecoder().decode(encoded);
      final viaCodec = getNonceCodec().decode(encoded);

      expect(nonceSize, 80);
      expect(decoded, nonce);
      expect(viaCodec, nonce);
      expect(decoded.version, NonceVersion.current);
      expect(decoded.state, NonceState.initialized);
      expect(decoded.authority, authority);
      expect(decoded.blockhash, blockhash);
      expect(decoded.lamportsPerSignature, BigInt.from(5000));
      expect(decoded.hashCode, nonce.hashCode);
      expect(decoded.toString(), contains('Nonce('));
    });

    test('builds and parses nonce management instructions', () {
      const nonceAccount = Address('11111111111111111111111111111111');
      const recentBlockhashes = Address('11111111111111111111111111111113');
      const rent = Address('11111111111111111111111111111114');
      const nonceAuthority = Address('11111111111111111111111111111112');
      const recipient = Address('11111111111111111111111111111115');
      const replacementAuthority = Address('11111111111111111111111111111116');

      final initialize = getInitializeNonceAccountInstruction(
        programAddress: system_program.systemProgramAddress,
        nonceAccount: nonceAccount,
        recentBlockhashesSysvar: recentBlockhashes,
        rentSysvar: rent,
        nonceAuthority: nonceAuthority,
      );

      expect(initialize.accounts, hasLength(3));
      expect(initialize.accounts![0].role, AccountRole.writable);
      expect(initialize.accounts![1].role, AccountRole.readonly);
      expect(initialize.accounts![2].role, AccountRole.readonly);
      expect(
        parseInitializeNonceAccountInstruction(initialize).nonceAuthority,
        nonceAuthority,
      );

      final advance = getAdvanceNonceAccountInstruction(
        programAddress: system_program.systemProgramAddress,
        nonceAccount: nonceAccount,
        recentBlockhashesSysvar: recentBlockhashes,
        nonceAuthority: nonceAuthority,
      );
      expect(advance.accounts, hasLength(3));
      expect(advance.accounts![2].role, AccountRole.readonlySigner);
      expect(
        parseAdvanceNonceAccountInstruction(advance).discriminator,
        isNonZero,
      );

      final authorize = getAuthorizeNonceAccountInstruction(
        programAddress: system_program.systemProgramAddress,
        nonceAccount: nonceAccount,
        nonceAuthority: nonceAuthority,
        newNonceAuthority: replacementAuthority,
      );
      expect(authorize.accounts, hasLength(2));
      expect(authorize.accounts![1].role, AccountRole.readonlySigner);
      expect(
        parseAuthorizeNonceAccountInstruction(authorize).newNonceAuthority,
        replacementAuthority,
      );

      final withdraw = getWithdrawNonceAccountInstruction(
        programAddress: system_program.systemProgramAddress,
        nonceAccount: nonceAccount,
        recipientAccount: recipient,
        recentBlockhashesSysvar: recentBlockhashes,
        rentSysvar: rent,
        nonceAuthority: nonceAuthority,
        withdrawAmount: BigInt.from(99),
      );
      expect(withdraw.accounts, hasLength(5));
      expect(withdraw.accounts![0].role, AccountRole.writable);
      expect(withdraw.accounts![1].role, AccountRole.writable);
      expect(withdraw.accounts![4].role, AccountRole.readonlySigner);
      expect(
        parseWithdrawNonceAccountInstruction(withdraw).withdrawAmount,
        BigInt.from(99),
      );

      final upgrade = getUpgradeNonceAccountInstruction(
        programAddress: system_program.systemProgramAddress,
        nonceAccount: nonceAccount,
      );
      expect(upgrade.accounts, hasLength(1));
      expect(upgrade.accounts![0].role, AccountRole.writable);
      expect(
        parseUpgradeNonceAccountInstruction(upgrade).discriminator,
        isNonZero,
      );
    });

    test('builds and parses create account with seed', () {
      const payer = Address('11111111111111111111111111111111');
      const newAccount = Address('11111111111111111111111111111112');
      const base = Address('11111111111111111111111111111113');
      const owner = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');
      const seed = 'nonce';

      final ix = getCreateAccountWithSeedInstruction(
        instructionProgramAddress: system_program.systemProgramAddress,
        payer: payer,
        newAccount: newAccount,
        baseAccount: base,
        base: base,
        seed: seed,
        amount: BigInt.from(123),
        space: BigInt.from(80),
        programAddress: owner,
      );

      expect(ix.accounts, hasLength(3));
      expect(ix.accounts![0].role, AccountRole.writableSigner);
      expect(ix.accounts![1].role, AccountRole.writable);
      expect(ix.accounts![2].role, AccountRole.readonlySigner);

      final parsed = parseCreateAccountWithSeedInstruction(ix);
      expect(parsed.base, base);
      expect(parsed.seed, seed);
      expect(parsed.amount, BigInt.from(123));
      expect(parsed.space, BigInt.from(80));
      expect(parsed.programAddress, owner);
    });
  });

  group('data codecs', () {
    test('round-trip enum and instruction data codecs', () {
      expect(
        getNonceStateCodec().decode(
          getNonceStateCodec().encode(NonceState.initialized),
        ),
        NonceState.initialized,
      );
      expect(
        getNonceVersionCodec().decode(
          getNonceVersionCodec().encode(NonceVersion.current),
        ),
        NonceVersion.current,
      );

      expect(
        getCreateAccountInstructionDataCodec()
            .decode(
              getCreateAccountInstructionDataCodec().encode(
                CreateAccountInstructionData(
                  lamports: BigInt.one,
                  space: BigInt.from(80),
                  programOwner: const Address(
                    'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA',
                  ),
                ),
              ),
            )
            .programOwner,
        const Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA'),
      );
      expect(
        getAdvanceNonceAccountInstructionDataCodec()
            .decode(
              getAdvanceNonceAccountInstructionDataCodec().encode(
                const AdvanceNonceAccountInstructionData(),
              ),
            )
            .discriminator,
        4,
      );
      expect(
        getAuthorizeNonceAccountInstructionDataCodec()
            .decode(
              getAuthorizeNonceAccountInstructionDataCodec().encode(
                const AuthorizeNonceAccountInstructionData(
                  newNonceAuthority: Address(
                    '11111111111111111111111111111112',
                  ),
                ),
              ),
            )
            .newNonceAuthority,
        const Address('11111111111111111111111111111112'),
      );
      expect(
        getWithdrawNonceAccountInstructionDataCodec()
            .decode(
              getWithdrawNonceAccountInstructionDataCodec().encode(
                WithdrawNonceAccountInstructionData(
                  withdrawAmount: BigInt.from(7),
                ),
              ),
            )
            .withdrawAmount,
        BigInt.from(7),
      );
      expect(
        getUpgradeNonceAccountInstructionDataCodec()
            .decode(
              getUpgradeNonceAccountInstructionDataCodec().encode(
                const UpgradeNonceAccountInstructionData(),
              ),
            )
            .discriminator,
        12,
      );
    });
  });

  group('error constants', () {
    test('system error helpers are defined', () {
      expect(systemErrorAccountAlreadyInUse, 0);
      expect(systemErrorResultWithNegativeLamports, 1);
      expect(systemErrorInvalidProgramId, 2);
      expect(systemErrorInvalidAccountDataLength, 3);
      expect(systemErrorMaxSeedLengthExceeded, 4);
      expect(systemErrorAddressWithSeedMismatch, 5);
      expect(systemErrorNonceNoRecentBlockhashes, 6);
      expect(systemErrorNonceBlockhashNotExpired, 7);
      expect(systemErrorNonceUnexpectedBlockhashValue, 8);
      expect(
        getSystemErrorMessage(systemErrorInvalidProgramId),
        'cannot assign account to this program id',
      );
      expect(getSystemErrorMessage(999), isNull);
      expect(isSystemError(systemErrorNonceUnexpectedBlockhashValue), isTrue);
      expect(isSystemError(999), isFalse);
    });
  });
}
