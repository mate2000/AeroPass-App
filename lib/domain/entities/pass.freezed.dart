// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pass.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Pass {

/// Opaque. Never logged or sent in an event (FR-015).
 String get passId; String get tripId;/// The reader the current code is for (FR-008).
 Checkpoint get nextCheckpoint;/// Only ever from the backend's status (FR-009).
 Set<Checkpoint> get validated;/// Server-defined: at most scheduled departure and 24 h from issuance.
 DateTime get validUntil; Duration get rotation;/// 015 FR-024: the checkpoints this pass opens, from the backend's
/// `permisos`. Today that is boarding only, so the screen must not
/// promise security.
 Set<Checkpoint> get checkpoints;
/// Create a copy of Pass
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PassCopyWith<Pass> get copyWith => _$PassCopyWithImpl<Pass>(this as Pass, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Pass;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Pass&&(identical(other.passId, _this.passId) || other.passId == _this.passId)&&(identical(other.tripId, _this.tripId) || other.tripId == _this.tripId)&&(identical(other.nextCheckpoint, _this.nextCheckpoint) || other.nextCheckpoint == _this.nextCheckpoint)&&const DeepCollectionEquality().equals(other.validated, _this.validated)&&(identical(other.validUntil, _this.validUntil) || other.validUntil == _this.validUntil)&&(identical(other.rotation, _this.rotation) || other.rotation == _this.rotation)&&const DeepCollectionEquality().equals(other.checkpoints, _this.checkpoints));
}


@override
int get hashCode {
  final _this = this as Pass;
  return Object.hash(runtimeType,_this.passId,_this.tripId,_this.nextCheckpoint,const DeepCollectionEquality().hash(_this.validated),_this.validUntil,_this.rotation,const DeepCollectionEquality().hash(_this.checkpoints));
}

@override
String toString() {
  final _this = this as Pass;
  return 'Pass(passId: ${_this.passId}, tripId: ${_this.tripId}, nextCheckpoint: ${_this.nextCheckpoint}, validated: ${_this.validated}, validUntil: ${_this.validUntil}, rotation: ${_this.rotation}, checkpoints: ${_this.checkpoints})';
}


}

/// @nodoc
abstract mixin class $PassCopyWith<$Res>  {
  factory $PassCopyWith(Pass value, $Res Function(Pass) _then) = _$PassCopyWithImpl;
@useResult
$Res call({
 String passId, String tripId, Checkpoint nextCheckpoint, Set<Checkpoint> validated, DateTime validUntil, Duration rotation, Set<Checkpoint> checkpoints
});




}
/// @nodoc
class _$PassCopyWithImpl<$Res>
    implements $PassCopyWith<$Res> {
  _$PassCopyWithImpl(this._self, this._then);

  final Pass _self;
  final $Res Function(Pass) _then;

/// Create a copy of Pass
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? passId = null,Object? tripId = null,Object? nextCheckpoint = null,Object? validated = null,Object? validUntil = null,Object? rotation = null,Object? checkpoints = null,}) {
  return _then(Pass(
passId: null == passId ? _self.passId : passId // ignore: cast_nullable_to_non_nullable
as String,tripId: null == tripId ? _self.tripId : tripId // ignore: cast_nullable_to_non_nullable
as String,nextCheckpoint: null == nextCheckpoint ? _self.nextCheckpoint : nextCheckpoint // ignore: cast_nullable_to_non_nullable
as Checkpoint,validated: null == validated ? _self.validated : validated // ignore: cast_nullable_to_non_nullable
as Set<Checkpoint>,validUntil: null == validUntil ? _self.validUntil : validUntil // ignore: cast_nullable_to_non_nullable
as DateTime,rotation: null == rotation ? _self.rotation : rotation // ignore: cast_nullable_to_non_nullable
as Duration,checkpoints: null == checkpoints ? _self.checkpoints : checkpoints // ignore: cast_nullable_to_non_nullable
as Set<Checkpoint>,
  ));
}

}


