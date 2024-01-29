import 'dart:async';

import 'package:meta/meta.dart';

/// Result class that can either contain a value on success,
/// or an error on failure
@immutable
class Result<R, S> {
  /// Create a result with a [value]
  const Result.ok([this._value])
      : assert(_value != null || Future<R> == Future<void>),
        _error = null;

  /// Create a Result with an [error]
  const Result.err(S error)
      : assert(Future<S> != Future<void>),
        _value = null,
        _error = error;

  /// Create a [Result] from a [Future].
  ///
  /// If [future] completes successfully then [Result] will contain its value,
  /// and if the [future] fails then its error will be contained in [Result]
  static Future<Result<R, S>> fromFuture<R, S>(
    Future<R> future, {
    required S Function(dynamic e, StackTrace s) error,
  }) async {
    try {
      return Result<R, S>.ok(await future);
    } catch (e, s) {
      return Result<R, S>.err(error(e, s));
    }
  }

  /// Create a [Result] from a callback that returns a [Future].
  ///
  /// If [future] completes successfully then [Result] will contain its value,
  /// and if the [future] fails then its error will be contained in [Result]
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

  final R? _value;
  final S? _error;

  /// Check if this [Result] contains an error
  bool get isError => _error != null;

  /// Get the value from this [Result]. This will throw error if this [Result]
  /// is an error. Check [isError] before accessing this.
  R get value => _value!;

  /// Get the error from this [Result]. This will throw error if this [Result]
  /// has a value instead. Check [isError] before accessing this.
  S get error => _error!;

  @override
  bool operator ==(Object other) =>
      other is Result<R, S> && other._value == _value && other._error == _error;

  @override
  int get hashCode => Object.hash(_value, _error);
}
