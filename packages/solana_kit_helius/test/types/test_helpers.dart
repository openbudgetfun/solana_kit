import 'package:test/test.dart';

typedef JsonFactory<T> = T Function(Map<String, Object?> json);
typedef JsonEncoder<T> = Map<String, Object?> Function(T value);

void expectJsonRoundTrip<T>(
  String description,
  Map<String, Object?> json,
  JsonFactory<T> fromJson,
  JsonEncoder<T> toJson,
) {
  test(description, () {
    final value = fromJson(json);
    expect(toJson(value), json);
  });
}