/// Adds pattern-matching-related methods to [Pass].
extension PassPatterns on Pass {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Pass value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Pass() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Pass value)  $default,){
final _that = this;
switch (_that) {
case _Pass():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Pass value)?  $default,){
final _that = this;
switch (_that) {
case _Pass() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String passId,  String tripId,  Checkpoint nextCheckpoint,  Set<Checkpoint> validated,  DateTime validUntil,  Duration rotation,  Set<Checkpoint> checkpoints)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Pass() when $default != null:
return $default(_that.passId,_that.tripId,_that.nextCheckpoint,_that.validated,_that.validUntil,_that.rotation,_that.checkpoints);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String passId,  String tripId,  Checkpoint nextCheckpoint,  Set<Checkpoint> validated,  DateTime validUntil,  Duration rotation,  Set<Checkpoint> checkpoints)  $default,) {final _that = this;
switch (_that) {
case _Pass():
return $default(_that.passId,_that.tripId,_that.nextCheckpoint,_that.validated,_that.validUntil,_that.rotation,_that.checkpoints);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String passId,  String tripId,  Checkpoint nextCheckpoint,  Set<Checkpoint> validated,  DateTime validUntil,  Duration rotation,  Set<Checkpoint> checkpoints)?  $default,) {final _that = this;
switch (_that) {
case _Pass() when $default != null:
return $default(_that.passId,_that.tripId,_that.nextCheckpoint,_that.validated,_that.validUntil,_that.rotation,_that.checkpoints);case _:
  return null;

}
}

}

/// @nodoc


class _Pass implements Pass {
  const _Pass({required this.passId, required this.tripId, required this.nextCheckpoint,  Set<Checkpoint> validated = const <Checkpoint>{}, required this.validUntil, this.rotation = passRotation,  Set<Checkpoint> checkpoints = const {Checkpoint.security, Checkpoint.boarding}}): _validated = validated,_checkpoints = checkpoints;
  

/// Opaque. Never logged or sent in an event (FR-015).
@override final  String passId;
@override final  String tripId;
/// The reader the current code is for (FR-008).
@override final  Checkpoint nextCheckpoint;
/// Only ever from the backend's status (FR-009).
 final  Set<Checkpoint> _validated;
/// Only ever from the backend's status (FR-009).
@override@JsonKey() Set<Checkpoint> get validated {
  if (_validated is EqualUnmodifiableSetView) return _validated;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_validated);
}

/// Server-defined: at most scheduled departure and 24 h from issuance.
@override final  DateTime validUntil;
@override@JsonKey() final  Duration rotation;
/// 015 FR-024: the checkpoints this pass opens, from the backend's
/// `permisos`. Today that is boarding only, so the screen must not
/// promise security.
 final  Set<Checkpoint> _checkpoints;
/// 015 FR-024: the checkpoints this pass opens, from the backend's
/// `permisos`. Today that is boarding only, so the screen must not
/// promise security.
@override@JsonKey() Set<Checkpoint> get checkpoints {
  if (_checkpoints is EqualUnmodifiableSetView) return _checkpoints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_checkpoints);
}


/// Create a copy of Pass
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PassCopyWith<_Pass> get copyWith => __$PassCopyWithImpl<_Pass>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Pass&&(identical(other.passId, passId) || other.passId == passId)&&(identical(other.tripId, tripId) || other.tripId == tripId)&&(identical(other.nextCheckpoint, nextCheckpoint) || other.nextCheckpoint == nextCheckpoint)&&const DeepCollectionEquality().equals(other.validated, _validated)&&(identical(other.validUntil, validUntil) || other.validUntil == validUntil)&&(identical(other.rotation, rotation) || other.rotation == rotation)&&const DeepCollectionEquality().equals(other.checkpoints, _checkpoints));
}


