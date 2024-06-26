// ignore_for_file: avoid_print

import 'dart:math';

import 'package:res/res.dart';

Future<int> functionThatCanThrowError() async {
  final n = Random().nextInt(10);

  if (n < 5) {
    throw RangeError(n);
  }

  return n;
}

Future<Result<int, String>> functionThatDoesNotThrow() async {
  try {
    return Result.ok(await functionThatCanThrowError());
  } catch (e, s) {
    return Result.err(e.toString() + s.toString());
  }

  // Or shorter
  // return Result.fromFuture(
  //   functionThatCanThrowError(),
  //   error: (e, s) => 'Out of Range',
  // );
}

void main() async {
  final result = await functionThatDoesNotThrow()
      .flatMap((_) => const Result.ok(0))
      .flatMap((_) => const Result.ok(0));

  // Or
  // final result = Result.fromFuture(
  //   functionThatCanThrowError(),
  //   error: (e, s) => '$e $s',
  // );

  if (result.isError) {
    return print('Error');
  }

  return print(result.value);
}
