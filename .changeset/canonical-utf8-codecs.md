---
"solana_kit_codecs_strings": major
"solana_kit_memo": test
---

# Preserve UTF-8 data exactly during decoding

UTF-8 codecs now preserve embedded null characters and reject malformed byte sequences. Lossy compatibility modes and null-character rejection modes have been removed; callers can opt into null removal explicitly with `removeNullCharacters` after decoding.

```dart
final value = getUtf8Codec().decode(bytes);
final withoutPadding = removeNullCharacters(value);
```
