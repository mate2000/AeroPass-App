// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'capture_attempt_counter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CaptureAttemptCounter {

/// Failed attempts since [lastResetAt]. Incremented on any `rejected`
/// outcome (device- or processor-side); NOT incremented on `accepted`.
 int get count;/// Set on successful completion of this step (an `accepted` capture)
/// or explicit routing to retry guidance (research.md §3) — a future,
/// unrelated enrollment attempt starts with a clean counter rather
/// than inheriting a stale one.
 DateTime get lastResetAt;
/// Create a copy of CaptureAttemptCounter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CaptureAttemptCounterCopyWith<CaptureAttemptCounter> get copyWith => _$CaptureAttemptCounterCopyWithImpl<CaptureAttemptCounter>(this as CaptureAttemptCounter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CaptureAttemptCounter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CaptureAttemptCounter&&(identical(other.count, _this.count) || other.count == _this.count)&&(identical(other.lastResetAt, _this.lastResetAt) || other.lastResetAt == _this.lastResetAt));
}


@override
int get hashCode {
  final _this = this as CaptureAttemptCounter;
  return Object.hash(runtimeType,_this.count,_this.lastResetAt);
}

@override
String toString() {
  final _this = this as CaptureAttemptCounter;
  return 'CaptureAttemptCounter(count: ${_this.count}, lastResetAt: ${_this.lastResetAt})';
}


}

/// @nodoc
abstract mixin class $CaptureAttemptCounterCopyWith<$Res>  {
  factory $CaptureAttemptCounterCopyWith(CaptureAttemptCounter value, $Res Function(CaptureAttemptCounter) _then) = _$CaptureAttemptCounterCopyWithImpl;
@useResult
$Res call({
 int count, DateTime lastResetAt
});




}
/// @nodoc
class _$CaptureAttemptCounterCopyWithImpl<$Res>
    implements $CaptureAttemptCounterCopyWith<$Res> {
  _$CaptureAttemptCounterCopyWithImpl(this._self, this._then);

  final CaptureAttemptCounter _self;
  final $Res Function(CaptureAttemptCounter) _then;

/// Create a copy of CaptureAttemptCounter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? count = null,Object? lastResetAt = null,}) {
  return _then(CaptureAttemptCounter(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,lastResetAt: null == lastResetAt ? _self.lastResetAt : lastResetAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CaptureAttemptCounter].
extension CaptureAttemptCounterPatterns on CaptureAttemptCounter {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CaptureAttemptCounter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CaptureAttemptCounter() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CaptureAttemptCounter value)  $default,){
final _that = this;
switch (_that) {
case _CaptureAttemptCounter():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CaptureAttemptCounter value)?  $default,){
final _that = this;
switch (_that) {
case _CaptureAttemptCounter() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int count,  DateTime lastResetAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CaptureAttemptCounter() when $default != null:
return $default(_that.count,_that.lastResetAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int count,  DateTime lastResetAt)  $default,) {final _that = this;
switch (_that) {
case _CaptureAttemptCounter():
return $default(_that.count,_that.lastResetAt);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int count,  DateTime lastResetAt)?  $default,) {final _that = this;
switch (_that) {
case _CaptureAttemptCounter() when $default != null:
return $default(_that.count,_that.lastResetAt);case _:
  return null;

}
}

}

/// @nodoc


class _CaptureAttemptCounter implements CaptureAttemptCounter {
  const _CaptureAttemptCounter({required this.count, required this.lastResetAt});
  

/// Failed attempts since [lastResetAt]. Incremented on any `rejected`
/// outcome (device- or processor-side); NOT incremented on `accepted`.
@override final  int count;
/// Set on successful completion of this step (an `accepted` capture)
/// or explicit routing to retry guidance (research.md §3) — a future,
/// unrelated enrollment attempt starts with a clean counter rather
/// than inheriting a stale one.
@override final  DateTime lastResetAt;

/// Create a copy of CaptureAttemptCounter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CaptureAttemptCounterCopyWith<_CaptureAttemptCounter> get copyWith => __$CaptureAttemptCounterCopyWithImpl<_CaptureAttemptCounter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CaptureAttemptCounter&&(identical(other.count, count) || other.count == count)&&(identical(other.lastResetAt, lastResetAt) || other.lastResetAt == lastResetAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,count,lastResetAt);
}

@override
String toString() {
    return 'CaptureAttemptCounter(count: $count, lastResetAt: $lastResetAt)';
}


}

/// @nodoc
abstract mixin class _$CaptureAttemptCounterCopyWith<$Res> implements $CaptureAttemptCounterCopyWith<$Res> {
  factory _$CaptureAttemptCounterCopyWith(_CaptureAttemptCounter value, $Res Function(_CaptureAttemptCounter) _then) = __$CaptureAttemptCounterCopyWithImpl;
@override @useResult
$Res call({
 int count, DateTime lastResetAt
});




}
/// @nodoc
class __$CaptureAttemptCounterCopyWithImpl<$Res>
    implements _$CaptureAttemptCounterCopyWith<$Res> {
  __$CaptureAttemptCounterCopyWithImpl(this._self, this._then);

  final _CaptureAttemptCounter _self;
  final $Res Function(_CaptureAttemptCounter) _then;

/// Create a copy of CaptureAttemptCounter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? count = null,Object? lastResetAt = null,}) {
  return _then(_CaptureAttemptCounter(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,lastResetAt: null == lastResetAt ? _self.lastResetAt : lastResetAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
