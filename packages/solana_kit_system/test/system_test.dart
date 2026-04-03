import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_system/solana_kit_system.dart';
import 'package:test/test.dart';

void main() {
  group('program constants', () {
    test('systemProgramAddress is correct', () {
      expect(
        systemProgramAddress,
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
        instructionProgramAddress: systemProgramAddress,
        payer: payer,
        newAccount: newAccount,
        lamports: BigInt.from(1461600),
        space: BigInt.from(82),
        programAddress: owner,
      );

      expect(ix.programAddress, systemProgramAddress);
      final accounts = ix.accounts!;
      expect(accounts, hasLength(2));
      expect(accounts[0].role, AccountRole.writableSigner);
      expect(accounts[1].role, AccountRole.writableSigner);

      final parsed = parseCreateAccountInstruction(ix);
      expect(parsed.lamports, BigInt.from(1461600));
      expect(parsed.space, BigInt.from(82));
      expect(parsed.programAddress, owner);
    });
  });

  group('TransferSol instruction', () {
    test('builds and parses correctly', () {
      const from = Address('11111111111111111111111111111111');
      const to = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');

      final ix = getTransferSolInstruction(
        programAddress: systemProgramAddress,
        source: from,
        destination: to,
        amount: BigInt.from(1000000),
      );

      expect(ix.programAddress, systemProgramAddress);
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
        instructionProgramAddress: systemProgramAddress,
        account: account,
        programAddress: owner,
      );

      expect(ix.programAddress, systemProgramAddress);
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
        programAddress: systemProgramAddress,
        newAccount: account,
        space: BigInt.from(200),
      );

      expect(ix.programAddress, systemProgramAddress);
      final accounts = ix.accounts!;
      expect(accounts, hasLength(1));

      final parsed = parseAllocateInstruction(ix);
      expect(parsed.space, BigInt.from(200));
    });
  });

  group('Nonce account codec', () {
    test('encodes and decodes nonce account', () {
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

      expect(decoded.version, NonceVersion.current);
      expect(decoded.state, NonceState.initialized);
      expect(decoded.authority, authority);
      expect(decoded.blockhash, blockhash);
      expect(decoded.lamportsPerSignature, BigInt.from(5000));
    });
  });

  group('error constants', () {
    test('system error codes are defined', () {
      expect(systemErrorAccountAlreadyInUse, isNotNull);
      expect(systemErrorResultWithNegativeLamports, isNotNull);
    });
  });
}
