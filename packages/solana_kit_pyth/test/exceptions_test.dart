import 'package:solana_kit_pyth/solana_kit_pyth.dart';
import 'package:test/test.dart';

void main() {
  group('PythException', () {
    test('renders its message', () {
      const exception = PythException('something broke');
      expect(exception.toString(), 'PythException: something broke');
    });
  });

  group('PythHttpException', () {
    test('renders the status without a body', () {
      const exception = PythHttpException(
        message: 'request failed',
        statusCode: 503,
      );
      expect(
        exception.toString(),
        'PythHttpException(status: 503): request failed',
      );
      expect(exception.body, isNull);
    });

    test('renders the status with a body', () {
      const exception = PythHttpException(
        message: 'request failed',
        statusCode: 418,
        body: 'teapot',
      );
      expect(
        exception.toString(),
        'PythHttpException(status: 418): request failed — teapot',
      );
      expect(exception.body, 'teapot');
    });
  });

  group('PythDecodeException', () {
    test('inherits the base rendering', () {
      const exception = PythDecodeException('bad bytes');
      expect(exception.toString(), 'PythException: bad bytes');
      expect(exception.message, 'bad bytes');
    });
  });
}
