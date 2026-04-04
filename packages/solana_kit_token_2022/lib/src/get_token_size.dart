import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import 'package:solana_kit_token_2022/src/generated/types/extension.dart';

/// The base serialized size of a Token-2022 token account without extensions.
const tokenSize = 165;

/// Returns the serialized size of a Token-2022 token account.
int getTokenSize([List<Extension>? extensions]) {
  if (extensions == null) return tokenSize;

  final extensionEncoder = getHiddenPrefixEncoder(
    getArrayEncoder(getExtensionEncoder(), size: const RemainderArraySize()),
    [getConstantEncoder(getU8Encoder().encode(2))],
  );

  return tokenSize + getEncodedSize(extensions, extensionEncoder);
}
