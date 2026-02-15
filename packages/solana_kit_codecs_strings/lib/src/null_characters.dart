/// Removes all null characters (`\u0000`) from a string.
///
/// This function cleans a string by stripping out any null characters,
/// which are often used as padding in fixed-size string encodings.
String removeNullCharacters(String value) {
  return value.replaceAll('\u0000', '');
}

/// Pads a string with null characters (`\u0000`) at the end to reach a
/// fixed length.
///
/// If the input string is shorter than the specified length, it is padded
/// with null characters until it reaches the desired size. If it is already
/// long enough, it remains unchanged.
String padNullCharacters(String value, int chars) {
  return value.padRight(chars, '\u0000');
}
