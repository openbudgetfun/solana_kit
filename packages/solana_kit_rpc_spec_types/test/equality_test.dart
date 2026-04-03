import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';
import 'package:test/test.dart';

void main() {
  // ---------------------------------------------------------------------------
  // RpcRequest
  // ---------------------------------------------------------------------------
  group('RpcRequest equality', () {
    test('equal when methodName and params match', () {
      const a = RpcRequest(methodName: 'getBalance', params: ['addr1']);
      const b = RpcRequest(methodName: 'getBalance', params: ['addr1']);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('equal with null params', () {
      const a = RpcRequest<Object?>(methodName: 'getHealth', params: null);
      const b = RpcRequest<Object?>(methodName: 'getHealth', params: null);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('identical instance equals itself', () {
      const a = RpcRequest(methodName: 'getSlot', params: 42);
      expect(a, equals(a));
    });

    test('not equal when methodName differs', () {
      const a = RpcRequest(methodName: 'getBalance', params: 'addr');
      const b = RpcRequest(methodName: 'getSlot', params: 'addr');
      expect(a, isNot(equals(b)));
    });

    test('not equal when params differ', () {
      const a = RpcRequest(methodName: 'getBalance', params: 'addr1');
      const b = RpcRequest(methodName: 'getBalance', params: 'addr2');
      expect(a, isNot(equals(b)));
    });

    test('not equal to a different type', () {
      const a = RpcRequest(methodName: 'getBalance', params: 'addr');
      expect(a, isNot(equals('getBalance')));
    });

    test('toString contains field values', () {
      const a = RpcRequest(methodName: 'getBalance', params: 'addr');
      expect(a.toString(), contains('RpcRequest'));
      expect(a.toString(), contains('getBalance'));
    });
  });

  // ---------------------------------------------------------------------------
  // RpcErrorResponsePayload
  // ---------------------------------------------------------------------------
  group('RpcErrorResponsePayload equality', () {
    test('equal when all fields match', () {
      const a = RpcErrorResponsePayload(
        code: -32600,
        message: 'Invalid request',
      );
      const b = RpcErrorResponsePayload(
        code: -32600,
        message: 'Invalid request',
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('equal when data is non-null and matching', () {
      const a = RpcErrorResponsePayload(
        code: -32000,
        message: 'Server error',
        data: 'extra info',
      );
      const b = RpcErrorResponsePayload(
        code: -32000,
        message: 'Server error',
        data: 'extra info',
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('identical instance equals itself', () {
      const a = RpcErrorResponsePayload(code: 0, message: 'ok');
      expect(a, equals(a));
    });

    test('not equal when code differs', () {
      const a = RpcErrorResponsePayload(code: -32600, message: 'err');
      const b = RpcErrorResponsePayload(code: -32601, message: 'err');
      expect(a, isNot(equals(b)));
    });

    test('not equal when message differs', () {
      const a = RpcErrorResponsePayload(code: -32600, message: 'err A');
      const b = RpcErrorResponsePayload(code: -32600, message: 'err B');
      expect(a, isNot(equals(b)));
    });

    test('not equal when data differs', () {
      const a = RpcErrorResponsePayload(
        code: -32000,
        message: 'err',
        data: 'detail1',
      );
      const b = RpcErrorResponsePayload(
        code: -32000,
        message: 'err',
        data: 'detail2',
      );
      expect(a, isNot(equals(b)));
    });

    test('not equal when one data is null', () {
      const a = RpcErrorResponsePayload(
        code: -32000,
        message: 'err',
        data: 'info',
      );
      const b = RpcErrorResponsePayload(code: -32000, message: 'err');
      expect(a, isNot(equals(b)));
    });

    test('not equal to a different type', () {
      const a = RpcErrorResponsePayload(code: 0, message: 'ok');
      expect(a, isNot(equals('ok')));
    });

    test('toString contains field values', () {
      const a = RpcErrorResponsePayload(code: -32600, message: 'Invalid');
      expect(a.toString(), contains('RpcErrorResponsePayload'));
      expect(a.toString(), contains('-32600'));
      expect(a.toString(), contains('Invalid'));
    });
  });

  // ---------------------------------------------------------------------------
  // RpcResponseResult
  // ---------------------------------------------------------------------------
  group('RpcResponseResult equality', () {
    test('equal when id and result match', () {
      const a = RpcResponseResult(id: '1', result: 42);
      const b = RpcResponseResult(id: '1', result: 42);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('equal with string result', () {
      const a = RpcResponseResult(id: '7', result: 'ok');
      const b = RpcResponseResult(id: '7', result: 'ok');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('identical instance equals itself', () {
      const a = RpcResponseResult(id: '2', result: true);
      expect(a, equals(a));
    });

    test('not equal when id differs', () {
      const a = RpcResponseResult(id: '1', result: 42);
      const b = RpcResponseResult(id: '2', result: 42);
      expect(a, isNot(equals(b)));
    });

    test('not equal when result differs', () {
      const a = RpcResponseResult(id: '1', result: 42);
      const b = RpcResponseResult(id: '1', result: 99);
      expect(a, isNot(equals(b)));
    });

    test('not equal to an RpcResponseError with same id', () {
      const result = RpcResponseResult(id: '1', result: 42);
      const error = RpcResponseError<Object?>(
        id: '1',
        error: RpcErrorResponsePayload(code: -32000, message: 'err'),
      );
      expect(result, isNot(equals(error)));
    });

    test('toString contains field values', () {
      const a = RpcResponseResult(id: '3', result: 'hello');
      expect(a.toString(), contains('RpcResponseResult'));
      expect(a.toString(), contains('3'));
      expect(a.toString(), contains('hello'));
    });
  });

  // ---------------------------------------------------------------------------
  // RpcResponseError
  // ---------------------------------------------------------------------------
  group('RpcResponseError equality', () {
    const payload1 = RpcErrorResponsePayload(code: -32000, message: 'bad');
    const payload2 = RpcErrorResponsePayload(
      code: -32601,
      message: 'not found',
    );

    test('equal when id and error match', () {
      const a = RpcResponseError<Object?>(id: '5', error: payload1);
      const b = RpcResponseError<Object?>(id: '5', error: payload1);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('identical instance equals itself', () {
      const a = RpcResponseError<Object?>(id: '0', error: payload1);
      expect(a, equals(a));
    });

    test('not equal when id differs', () {
      const a = RpcResponseError<Object?>(id: '5', error: payload1);
      const b = RpcResponseError<Object?>(id: '6', error: payload1);
      expect(a, isNot(equals(b)));
    });

    test('not equal when error differs', () {
      const a = RpcResponseError<Object?>(id: '5', error: payload1);
      const b = RpcResponseError<Object?>(id: '5', error: payload2);
      expect(a, isNot(equals(b)));
    });

    test('not equal to a different type', () {
      const a = RpcResponseError<Object?>(id: '5', error: payload1);
      expect(a, isNot(equals('error')));
    });

    test('toString contains field values', () {
      const a = RpcResponseError<Object?>(id: '5', error: payload1);
      expect(a.toString(), contains('RpcResponseError'));
      expect(a.toString(), contains('5'));
    });
  });
}
