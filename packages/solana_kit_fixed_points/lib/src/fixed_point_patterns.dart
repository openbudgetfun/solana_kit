/// Shared regular expressions for fixed-point string parsing and formatting.
///
/// These were previously constructed inside the functions that use them, which
/// compiled a fresh pattern for every parsed value. Parsing a list of balances
/// paid that cost once per element. Hoisting them here compiles each pattern
/// once per isolate.
library;

/// Matches a string of one or more decimal digits.
final RegExp decimalDigitsRegExp = RegExp(r'^\d+$');

/// Matches a single decimal digit anywhere in the subject.
final RegExp anyDecimalDigitRegExp = RegExp(r'\d');

/// Matches a non-zero decimal digit, used to detect a truncated value.
final RegExp nonZeroDecimalDigitRegExp = RegExp('[1-9]');

/// Matches one or more trailing zeroes, trimmed from fractional output.
final RegExp trailingZeroesRegExp = RegExp(r'0+$');