@override
int get hashCode {
    return Object.hash(runtimeType,passId,tripId,nextCheckpoint,const DeepCollectionEquality().hash(_validated),validUntil,rotation,const DeepCollectionEquality().hash(_checkpoints));
}

@override
String toString() {
    return 'Pass(passId: $passId, tripId: $tripId, nextCheckpoint: $nextCheckpoint, validated: $validated, validUntil: $validUntil, rotation: $rotation, checkpoints: $checkpoints)';
}


}

/// @nodoc
abstract mixin class _$PassCopyWith<$Res> implements $PassCopyWith<$Res> {
  factory _$PassCopyWith(_Pass value, $Res Function(_Pass) _then) = __$PassCopyWithImpl;
@override @useResult
$Res call({
 String passId, String tripId, Checkpoint nextCheckpoint, Set<Checkpoint> validated, DateTime validUntil, Duration rotation, Set<Checkpoint> checkpoints
});




}
/// @nodoc
class __$PassCopyWithImpl<$Res>
    implements _$PassCopyWith<$Res> {
  __$PassCopyWithImpl(this._self, this._then);

  final _Pass _self;
  final $Res Function(_Pass) _then;

/// Create a copy of Pass
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? passId = null,Object? tripId = null,Object? nextCheckpoint = null,Object? validated = null,Object? validUntil = null,Object? rotation = null,Object? checkpoints = null,}) {
  return _then(_Pass(
passId: null == passId ? _self.passId : passId // ignore: cast_nullable_to_non_nullable
as String,tripId: null == tripId ? _self.tripId : tripId // ignore: cast_nullable_to_non_nullable
as String,nextCheckpoint: null == nextCheckpoint ? _self.nextCheckpoint : nextCheckpoint // ignore: cast_nullable_to_non_nullable
as Checkpoint,validated: null == validated ? _self._validated : validated // ignore: cast_nullable_to_non_nullable
as Set<Checkpoint>,validUntil: null == validUntil ? _self.validUntil : validUntil // ignore: cast_nullable_to_non_nullable
as DateTime,rotation: null == rotation ? _self.rotation : rotation // ignore: cast_nullable_to_non_nullable
as Duration,checkpoints: null == checkpoints ? _self._checkpoints : checkpoints // ignore: cast_nullable_to_non_nullable
as Set<Checkpoint>,
  ));
}


}

/// @nodoc
mixin _$PassCode {

 String get payload; DateTime get windowStartsAt; DateTime get windowEndsAt;/// 015 FR-012: renewal failed, and this still-valid code stays on screen
/// while it is retried. The view says "Actualizando código…".
 bool get renewalPending;
/// Create a copy of PassCode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PassCodeCopyWith<PassCode> get copyWith => _$PassCodeCopyWithImpl<PassCode>(this as PassCode, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PassCode;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PassCode&&(identical(other.payload, _this.payload) || other.payload == _this.payload)&&(identical(other.windowStartsAt, _this.windowStartsAt) || other.windowStartsAt == _this.windowStartsAt)&&(identical(other.windowEndsAt, _this.windowEndsAt) || other.windowEndsAt == _this.windowEndsAt)&&(identical(other.renewalPending, _this.renewalPending) || other.renewalPending == _this.renewalPending));
}


@override
int get hashCode {
  final _this = this as PassCode;
  return Object.hash(runtimeType,_this.payload,_this.windowStartsAt,_this.windowEndsAt,_this.renewalPending);
}

@override
String toString() {
  final _this = this as PassCode;
  return 'PassCode(payload: ${_this.payload}, windowStartsAt: ${_this.windowStartsAt}, windowEndsAt: ${_this.windowEndsAt}, renewalPending: ${_this.renewalPending})';
}


}

