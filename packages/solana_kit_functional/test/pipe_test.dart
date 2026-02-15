import 'package:solana_kit_functional/solana_kit_functional.dart';
import 'package:test/test.dart';

void main() {
  group('pipe', () {
    test('can pipe a single value', () {
      expect(true.pipe((v) => v), isTrue);
      expect('test'.pipe((v) => v), equals('test'));
      expect(1.pipe((v) => v), equals(1));
      expect(null.pipe((v) => v), isNull);
    });

    test('can pipe a single function', () {
      expect('test'.pipe((value) => value.toUpperCase()), equals('TEST'));
    });

    test('can pipe multiple functions', () {
      expect(
        'test'
            .pipe((value) => value.toUpperCase())
            .pipe((value) => '$value!')
            .pipe((value) => '$value$value$value'),
        equals('TEST!TEST!TEST!'),
      );
      expect(
        1
            .pipe((value) => value + 1)
            .pipe((value) => value + 2)
            .pipe((value) => value + 3),
        equals(7),
      );
      expect(
        1
            .pipe((value) => value + 1)
            .pipe((value) => value * 2)
            .pipe((value) => value - 1),
        equals(3),
      );
    });

    test('can pipe multiple functions with different types', () {
      expect(
        1
            .pipe((value) => value + 1)
            .pipe((value) => value.toString())
            .pipe((value) => '$value!'),
        equals('2!'),
      );
      expect(
        'test'
            .pipe((value) => value.toUpperCase())
            .pipe((value) => value.length)
            .pipe((value) => value + 1),
        equals(5),
      );
      expect(
        1
            .pipe((value) => value + 1)
            .pipe((value) => value * 2)
            .pipe((value) => value - 1)
            .pipe((value) => value.toString())
            .pipe((value) => '$value!'),
        equals('3!'),
      );
    });

    group('mutating objects', () {
      test('will not mutate an object directly', () {
        final startObj = {'hello': 'world'};
        final endObj = startObj.pipe((obj) {
          obj['hello'] = 'there';
          return obj;
        });
        expect(identical(startObj, endObj), isTrue);
      });

      test('will mutate a cloned object', () {
        final startObj = {'hello': 'world'};
        final endObj = startObj.pipe((obj) => {...obj, 'hello': 'there'});
        expect(endObj, equals({'hello': 'there'}));
      });
    });

    group('combining objects', () {
      Map<String, Object?> combine(
        Map<String, Object?> a,
        Map<String, Object?> b,
      ) {
        return {...a, ...b};
      }

      test('can combine two objects', () {
        expect(
          {'a': 1}.pipe((value) => combine(value, {'b': 2})),
          equals({'a': 1, 'b': 2}),
        );
      });

      test('can combine four objects', () {
        expect(
          {'a': 1}
              .pipe((value) => combine(value, {'b': 2}))
              .pipe((value) => combine(value, {'c': 3}))
              .pipe((value) => combine(value, {'d': 4})),
          equals({'a': 1, 'b': 2, 'c': 3, 'd': 4}),
        );
      });
    });

    group('combining lists', () {
      List<int> combine(List<int> a, List<int> b) {
        return [...a, ...b];
      }

      test('can combine two lists', () {
        expect([1].pipe((value) => combine(value, [2])), equals([1, 2]));
      });

      test('can combine four lists', () {
        expect(
          [1]
              .pipe((value) => combine(value, [2]))
              .pipe((value) => combine(value, [3]))
              .pipe((value) => combine(value, [4])),
          equals([1, 2, 3, 4]),
        );
      });
    });

    group('combining strings', () {
      String combine(String a, String b) {
        return '$a$b';
      }

      test('can combine two strings', () {
        expect('a'.pipe((value) => combine(value, 'b')), equals('ab'));
      });

      test('can combine four strings', () {
        expect(
          'a'
              .pipe((value) => combine(value, 'b'))
              .pipe((value) => combine(value, 'c'))
              .pipe((value) => combine(value, 'd')),
          equals('abcd'),
        );
      });
    });

    group('appending or creating lists on objects', () {
      Map<String, Object?> addOrAppend(Map<String, Object?> obj, String value) {
        final d = obj['d'];
        if (d is List<String>) {
          return {
            ...obj,
            'd': [...d, value],
          };
        } else {
          return {
            ...obj,
            'd': [value],
          };
        }
      }

      Map<String, Object?> dropList(Map<String, Object?> obj) {
        if (obj.containsKey('d')) {
          return Map.fromEntries(obj.entries.where((e) => e.key != 'd'));
        }
        return obj;
      }

      test('can create the list', () {
        expect(
          <String, Object?>{'a': 1}.pipe((value) => addOrAppend(value, 'test')),
          equals({
            'a': 1,
            'd': ['test'],
          }),
        );
      });

      test('can append to the list', () {
        expect(
          <String, Object?>{
            'a': 1,
            'd': ['test'],
          }.pipe((value) => addOrAppend(value, 'test')),
          equals({
            'a': 1,
            'd': ['test', 'test'],
          }),
        );
      });

      test('can create and append to the list', () {
        expect(
          <String, Object?>{'a': 1, 'b': 'test'}
              .pipe((value) => addOrAppend(value, 'test'))
              .pipe((value) => addOrAppend(value, 'test again')),
          equals({
            'a': 1,
            'b': 'test',
            'd': ['test', 'test again'],
          }),
        );
      });

      test('can create and append to the list multiple times', () {
        expect(
          <String, Object?>{'a': 1, 'b': 'test'}
              .pipe((value) => addOrAppend(value, 'test'))
              .pipe((value) => addOrAppend(value, 'test again'))
              .pipe((value) => addOrAppend(value, 'test again'))
              .pipe((value) => addOrAppend(value, 'test again')),
          equals({
            'a': 1,
            'b': 'test',
            'd': ['test', 'test again', 'test again', 'test again'],
          }),
        );
      });

      test('can create the list, do some other operations, '
          'then append to the list', () {
        expect(
          <String, Object?>{'a': 1, 'b': 'test'}
              .pipe((value) => addOrAppend(value, 'test'))
              .pipe((value) => addOrAppend(value, 'test again'))
              .pipe((value) => {...value, 'b': '${value['b']}!'})
              .pipe((value) => addOrAppend(value, 'test again')),
          equals({
            'a': 1,
            'b': 'test!',
            'd': ['test', 'test again', 'test again'],
          }),
        );
      });

      test('can create the list, append to it, do some other operations, '
          'then drop it', () {
        expect(
          <String, Object?>{'a': 1, 'b': 'test'}
              .pipe((value) => addOrAppend(value, 'test'))
              .pipe((value) => addOrAppend(value, 'test again'))
              .pipe((value) => {...value, 'b': '${value['b']}!'})
              .pipe(dropList),
          equals({'a': 1, 'b': 'test!'}),
        );
      });

      test('can create the list, append to it, do some other operations, '
          'then drop it, then create/append to it again', () {
        expect(
          <String, Object?>{'a': 1, 'b': 'test'}
              .pipe((value) => addOrAppend(value, 'test'))
              .pipe((value) => addOrAppend(value, 'test again'))
              .pipe((value) => {...value, 'b': '${value['b']}!'})
              .pipe(dropList)
              .pipe((value) => addOrAppend(value, 'test again')),
          equals({
            'a': 1,
            'b': 'test!',
            'd': ['test again'],
          }),
        );
      });
    });

    group('capturing errors', () {
      String throws(String a) {
        throw Exception('test error');
      }

      test('can capture errors', () {
        expect(
          () => 'init'.pipe(throws),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('test error'),
            ),
          ),
        );
      });

      test('can capture errors with multiple throws', () {
        expect(
          () => 'init'.pipe(throws).pipe(throws).pipe(throws),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('test error'),
            ),
          ),
        );
      });

      test('can capture errors when throw occurs early in pipe', () {
        expect(
          () => 'init'
              .pipe(throws)
              .pipe((value) => value.toUpperCase())
              .pipe((value) => '$value!')
              .pipe((value) => '$value$value$value'),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('test error'),
            ),
          ),
        );
      });
    });

    group('nested pipes', () {
      test('can pipe a single value from a nested pipe of a single value', () {
        expect(1.pipe((v) => v).pipe((v) => v).pipe((v) => v), equals(1));
      });

      test(
        'can pipe a single value from a nested pipe of multiple functions',
        () {
          expect(
            1
                .pipe((value) => value + 1)
                .pipe((value) => value * 2)
                .pipe((value) => value - 1)
                .pipe((v) => v)
                .pipe((v) => v),
            equals(3),
          );
        },
      );

      test(
        'can pipe multiple functions on a nested pipe of multiple functions',
        () {
          expect(
            1
                .pipe((value) => value + 1)
                .pipe((value) => value * 2)
                .pipe((value) => value - 1)
                .pipe((v) => v)
                .pipe((v) => v)
                .pipe((value) => value.toString())
                .pipe((value) => '$value!'),
            equals('3!'),
          );
        },
      );

      test('can pipe an initial value through multiple functions, apply a '
          'nested pipe, then apply more functions', () {
        expect(
          1
              .pipe((value) => value + 1)
              .pipe((value) => value * 2)
              .pipe((value) => value - 1)
              .pipe(
                (value) => value.pipe((v) => v.toString()).pipe((v) => '$v!'),
              )
              .pipe((value) => '$value##')
              .pipe((value) => '$value$value'),
          equals('3!##3!##'),
        );
      });
    });

    test('can pipe an initial object through multiple functions, apply a '
        'nested pipe, then apply more functions', () {
      expect(
        <String, int>{'a': 1}
            .pipe((value) => {...value, 'b': 2})
            .pipe((value) => {...value, 'c': 3})
            .pipe((value) => {...value, 'd': 4})
            .pipe(
              (value) => value
                  .pipe((v) => {...v, 'e': 5})
                  .pipe((v) => {...v, 'f': 6})
                  .pipe((v) => {...v, 'g': 7}),
            )
            .pipe((value) => {...value, 'h': 8})
            .pipe((value) => {...value, 'i': 9})
            .pipe((value) => {...value, 'j': 10}),
        equals({
          'a': 1,
          'b': 2,
          'c': 3,
          'd': 4,
          'e': 5,
          'f': 6,
          'g': 7,
          'h': 8,
          'i': 9,
          'j': 10,
        }),
      );
    });

    test('can pipe an initial object through multiple functions, apply a '
        'nested pipe to one field, then apply more functions', () {
      expect(
        <String, Object?>{'a': 1}
            .pipe((value) => {...value, 'b': 2})
            .pipe((value) => {...value, 'c': 3})
            .pipe((value) {
              return {
                ...value,
                'd': <String>[]
                    .pipe((d) => [...d, 'test'])
                    .pipe((d) => [...d, 'test again'])
                    .pipe((d) => [...d, 'test a third time']),
              };
            })
            .pipe((value) => {...value, 'e': 5})
            .pipe((value) => {...value, 'f': 6})
            .pipe((value) => {...value, 'g': 7}),
        equals({
          'a': 1,
          'b': 2,
          'c': 3,
          'd': ['test', 'test again', 'test a third time'],
          'e': 5,
          'f': 6,
          'g': 7,
        }),
      );
    });
  });
}
