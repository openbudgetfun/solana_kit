/**
 * Convert a Uint8Array to a Dart hex literal string.
 * Used for discriminator constants.
 */
export function bytesToDartHexList(bytes: Uint8Array): string {
  const pairs: string[] = [];
  for (let i = 0; i < bytes.length; i++) {
    pairs.push(`0x${bytes[i].toString(16).padStart(2, "0")}`);
  }
  return `[${pairs.join(", ")}]`;
}

/**
 * Convert a Uint8Array to a Dart Uint8List.fromList() expression.
 */
export function bytesToDartUint8List(bytes: Uint8Array): string {
  const hex = bytesToDartHexList(bytes);
  return `Uint8List.fromList(${hex})`;
}