/// @nodoc
abstract mixin class $PassCodeCopyWith<$Res>  {
  factory $PassCodeCopyWith(PassCode value, $Res Function(PassCode) _then) = _$PassCodeCopyWithImpl;
@useResult
$Res call({
 String payload, DateTime windowStartsAt, DateTime windowEndsAt, bool renewalPending
});




}
/// @nodoc
class _$PassCodeCopyWithImpl<$Res>
    implements $PassCodeCopyWith<$Res> {
  _$PassCodeCopyWithImpl(this._self, this._then);

  final PassCode _self;
  final $Res Function(PassCode) _then;

/// Create a copy of PassCode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? payload = null,Object? windowStartsAt = null,Object? windowEndsAt = null,Object? renewalPending = null,}) {
  return _then(PassCode(
payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as String,windowStartsAt: null == windowStartsAt ? _self.windowStartsAt : windowStartsAt // ignore: cast_nullable_to_non_nullable
as DateTime,windowEndsAt: null == windowEndsAt ? _self.windowEndsAt : windowEndsAt // ignore: cast_nullable_to_non_nullable
as DateTime,renewalPending: null == renewalPending ? _self.renewalPending : renewalPending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PassCode].
extension PassCodePatterns on PassCode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PassCode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PassCode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PassCode value)  $default,){
final _that = this;
switch (_that) {
case _PassCode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PassCode value)?  $default,){
final _that = this;
switch (_that) {
case _PassCode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String payload,  DateTime windowStartsAt,  DateTime windowEndsAt,  bool renewalPending)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PassCode() when $default != null:
return $default(_that.payload,_that.windowStartsAt,_that.windowEndsAt,_that.renewalPending);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String payload,  DateTime windowStartsAt,  DateTime windowEndsAt,  bool renewalPending)  $default,) {final _that = this;
switch (_that) {
case _PassCode():
return $default(_that.payload,_that.windowStartsAt,_that.windowEndsAt,_that.renewalPending);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String payload,  DateTime windowStartsAt,  DateTime windowEndsAt,  bool renewalPending)?  $default,) {final _that = this;
switch (_that) {
case _PassCode() when $default != null:
return $default(_that.payload,_that.windowStartsAt,_that.windowEndsAt,_that.renewalPending);case _:
  return null;

}
}

}

/// @nodoc


class _PassCode implements PassCode {
  const _PassCode({required this.payload, required this.windowStartsAt, required this.windowEndsAt, this.renewalPending = false});
  

@override final  String payload;
@override final  DateTime windowStartsAt;
@override final  DateTime windowEndsAt;
/// 015 FR-012: renewal failed, and this still-valid code stays on screen
/// while it is retried. The view says "Actualizando código…".
@override@JsonKey() final  bool renewalPending;

/// Create a copy of PassCode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PassCodeCopyWith<_PassCode> get copyWith => __$PassCodeCopyWithImpl<_PassCode>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PassCode&&(identical(other.payload, payload) || other.payload == payload)&&(identical(other.windowStartsAt, windowStartsAt) || other.windowStartsAt == windowStartsAt)&&(identical(other.windowEndsAt, windowEndsAt) || other.windowEndsAt == windowEndsAt)&&(identical(other.renewalPending, renewalPending) || other.renewalPending == renewalPending));
}


@override
int get hashCode {
    return Object.hash(runtimeType,payload,windowStartsAt,windowEndsAt,renewalPending);
}

@override
String toString() {
    return 'PassCode(payload: $payload, windowStartsAt: $windowStartsAt, windowEndsAt: $windowEndsAt, renewalPending: $renewalPending)';
}


}

