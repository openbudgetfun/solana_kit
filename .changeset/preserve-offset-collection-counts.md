---
"codama-renderers-dart": patch
---

# Preserve offset collection length codecs

Keep pre-offset and post-offset wrappers around prefixed array, map, and set lengths. This lets generated Dart codecs represent compact layouts with multiple dynamic tails whose lengths live in a fixed header.

For example, a length codec can write a `u8` count at header byte zero, then restore the cursor before encoding the tail:

```ts
prefixedCountNode(
  postOffsetTypeNode(
    preOffsetTypeNode(numberTypeNode("u8"), 0, "absolute"),
    0,
    "preOffset",
  ),
);
```
