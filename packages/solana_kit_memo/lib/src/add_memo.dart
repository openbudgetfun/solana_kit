import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_memo/src/generated/instructions/add_memo.dart';

/// Creates a Memo program instruction from plain UTF-8 [memo] text.
Instruction getAddMemoInstruction({
  required String memo,
  Address programAddress = memoProgramAddress,
}) {
  return getAddMemoInstructionFromData(
    data: AddMemoInstructionData(memo: memo),
    programAddress: programAddress,
  );
}