/// @nodoc
abstract mixin class _$PassCodeCopyWith<$Res> implements $PassCodeCopyWith<$Res> {
  factory _$PassCodeCopyWith(_PassCode value, $Res Function(_PassCode) _then) = __$PassCodeCopyWithImpl;
@override @useResult
$Res call({
 String payload, DateTime windowStartsAt, DateTime windowEndsAt, bool renewalPending
});




}
/// @nodoc
class __$PassCodeCopyWithImpl<$Res>
    implements _$PassCodeCopyWith<$Res> {
  __$PassCodeCopyWithImpl(this._self, this._then);

  final _PassCode _self;
  final $Res Function(_PassCode) _then;

/// Create a copy of PassCode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? payload = null,Object? windowStartsAt = null,Object? windowEndsAt = null,Object? renewalPending = null,}) {
  return _then(_PassCode(
payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as String,windowStartsAt: null == windowStartsAt ? _self.windowStartsAt : windowStartsAt // ignore: cast_nullable_to_non_nullable
as DateTime,windowEndsAt: null == windowEndsAt ? _self.windowEndsAt : windowEndsAt // ignore: cast_nullable_to_non_nullable
as DateTime,renewalPending: null == renewalPending ? _self.renewalPending : renewalPending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$PassState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PassState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'PassState()';
}


}

/// @nodoc
class $PassStateCopyWith<$Res>  {
$PassStateCopyWith(PassState _, $Res Function(PassState) __);
}


/// Adds pattern-matching-related methods to [PassState].
extension PassStatePatterns on PassState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PassActive value)?  active,TResult Function( PassExpired value)?  expired,TResult Function( PassRevoked value)?  revoked,TResult Function( PassBoarded value)?  boarded,TResult Function( PassFlightChanged value)?  flightChanged,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PassActive() when active != null:
return active(_that);case PassExpired() when expired != null:
return expired(_that);case PassRevoked() when revoked != null:
return revoked(_that);case PassBoarded() when boarded != null:
return boarded(_that);case PassFlightChanged() when flightChanged != null:
return flightChanged(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PassActive value)  active,required TResult Function( PassExpired value)  expired,required TResult Function( PassRevoked value)  revoked,required TResult Function( PassBoarded value)  boarded,required TResult Function( PassFlightChanged value)  flightChanged,}){
final _that = this;
switch (_that) {
case PassActive():
return active(_that);case PassExpired():
return expired(_that);case PassRevoked():
return revoked(_that);case PassBoarded():
return boarded(_that);case PassFlightChanged():
return flightChanged(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PassActive value)?  active,TResult? Function( PassExpired value)?  expired,TResult? Function( PassRevoked value)?  revoked,TResult? Function( PassBoarded value)?  boarded,TResult? Function( PassFlightChanged value)?  flightChanged,}){
final _that = this;
switch (_that) {
case PassActive() when active != null:
return active(_that);case PassExpired() when expired != null:
return expired(_that);case PassRevoked() when revoked != null:
return revoked(_that);case PassBoarded() when boarded != null:
return boarded(_that);case PassFlightChanged() when flightChanged != null:
return flightChanged(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( Pass pass)?  active,TResult Function()?  expired,TResult Function()?  revoked,TResult Function()?  boarded,TResult Function( bool cancelled)?  flightChanged,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PassActive() when active != null:
return active(_that.pass);case PassExpired() when expired != null:
return expired();case PassRevoked() when revoked != null:
return revoked();case PassBoarded() when boarded != null:
return boarded();case PassFlightChanged() when flightChanged != null:
return flightChanged(_that.cancelled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( Pass pass)  active,required TResult Function()  expired,required TResult Function()  revoked,required TResult Function()  boarded,required TResult Function( bool cancelled)  flightChanged,}) {final _that = this;
switch (_that) {
case PassActive():
return active(_that.pass);case PassExpired():
return expired();case PassRevoked():
return revoked();case PassBoarded():
return boarded();case PassFlightChanged():
return flightChanged(_that.cancelled);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( Pass pass)?  active,TResult? Function()?  expired,TResult? Function()?  revoked,TResult? Function()?  boarded,TResult? Function( bool cancelled)?  flightChanged,}) {final _that = this;
switch (_that) {
case PassActive() when active != null:
return active(_that.pass);case PassExpired() when expired != null:
return expired();case PassRevoked() when revoked != null:
return revoked();case PassBoarded() when boarded != null:
return boarded();case PassFlightChanged() when flightChanged != null:
return flightChanged(_that.cancelled);case _:
  return null;

}
}

}

/// @nodoc


class PassActive implements PassState {
  const PassActive(this.pass);
  

 final  Pass pass;

/// Create a copy of PassState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PassActiveCopyWith<PassActive> get copyWith => _$PassActiveCopyWithImpl<PassActive>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PassActive&&(identical(other.pass, pass) || other.pass == pass));
}


@override
int get hashCode {
    return Object.hash(runtimeType,pass);
}

@override
String toString() {
    return 'PassState.active(pass: $pass)';
}


}

