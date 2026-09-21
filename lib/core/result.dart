import 'package:freezed_annotation/freezed_annotation.dart';

part 'result.freezed.dart';

/// Sealed result type returned at every repository/use-case layer boundary,
/// per Constitution Principle IX ("Result objects at layer boundaries").
///
/// Repositories and use-cases MUST return `Result<T>` instead of throwing
/// across a layer boundary; exceptions are caught and converted at the
/// service boundary (see `lib/data/services/`).
@freezed
sealed class Result<T> with _$Result<T> {
  const factory Result.ok(T value) = Ok<T>;
  const factory Result.error(Object error, [StackTrace? stackTrace]) = Error<T>;

  const Result._();

  /// True when this is an [Ok] result.
  bool get isOk => this is Ok<T>;

  /// True when this is an [Error] result.
  bool get isError => this is Error<T>;

  /// Returns the success value, or `null` when this is an [Error].
  T? get valueOrNull => switch (this) {
    Ok<T>(:final value) => value,
    Error<T>() => null,
  };

  /// Pattern-matches over both variants, forcing exhaustive handling at
  /// every call site.
  R when<R>({
    required R Function(T value) ok,
    required R Function(Object error, StackTrace? stackTrace) error,
  }) => switch (this) {
    Ok<T>(:final value) => ok(value),
    Error<T>(error: final err, stackTrace: final st) => error(err, st),
  };
}
