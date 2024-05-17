import 'dart:async';

import 'package:res/res.dart';
import 'package:test/test.dart';

Future<int> throwError() async {
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

Result<int, String> intError() => const Result.err('error');

Result<int, String> intOk([int v = 0]) => Result.ok(v);

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
        throwError(),
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

    test('ok assertion test', () async {
      expect(Result<int, String>.ok, throwsA(isA<AssertionError>()));
      expect(Result<int?, String>.ok, returnsNormally);
    });

    test('flatMap works', () async {
      final errorCase = intOk()
          .flatMap((v) => Result.ok(v++))
          .flatMap((v) => intError())
          .flatMap((v) {
        assert(false);
        return Result.ok(v++);
      });
      expect(errorCase.isError, isTrue);
      expect(errorCase.error, 'error');

      final okCase = intOk()
          .flatMap((v) => Result.ok(++v))
          .flatMap((v) => Result.ok(++v))
          .flatMap((v) => Result.ok(++v));
      expect(okCase.value, 3);
    });
  });
}
