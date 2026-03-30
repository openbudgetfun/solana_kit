import fs from 'node:fs/promises';
import path from 'node:path';
import { pathToFileURL } from 'node:url';

const nodeModulesDir = process.env.UPSTREAM_KIT_NODE_MODULES;
if (!nodeModulesDir) {
  throw new Error('UPSTREAM_KIT_NODE_MODULES must point to the installed upstream node_modules directory.');
}

const kitEntryPath = path.join(nodeModulesDir, '@solana', 'kit', 'dist', 'index.node.mjs');
const kitPackageJsonPath = path.join(nodeModulesDir, '@solana', 'kit', 'package.json');

const kit = await import(pathToFileURL(kitEntryPath).href);
const { version } = JSON.parse(await fs.readFile(kitPackageJsonPath, 'utf8'));

function serializeSeed(seed) {
  if (typeof seed === 'string') {
    return { kind: 'string', value: seed };
  }

  return { kind: 'bytes', value: Array.from(seed) };
}

function serializeValidationCase(coerce, validate, input) {
  const isValid = validate(input);
  let errorCode = null;

  if (!isValid) {
    try {
      coerce(input);
    } catch (error) {
      errorCode = error?.context?.__code ?? null;
    }
  }

  return { input, isValid, errorCode };
}

function buildBlockhashTransactionCase({ name, version: transactionVersion, feePayer, blockhash, lastValidBlockHeight, instruction }) {
  let message = kit.createTransactionMessage({ version: transactionVersion });
  message = kit.setTransactionMessageFeePayer(kit.address(feePayer), message);
  message = kit.setTransactionMessageLifetimeUsingBlockhash(
    { blockhash, lastValidBlockHeight: BigInt(lastValidBlockHeight) },
    message,
  );

  if (instruction) {
    message = kit.appendTransactionMessageInstruction(
      {
        programAddress: kit.address(instruction.programAddress),
        accounts: instruction.accounts.map(account => ({
          address: kit.address(account.address),
          role: kit.AccountRole[account.role],
        })),
        data: new Uint8Array(instruction.data),
      },
      message,
    );
  }

  const compiledMessage = kit.compileTransactionMessage(message);
  const transaction = kit.compileTransaction(message);

  return {
    name,
    input: {
      version: transactionVersion === 'legacy' ? 'legacy' : 'v0',
      feePayer,
      blockhash,
      lastValidBlockHeight,
      instruction:
        instruction == null
          ? null
          : {
              programAddress: instruction.programAddress,
              accounts: instruction.accounts,
              data: instruction.data,
            },
    },
    output: {
      compiledMessage: {
        version: compiledMessage.version === 'legacy' ? 'legacy' : 'v0',
        header: {
          numReadonlyNonSignerAccounts: compiledMessage.header.numReadonlyNonSignerAccounts,
          numReadonlySignerAccounts: compiledMessage.header.numReadonlySignerAccounts,
          numSignerAccounts: compiledMessage.header.numSignerAccounts,
        },
        staticAccounts: [...compiledMessage.staticAccounts],
        lifetimeToken: compiledMessage.lifetimeToken,
        instructions: compiledMessage.instructions.map(compiledInstruction => ({
          programAddressIndex: compiledInstruction.programAddressIndex,
          accountIndices: [...compiledInstruction.accountIndices],
          data: [...compiledInstruction.data],
        })),
        addressTableLookups:
          compiledMessage.addressTableLookups == null
            ? null
            : compiledMessage.addressTableLookups.map(lookup => ({
                lookupTableAddress: lookup.lookupTableAddress,
                writableIndices: [...lookup.writableIndices],
                readonlyIndices: [...lookup.readonlyIndices],
              })),
      },
      compiledTransaction: {
        messageBytesBase64: Buffer.from(transaction.messageBytes).toString('base64'),
        wireTransactionBase64: kit.getBase64EncodedWireTransaction(transaction),
        signatureAddresses: Object.keys(transaction.signatures),
      },
    },
  };
}

const addressEncodingInput = '7EqQdEULxWcraVx3mXKFjc84LhCkMGZCkRuDpvcMwJeK';
const addressWithSeedBaseAddress = '11111111111111111111111111111111';
const addressWithSeedProgramAddress = 'Stake11111111111111111111111111111111111111';
const addressWithSeedSeed = 'seed';
const pdaProgramAddress = 'BPFLoaderUpgradeab1e11111111111111111111111';
const pdaSeeds = ['vault', Uint8Array.from([117, 115, 101, 114, 45, 52, 50])];