/// @nodoc
abstract mixin class $PassActiveCopyWith<$Res> implements $PassStateCopyWith<$Res> {
  factory $PassActiveCopyWith(PassActive value, $Res Function(PassActive) _then) = _$PassActiveCopyWithImpl;
@useResult
$Res call({
 Pass pass
});


$PassCopyWith<$Res> get pass;

}
/// @nodoc
class _$PassActiveCopyWithImpl<$Res>
    implements $PassActiveCopyWith<$Res> {
  _$PassActiveCopyWithImpl(this._self, this._then);

  final PassActive _self;
  final $Res Function(PassActive) _then;

/// Create a copy of PassState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? pass = null,}) {
  return _then(PassActive(
null == pass ? _self.pass : pass // ignore: cast_nullable_to_non_nullable
as Pass,
  ));
}

/// Create a copy of PassState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PassCopyWith<$Res> get pass {
  
  return $PassCopyWith<$Res>(_self.pass, (value) {
    return _then(_self.copyWith(pass: value));
  });
}
}

/// @nodoc


class PassExpired implements PassState {
  const PassExpired();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PassExpired);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'PassState.expired()';
}


}




/// @nodoc


class PassRevoked implements PassState {
  const PassRevoked();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PassRevoked);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'PassState.revoked()';
}


}




/// @nodoc


class PassBoarded implements PassState {
  const PassBoarded();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PassBoarded);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'PassState.boarded()';
}


}




/// @nodoc


class PassFlightChanged implements PassState {
  const PassFlightChanged({required this.cancelled});
  

 final  bool cancelled;

/// Create a copy of PassState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PassFlightChangedCopyWith<PassFlightChanged> get copyWith => _$PassFlightChangedCopyWithImpl<PassFlightChanged>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PassFlightChanged&&(identical(other.cancelled, cancelled) || other.cancelled == cancelled));
}


@override
int get hashCode {
    return Object.hash(runtimeType,cancelled);
}

@override
String toString() {
    return 'PassState.flightChanged(cancelled: $cancelled)';
}


}

