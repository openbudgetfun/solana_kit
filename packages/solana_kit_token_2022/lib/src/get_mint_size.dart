import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import 'package:solana_kit_token_2022/src/generated/types/extension.dart';

/// The base serialized size of a Token-2022 mint account without extensions.
const mintSize = 82;

/// Returns the serialized size of a Token-2022 mint account.
int getMintSize([List<Extension>? extensions]) {
  if (extensions == null) return mintSize;

  final extensionEncoder = getHiddenPrefixEncoder(
    getArrayEncoder(getExtensionEncoder(), size: const RemainderArraySize()),
    [getConstantEncoder(padLeftEncoder(getU8Encoder(), 83).encode(1))],
  );

  return mintSize + getEncodedSize(extensions, extensionEncoder);
}
