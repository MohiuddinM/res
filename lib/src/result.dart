import 'dart:async';

import 'package:meta/meta.dart';

/// Result class that can either contain a value on success,
/// or an error on failure
@immutable
class Result<R, S> {
  /// Create a result with a [value]
  const Result.ok([this._value])
      : assert(_value != null || null is R || Future<R> == Future<void>),
        _error = null;

  /// Create a Result with an [error]
  const Result.err(S error)
      : assert(Future<S> != Future<void>),
        _value = null,
        _error = error;

  /// Wraps a Future result into a [Result].
  ///
  /// If [future] completes successfully then [Result] will contain its value,
  /// and if the [future] fails then its error will be contained in [Result]
  static Future<Result<R, S>> ofFuture<R, S>(
    Future<R> future, {
    required S Function(dynamic e, StackTrace s) error,
  }) async {
    try {
      return Result<R, S>.ok(await future);
    } catch (e, s) {
      return Result<R, S>.err(error(e, s));
    }
  }

  /// Create a [Result] from a [Future].
  @Deprecated('use Result.ofFuture')
  static Future<Result<R, S>> fromFuture<R, S>(
    Future<R> future, {
    required S Function(dynamic e, StackTrace s) error,
  }) =>
      Result.ofFuture(future, error: error);

  /// Create a [Result] from a callback that returns a [Future].
  ///
  /// If [future] completes successfully then [Result] will contain its value,
  /// and if the [future] fails then its error will be contained in [Result]
  @Deprecated('use Result.of')
  static Future<Result<R, S>> fromAsyncCallback<R, S>(
    Future<R> Function() future, {
    required S Function(dynamic e, StackTrace s) error,
  }) async {
    try {
      return Result<R, S>.ok(await future.call());
    } catch (e, s) {
      return Result<R, S>.err(error(e, s));
    }
  }

  /// Wraps a function that can throw an error and returns a [Result].
  ///
  /// If the wrapped function [func] executes successfully then [Result] will
  /// contain its value, and if the [func] fails then its error will be
  /// contained in [Result]
  static Future<Result<R, S>> of<R, S>(
    FutureOr<R> Function() func, {
    required S Function(dynamic e, StackTrace s) error,
  }) async {
    try {
      return Result<R, S>.ok(await func.call());
    } catch (e, s) {
      return Result<R, S>.err(error(e, s));
    }
  }

  final R? _value;
  final S? _error;

  /// Check if this [Result] contains an error
  bool get isError => _error != null;

  /// Opposite of [isError]
  bool get isNotError => _error == null;

  /// Get the value from this [Result]. This will throw error if this [Result]
  /// is an error. Check [isError] before accessing this.
  R get value => _value as R;

  /// Get the error from this [Result]. This will throw error if this [Result]
  /// has a value instead. Check [isError] before accessing this.
  S get error => _error!;

  /// The flatMap function allows chaining of operations that return a [Result].
  /// If this Result is [value], it applies [f] to the value inside.
  /// If this Result is [error], it returns the error.
  Result<U, S> flatMap<U>(Result<U, S> Function(R) f) =>
      isError ? Result.err(error) : f(value);

  @override
  bool operator ==(Object other) =>
      other is Result<R, S> && other._value == _value && other._error == _error;

  @override
  int get hashCode => Object.hash(_value, _error);

  @override
  String toString() => isError ? 'Result.err($error)' : 'Result.ok($value)';
}

/// Extension method on Future of Result
extension FutureResultX<R, S> on Future<Result<R, S>> {
  /// Called flatMap on result after resolving the result future
  Future<Result<T, S>> flatMap<T>(Result<T, S> Function(R) f) async =>
      (await this).flatMap(f);
}