/// @nodoc
abstract mixin class $PassFlightChangedCopyWith<$Res> implements $PassStateCopyWith<$Res> {
  factory $PassFlightChangedCopyWith(PassFlightChanged value, $Res Function(PassFlightChanged) _then) = _$PassFlightChangedCopyWithImpl;
@useResult
$Res call({
 bool cancelled
});




}
/// @nodoc
class _$PassFlightChangedCopyWithImpl<$Res>
    implements $PassFlightChangedCopyWith<$Res> {
  _$PassFlightChangedCopyWithImpl(this._self, this._then);

  final PassFlightChanged _self;
  final $Res Function(PassFlightChanged) _then;

/// Create a copy of PassState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? cancelled = null,}) {
  return _then(PassFlightChanged(
cancelled: null == cancelled ? _self.cancelled : cancelled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$ClockTrust {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ClockTrust);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ClockTrust()';
}


}

/// @nodoc
class $ClockTrustCopyWith<$Res>  {
$ClockTrustCopyWith(ClockTrust _, $Res Function(ClockTrust) __);
}


/// Adds pattern-matching-related methods to [ClockTrust].
extension ClockTrustPatterns on ClockTrust {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ClockTrusted value)?  trusted,TResult Function( ClockUntrusted value)?  untrusted,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ClockTrusted() when trusted != null:
return trusted(_that);case ClockUntrusted() when untrusted != null:
return untrusted(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ClockTrusted value)  trusted,required TResult Function( ClockUntrusted value)  untrusted,}){
final _that = this;
switch (_that) {
case ClockTrusted():
return trusted(_that);case ClockUntrusted():
return untrusted(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ClockTrusted value)?  trusted,TResult? Function( ClockUntrusted value)?  untrusted,}){
final _that = this;
switch (_that) {
case ClockTrusted() when trusted != null:
return trusted(_that);case ClockUntrusted() when untrusted != null:
return untrusted(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( Duration offset)?  trusted,TResult Function( ClockDistrustReason reason)?  untrusted,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ClockTrusted() when trusted != null:
return trusted(_that.offset);case ClockUntrusted() when untrusted != null:
return untrusted(_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( Duration offset)  trusted,required TResult Function( ClockDistrustReason reason)  untrusted,}) {final _that = this;
switch (_that) {
case ClockTrusted():
return trusted(_that.offset);case ClockUntrusted():
return untrusted(_that.reason);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( Duration offset)?  trusted,TResult? Function( ClockDistrustReason reason)?  untrusted,}) {final _that = this;
switch (_that) {
case ClockTrusted() when trusted != null:
return trusted(_that.offset);case ClockUntrusted() when untrusted != null:
return untrusted(_that.reason);case _:
  return null;

}
}

}

/// @nodoc


class ClockTrusted implements ClockTrust {
  const ClockTrusted({required this.offset});
  

 final  Duration offset;

/// Create a copy of ClockTrust
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClockTrustedCopyWith<ClockTrusted> get copyWith => _$ClockTrustedCopyWithImpl<ClockTrusted>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ClockTrusted&&(identical(other.offset, offset) || other.offset == offset));
}


@override
int get hashCode {
    return Object.hash(runtimeType,offset);
}

@override
String toString() {
    return 'ClockTrust.trusted(offset: $offset)';
}


}

/// @nodoc
abstract mixin class $ClockTrustedCopyWith<$Res> implements $ClockTrustCopyWith<$Res> {
  factory $ClockTrustedCopyWith(ClockTrusted value, $Res Function(ClockTrusted) _then) = _$ClockTrustedCopyWithImpl;
@useResult
$Res call({
 Duration offset
});




}
/// @nodoc
class _$ClockTrustedCopyWithImpl<$Res>
    implements $ClockTrustedCopyWith<$Res> {
  _$ClockTrustedCopyWithImpl(this._self, this._then);

  final ClockTrusted _self;
  final $Res Function(ClockTrusted) _then;

/// Create a copy of ClockTrust
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? offset = null,}) {
  return _then(ClockTrusted(
offset: null == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}


}

/// @nodoc


class ClockUntrusted implements ClockTrust {
  const ClockUntrusted(this.reason);
  

 final  ClockDistrustReason reason;

/// Create a copy of ClockTrust
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClockUntrustedCopyWith<ClockUntrusted> get copyWith => _$ClockUntrustedCopyWithImpl<ClockUntrusted>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ClockUntrusted&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode {
    return Object.hash(runtimeType,reason);
}

@override
String toString() {
    return 'ClockTrust.untrusted(reason: $reason)';
}


}

/// @nodoc
abstract mixin class $ClockUntrustedCopyWith<$Res> implements $ClockTrustCopyWith<$Res> {
  factory $ClockUntrustedCopyWith(ClockUntrusted value, $Res Function(ClockUntrusted) _then) = _$ClockUntrustedCopyWithImpl;
@useResult
$Res call({
 ClockDistrustReason reason
});




}
/// @nodoc
class _$ClockUntrustedCopyWithImpl<$Res>
    implements $ClockUntrustedCopyWith<$Res> {
  _$ClockUntrustedCopyWithImpl(this._self, this._then);

  final ClockUntrusted _self;
  final $Res Function(ClockUntrusted) _then;

/// Create a copy of ClockTrust
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reason = null,}) {
  return _then(ClockUntrusted(
null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as ClockDistrustReason,
  ));
}


}