const fixture = {
  upstreamKitVersion: version,
  addresses: {
    validationCases: [
      '11111111111111111111111111111111',
      '7EqQdEULxWcraVx3mXKFjc84LhCkMGZCkRuDpvcMwJeK',
      '1111111111111111111111111111111',
      '1JEKNVnkbo3jma5nREBBJCDoXFVeKkD56V3xKrvRmWxFG',
      '2xea9jWJ9eca3dFiefTeSPP85c6qXqunCqL2h2JNffM',
    ].map(input => serializeValidationCase(kit.address, kit.isAddress, input)),
    encodingCase: {
      input: addressEncodingInput,
      encodedBytes: Array.from(kit.getAddressEncoder().encode(kit.address(addressEncodingInput))),
    },
    createAddressWithSeedCase: {
      input: {
        baseAddress: addressWithSeedBaseAddress,
        programAddress: addressWithSeedProgramAddress,
        seed: serializeSeed(addressWithSeedSeed),
      },
      output: await kit.createAddressWithSeed({
        baseAddress: kit.address(addressWithSeedBaseAddress),
        programAddress: kit.address(addressWithSeedProgramAddress),
        seed: addressWithSeedSeed,
      }),
    },
    createAddressWithSeedErrorCase: {
      input: {
        baseAddress: addressWithSeedBaseAddress,
        programAddress: addressWithSeedProgramAddress,
        seed: serializeSeed('a'.repeat(33)),
      },
      errorCode: await (async () => {
        try {
          await kit.createAddressWithSeed({
            baseAddress: kit.address(addressWithSeedBaseAddress),
            programAddress: kit.address(addressWithSeedProgramAddress),
            seed: 'a'.repeat(33),
          });
          return null;
        } catch (error) {
          return error?.context?.__code ?? null;
        }
      })(),
    },
    programDerivedAddressCase: {
      input: {
        programAddress: pdaProgramAddress,
        seeds: pdaSeeds.map(serializeSeed),
      },
      output: null,
    },
    programDerivedAddressErrorCase: {
      input: {
        programAddress: pdaProgramAddress,
        seeds: [serializeSeed('a'.repeat(33))],
      },
      errorCode: await (async () => {
        try {
          await kit.getProgramDerivedAddress({
            programAddress: kit.address(pdaProgramAddress),
            seeds: ['a'.repeat(33)],
          });
          return null;
        } catch (error) {
          return error?.context?.__code ?? null;
        }
      })(),
    },
  },
  signatures: {
    validationCases: [
      '1111111111111111111111111111111111111111111111111111111111111111',
      '3bwsNoq6EP89sShUAKBeB26aCC3KLGNajRm5wqwr6zRPP3gErZH7erSg3332SVY7Ru6cME43qT35Z7JKpZqCoPaL',
      'ttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt',
      '3bwsNoq6EP89sShUAKBeB26aCC3KLGNajRm5wqwr6zRPP3gErZH7erSg3332SVY7Ru6cME43qT35Z7JKpZqCoP',
    ].map(input => serializeValidationCase(kit.signature, kit.isSignature, input)),
  },
  transactions: {
    compileCases: [
      buildBlockhashTransactionCase({
        name: 'legacy_minimal_blockhash',
        version: 'legacy',
        feePayer: '7EqQdEULxWcraVx3mXKFjc84LhCkMGZCkRuDpvcMwJeK',
        blockhash: 'J4yED2jcMAHyQUg61DBmm4njmEydUr2WqrV9cdEcDDgL',
        lastValidBlockHeight: '100',
      }),
      buildBlockhashTransactionCase({
        name: 'v0_single_instruction_blockhash',
        version: 0,
        feePayer: '7EqQdEULxWcraVx3mXKFjc84LhCkMGZCkRuDpvcMwJeK',
        blockhash: 'J4yED2jcMAHyQUg61DBmm4njmEydUr2WqrV9cdEcDDgL',
        lastValidBlockHeight: '100',
        instruction: {
          programAddress: 'HZMKVnRrWLyQLwPLTTLKtY7ET4Cf7pQugrTr9eTBrpsf',
          accounts: [
            {
              address: 'H4RdPRWYk3pKw2CkNznxQK6J6herjgQke2pzFJW4GC6x',
              role: 'WRITABLE_SIGNER',
            },
            {
              address: '3LeBzRE9Yna5zi9R8vdT3MiNQYuEp4gJgVyhhwmqfCtd',
              role: 'WRITABLE',
            },
          ],
          data: [1, 2, 3],
        },
      }),
    ],
  },
};

fixture.addresses.programDerivedAddressCase.output = await (async () => {
  const [derivedAddress, bump] = await kit.getProgramDerivedAddress({
    programAddress: kit.address(pdaProgramAddress),
    seeds: pdaSeeds,
  });

  return {
    address: derivedAddress,
    bump,
  };
})();

process.stdout.write(`${JSON.stringify(fixture, null, 2)}\n`);
