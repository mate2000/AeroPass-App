// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'service_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ServiceFailure {

 ServiceFailureClass get failureClass; VerificationStage get stage;/// True only when the job completed with `serviceFailure`: that job can
/// never finish, so a retry needs a new selfie (FR-004).
 bool get jobTerminal; DateTime get occurredAt;
/// Create a copy of ServiceFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServiceFailureCopyWith<ServiceFailure> get copyWith => _$ServiceFailureCopyWithImpl<ServiceFailure>(this as ServiceFailure, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ServiceFailure;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServiceFailure&&(identical(other.failureClass, _this.failureClass) || other.failureClass == _this.failureClass)&&(identical(other.stage, _this.stage) || other.stage == _this.stage)&&(identical(other.jobTerminal, _this.jobTerminal) || other.jobTerminal == _this.jobTerminal)&&(identical(other.occurredAt, _this.occurredAt) || other.occurredAt == _this.occurredAt));
}


@override
int get hashCode {
  final _this = this as ServiceFailure;
  return Object.hash(runtimeType,_this.failureClass,_this.stage,_this.jobTerminal,_this.occurredAt);
}

@override
String toString() {
  final _this = this as ServiceFailure;
  return 'ServiceFailure(failureClass: ${_this.failureClass}, stage: ${_this.stage}, jobTerminal: ${_this.jobTerminal}, occurredAt: ${_this.occurredAt})';
}


}

/// @nodoc
abstract mixin class $ServiceFailureCopyWith<$Res>  {
  factory $ServiceFailureCopyWith(ServiceFailure value, $Res Function(ServiceFailure) _then) = _$ServiceFailureCopyWithImpl;
@useResult
$Res call({
 ServiceFailureClass failureClass, VerificationStage stage, bool jobTerminal, DateTime occurredAt
});




}
/// @nodoc
class _$ServiceFailureCopyWithImpl<$Res>
    implements $ServiceFailureCopyWith<$Res> {
  _$ServiceFailureCopyWithImpl(this._self, this._then);

  final ServiceFailure _self;
  final $Res Function(ServiceFailure) _then;

/// Create a copy of ServiceFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? failureClass = null,Object? stage = null,Object? jobTerminal = null,Object? occurredAt = null,}) {
  return _then(ServiceFailure(
failureClass: null == failureClass ? _self.failureClass : failureClass // ignore: cast_nullable_to_non_nullable
as ServiceFailureClass,stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as VerificationStage,jobTerminal: null == jobTerminal ? _self.jobTerminal : jobTerminal // ignore: cast_nullable_to_non_nullable
as bool,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ServiceFailure].
extension ServiceFailurePatterns on ServiceFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServiceFailure value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServiceFailure() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServiceFailure value)  $default,){
final _that = this;
switch (_that) {
case _ServiceFailure():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServiceFailure value)?  $default,){
final _that = this;
switch (_that) {
case _ServiceFailure() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ServiceFailureClass failureClass,  VerificationStage stage,  bool jobTerminal,  DateTime occurredAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServiceFailure() when $default != null:
return $default(_that.failureClass,_that.stage,_that.jobTerminal,_that.occurredAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ServiceFailureClass failureClass,  VerificationStage stage,  bool jobTerminal,  DateTime occurredAt)  $default,) {final _that = this;
switch (_that) {
case _ServiceFailure():
return $default(_that.failureClass,_that.stage,_that.jobTerminal,_that.occurredAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ServiceFailureClass failureClass,  VerificationStage stage,  bool jobTerminal,  DateTime occurredAt)?  $default,) {final _that = this;
switch (_that) {
case _ServiceFailure() when $default != null:
return $default(_that.failureClass,_that.stage,_that.jobTerminal,_that.occurredAt);case _:
  return null;

}
}

}

/// @nodoc


class _ServiceFailure implements ServiceFailure {
  const _ServiceFailure({required this.failureClass, required this.stage, required this.jobTerminal, required this.occurredAt});
  

@override final  ServiceFailureClass failureClass;
@override final  VerificationStage stage;
/// True only when the job completed with `serviceFailure`: that job can
/// never finish, so a retry needs a new selfie (FR-004).
@override final  bool jobTerminal;
@override final  DateTime occurredAt;

/// Create a copy of ServiceFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServiceFailureCopyWith<_ServiceFailure> get copyWith => __$ServiceFailureCopyWithImpl<_ServiceFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServiceFailure&&(identical(other.failureClass, failureClass) || other.failureClass == failureClass)&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.jobTerminal, jobTerminal) || other.jobTerminal == jobTerminal)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,failureClass,stage,jobTerminal,occurredAt);
}

@override
String toString() {
    return 'ServiceFailure(failureClass: $failureClass, stage: $stage, jobTerminal: $jobTerminal, occurredAt: $occurredAt)';
}


}

/// @nodoc
abstract mixin class _$ServiceFailureCopyWith<$Res> implements $ServiceFailureCopyWith<$Res> {
  factory _$ServiceFailureCopyWith(_ServiceFailure value, $Res Function(_ServiceFailure) _then) = __$ServiceFailureCopyWithImpl;
@override @useResult
$Res call({
 ServiceFailureClass failureClass, VerificationStage stage, bool jobTerminal, DateTime occurredAt
});




}
/// @nodoc
class __$ServiceFailureCopyWithImpl<$Res>
    implements _$ServiceFailureCopyWith<$Res> {
  __$ServiceFailureCopyWithImpl(this._self, this._then);

  final _ServiceFailure _self;
  final $Res Function(_ServiceFailure) _then;

/// Create a copy of ServiceFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? failureClass = null,Object? stage = null,Object? jobTerminal = null,Object? occurredAt = null,}) {
  return _then(_ServiceFailure(
failureClass: null == failureClass ? _self.failureClass : failureClass // ignore: cast_nullable_to_non_nullable
as ServiceFailureClass,stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as VerificationStage,jobTerminal: null == jobTerminal ? _self.jobTerminal : jobTerminal // ignore: cast_nullable_to_non_nullable
as bool,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