/// @nodoc
mixin _$DevicePosture {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DevicePosture);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'DevicePosture()';
}


}

/// @nodoc
class $DevicePostureCopyWith<$Res>  {
$DevicePostureCopyWith(DevicePosture _, $Res Function(DevicePosture) __);
}


/// Adds pattern-matching-related methods to [DevicePosture].
extension DevicePosturePatterns on DevicePosture {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DeviceTrusted value)?  trusted,TResult Function( DeviceCompromised value)?  compromised,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DeviceTrusted() when trusted != null:
return trusted(_that);case DeviceCompromised() when compromised != null:
return compromised(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DeviceTrusted value)  trusted,required TResult Function( DeviceCompromised value)  compromised,}){
final _that = this;
switch (_that) {
case DeviceTrusted():
return trusted(_that);case DeviceCompromised():
return compromised(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DeviceTrusted value)?  trusted,TResult? Function( DeviceCompromised value)?  compromised,}){
final _that = this;
switch (_that) {
case DeviceTrusted() when trusted != null:
return trusted(_that);case DeviceCompromised() when compromised != null:
return compromised(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  trusted,TResult Function( List<String> signals)?  compromised,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DeviceTrusted() when trusted != null:
return trusted();case DeviceCompromised() when compromised != null:
return compromised(_that.signals);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  trusted,required TResult Function( List<String> signals)  compromised,}) {final _that = this;
switch (_that) {
case DeviceTrusted():
return trusted();case DeviceCompromised():
return compromised(_that.signals);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  trusted,TResult? Function( List<String> signals)?  compromised,}) {final _that = this;
switch (_that) {
case DeviceTrusted() when trusted != null:
return trusted();case DeviceCompromised() when compromised != null:
return compromised(_that.signals);case _:
  return null;

}
}

}

/// @nodoc


class DeviceTrusted implements DevicePosture {
  const DeviceTrusted();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DeviceTrusted);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'DevicePosture.trusted()';
}


}




/// @nodoc


class DeviceCompromised implements DevicePosture {
  const DeviceCompromised( List<String> signals): _signals = signals;
  

 final  List<String> _signals;
 List<String> get signals {
  if (_signals is EqualUnmodifiableListView) return _signals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_signals);
}


/// Create a copy of DevicePosture
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeviceCompromisedCopyWith<DeviceCompromised> get copyWith => _$DeviceCompromisedCopyWithImpl<DeviceCompromised>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DeviceCompromised&&const DeepCollectionEquality().equals(other.signals, _signals));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_signals));
}

@override
String toString() {
    return 'DevicePosture.compromised(signals: $signals)';
}


}

/// @nodoc
abstract mixin class $DeviceCompromisedCopyWith<$Res> implements $DevicePostureCopyWith<$Res> {
  factory $DeviceCompromisedCopyWith(DeviceCompromised value, $Res Function(DeviceCompromised) _then) = _$DeviceCompromisedCopyWithImpl;
@useResult
$Res call({
 List<String> signals
});




}
/// @nodoc
class _$DeviceCompromisedCopyWithImpl<$Res>
    implements $DeviceCompromisedCopyWith<$Res> {
  _$DeviceCompromisedCopyWithImpl(this._self, this._then);

  final DeviceCompromised _self;
  final $Res Function(DeviceCompromised) _then;

/// Create a copy of DevicePosture
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? signals = null,}) {
  return _then(DeviceCompromised(
null == signals ? _self._signals : signals // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
