// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'service_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ServiceStatus {

 Map<JourneyStep, StepHealth> get steps;/// When the source says a retry is worth trying; null when it does not
/// say (FR-008).
 DateTime? get retryAfter;
/// Create a copy of ServiceStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServiceStatusCopyWith<ServiceStatus> get copyWith => _$ServiceStatusCopyWithImpl<ServiceStatus>(this as ServiceStatus, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ServiceStatus;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServiceStatus&&const DeepCollectionEquality().equals(other.steps, _this.steps)&&(identical(other.retryAfter, _this.retryAfter) || other.retryAfter == _this.retryAfter));
}


@override
int get hashCode {
  final _this = this as ServiceStatus;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.steps),_this.retryAfter);
}

@override
String toString() {
  final _this = this as ServiceStatus;
  return 'ServiceStatus(steps: ${_this.steps}, retryAfter: ${_this.retryAfter})';
}


}

/// @nodoc
abstract mixin class $ServiceStatusCopyWith<$Res>  {
  factory $ServiceStatusCopyWith(ServiceStatus value, $Res Function(ServiceStatus) _then) = _$ServiceStatusCopyWithImpl;
@useResult
$Res call({
 Map<JourneyStep, StepHealth> steps, DateTime? retryAfter
});




}
/// @nodoc
class _$ServiceStatusCopyWithImpl<$Res>
    implements $ServiceStatusCopyWith<$Res> {
  _$ServiceStatusCopyWithImpl(this._self, this._then);

  final ServiceStatus _self;
  final $Res Function(ServiceStatus) _then;

/// Create a copy of ServiceStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? steps = null,Object? retryAfter = freezed,}) {
  return _then(ServiceStatus(
steps: null == steps ? _self.steps : steps // ignore: cast_nullable_to_non_nullable
as Map<JourneyStep, StepHealth>,retryAfter: freezed == retryAfter ? _self.retryAfter : retryAfter // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ServiceStatus].
extension ServiceStatusPatterns on ServiceStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServiceStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServiceStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServiceStatus value)  $default,){
final _that = this;
switch (_that) {
case _ServiceStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServiceStatus value)?  $default,){
final _that = this;
switch (_that) {
case _ServiceStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<JourneyStep, StepHealth> steps,  DateTime? retryAfter)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServiceStatus() when $default != null:
return $default(_that.steps,_that.retryAfter);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<JourneyStep, StepHealth> steps,  DateTime? retryAfter)  $default,) {final _that = this;
switch (_that) {
case _ServiceStatus():
return $default(_that.steps,_that.retryAfter);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<JourneyStep, StepHealth> steps,  DateTime? retryAfter)?  $default,) {final _that = this;
switch (_that) {
case _ServiceStatus() when $default != null:
return $default(_that.steps,_that.retryAfter);case _:
  return null;

}
}

}

/// @nodoc


class _ServiceStatus extends ServiceStatus {
  const _ServiceStatus({required  Map<JourneyStep, StepHealth> steps, this.retryAfter}): _steps = steps,super._();
  

 final  Map<JourneyStep, StepHealth> _steps;
@override Map<JourneyStep, StepHealth> get steps {
  if (_steps is EqualUnmodifiableMapView) return _steps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_steps);
}

/// When the source says a retry is worth trying; null when it does not
/// say (FR-008).
@override final  DateTime? retryAfter;

/// Create a copy of ServiceStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServiceStatusCopyWith<_ServiceStatus> get copyWith => __$ServiceStatusCopyWithImpl<_ServiceStatus>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServiceStatus&&const DeepCollectionEquality().equals(other.steps, _steps)&&(identical(other.retryAfter, retryAfter) || other.retryAfter == retryAfter));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_steps),retryAfter);
}

@override
String toString() {
    return 'ServiceStatus(steps: $steps, retryAfter: $retryAfter)';
}


}

/// @nodoc
abstract mixin class _$ServiceStatusCopyWith<$Res> implements $ServiceStatusCopyWith<$Res> {
  factory _$ServiceStatusCopyWith(_ServiceStatus value, $Res Function(_ServiceStatus) _then) = __$ServiceStatusCopyWithImpl;
@override @useResult
$Res call({
 Map<JourneyStep, StepHealth> steps, DateTime? retryAfter
});




}
/// @nodoc
class __$ServiceStatusCopyWithImpl<$Res>
    implements _$ServiceStatusCopyWith<$Res> {
  __$ServiceStatusCopyWithImpl(this._self, this._then);

  final _ServiceStatus _self;
  final $Res Function(_ServiceStatus) _then;

/// Create a copy of ServiceStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? steps = null,Object? retryAfter = freezed,}) {
  return _then(_ServiceStatus(
steps: null == steps ? _self._steps : steps // ignore: cast_nullable_to_non_nullable
as Map<JourneyStep, StepHealth>,retryAfter: freezed == retryAfter ? _self.retryAfter : retryAfter // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
