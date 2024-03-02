import 'dart:async';

import 'package:res/res.dart';
import 'package:test/test.dart';

Future<int> throws() async {
  throw Error();
}

Future<int> noThrow() async => 0;

Future<int?> noThrowNullable() async => null;

Result<void, String> voidOk() => const Result.ok();

Result<void, String> voidError() => const Result.err('Error');

Future<void> futureVoidOk() async {}

Future<void> futureVoidError() async {
  throw Error();
}

void main() {
  group('Result', () {
    test('return value on success', () async {
      final result = await Result.fromFuture(
        noThrow(),
        error: (e, s) => '$e $s',
      );
      expect(result.isError, isFalse);
      expect(result.value, 0);
    });

    test('return error on error', () async {
      final result = await Result.fromFuture(
        throws(),
        error: (e, s) => '$e $s',
      );
      expect(result.isError, isTrue);
      expect(result.error, isA<String>());
    });

    test('void ok', () async {
      final result = voidOk();

      expect(result.isError, isFalse);
    });

    test('void throws error', () async {
      final result = voidError();

      expect(result.isError, isTrue);
      expect(result.error, isA<String>());
    });

    test('future void ok', () async {
      final result = await Result.fromFuture(
        futureVoidOk(),
        error: (e, s) => '$e $s',
      );
      expect(result.isError, isFalse);
    });

    test('future void throws error', () async {
      final result = await Result.fromFuture(
        futureVoidError(),
        error: (e, s) => '$e $s',
      );
      expect(result.isError, isTrue);
      expect(result.error, isA<String>());
    });

    test('nullable ok value', () async {
      final result = await Result.fromFuture(
        noThrowNullable(),
        error: (e, s) => '$e $s',
      );

      expect(result.isError, isFalse);
      expect(result.value, isNull);
    });
  });
}
