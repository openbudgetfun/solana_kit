import 'package:solana_kit_anchor/solana_kit_anchor.dart';
import 'package:test/test.dart';

void main() {
  test('standard errors use the Anchor 0.31 runtime code ranges', () {
    // These are the exact explicit and implicit discriminants in
    // anchor_lang::error::ErrorCode. Checking every code prevents a future
    // table edit from silently shifting the name associated with a runtime
    // error returned by a real program.
    expect(standardAnchorErrorMessages.keys, [
      100,
      101,
      102,
      103,
      1000,
      1001,
      1002,
      1500,
      ...List.generate(40, (index) => 2000 + index),
      ...List.generate(7, (index) => 2500 + index),
      ...List.generate(18, (index) => 3000 + index),
      4100,
      4101,
      4102,
      5000,
    ]);
  });

  test('range boundaries resolve to the names emitted by Anchor 0.31', () {
    expect(anchorProgramError(100).name, 'InstructionMissing');
    expect(anchorProgramError(103).name, 'InstructionDidNotSerialize');
    expect(anchorProgramError(1000).name, 'IdlInstructionStub');
    expect(anchorProgramError(1500).name, 'EventInstructionStub');
    expect(anchorProgramError(2000).name, 'ConstraintMut');
    expect(anchorProgramError(2001).name, 'ConstraintHasOne');
    expect(
      anchorProgramError(2039).name,
      'ConstraintMintTransferHookExtensionProgramId',
    );
    expect(anchorProgramError(2500).name, 'RequireViolated');
    expect(anchorProgramError(2506).name, 'RequireGteViolated');
    expect(anchorProgramError(3000).name, 'AccountDiscriminatorAlreadySet');
    expect(anchorProgramError(3017).name, 'AccountDuplicateReallocs');
    expect(anchorProgramError(4100).name, 'DeclaredProgramIdMismatch');
    expect(anchorProgramError(4102).name, 'InvalidNumericConversion');
    expect(anchorProgramError(5000).name, 'Deprecated');
  });
}
