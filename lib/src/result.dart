import 'dart:async';

import 'package:meta/meta.dart';

@immutable
class Result<R, S> {
  const Result.ok([this._value])
      : assert(_value != null || Future<R> == Future<void>),
        _error = null;

  const Result.err(S error)
      : assert(Future<S> != Future<void>),
        _value = null,
        _error = error;

  static Future<Result<R, S>> fromFuture<R, S>(
    Future<R> future, {
    required S Function(dynamic, StackTrace) error,
  }) async {
    try {
      return Result.ok(await future);
    } catch (e, s) {
      return Result.err(error(e, s));
    }
  }

  final R? _value;
  final S? _error;

  bool get isError => _error != null;

  R get value => _value!;

  S get error => _error!;

  @override
  bool operator ==(Object other) =>
      other is Result<R, S> && other._value == _value && other._error == _error;

  @override
  int get hashCode => Object.hash(_value, _error);
}
