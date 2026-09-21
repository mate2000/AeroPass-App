// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'enrollment_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EnrollmentStep {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EnrollmentStep);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'EnrollmentStep()';
}


}

/// @nodoc
class $EnrollmentStepCopyWith<$Res>  {
$EnrollmentStepCopyWith(EnrollmentStep _, $Res Function(EnrollmentStep) __);
}


/// Adds pattern-matching-related methods to [EnrollmentStep].
extension EnrollmentStepPatterns on EnrollmentStep {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ConsentStep value)?  consent,TResult Function( DocumentCaptureStep value)?  documentCapture,TResult Function( SelfieCaptureStep value)?  selfieCapture,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ConsentStep() when consent != null:
return consent(_that);case DocumentCaptureStep() when documentCapture != null:
return documentCapture(_that);case SelfieCaptureStep() when selfieCapture != null:
return selfieCapture(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ConsentStep value)  consent,required TResult Function( DocumentCaptureStep value)  documentCapture,required TResult Function( SelfieCaptureStep value)  selfieCapture,}){
final _that = this;
switch (_that) {
case ConsentStep():
return consent(_that);case DocumentCaptureStep():
return documentCapture(_that);case SelfieCaptureStep():
return selfieCapture(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ConsentStep value)?  consent,TResult? Function( DocumentCaptureStep value)?  documentCapture,TResult? Function( SelfieCaptureStep value)?  selfieCapture,}){
final _that = this;
switch (_that) {
case ConsentStep() when consent != null:
return consent(_that);case DocumentCaptureStep() when documentCapture != null:
return documentCapture(_that);case SelfieCaptureStep() when selfieCapture != null:
return selfieCapture(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  consent,TResult Function()?  documentCapture,TResult Function()?  selfieCapture,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ConsentStep() when consent != null:
return consent();case DocumentCaptureStep() when documentCapture != null:
return documentCapture();case SelfieCaptureStep() when selfieCapture != null:
return selfieCapture();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  consent,required TResult Function()  documentCapture,required TResult Function()  selfieCapture,}) {final _that = this;
switch (_that) {
case ConsentStep():
return consent();case DocumentCaptureStep():
return documentCapture();case SelfieCaptureStep():
return selfieCapture();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  consent,TResult? Function()?  documentCapture,TResult? Function()?  selfieCapture,}) {final _that = this;
switch (_that) {
case ConsentStep() when consent != null:
return consent();case DocumentCaptureStep() when documentCapture != null:
return documentCapture();case SelfieCaptureStep() when selfieCapture != null:
return selfieCapture();case _:
  return null;

}
}

}

/// @nodoc


class ConsentStep implements EnrollmentStep {
  const ConsentStep();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ConsentStep);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'EnrollmentStep.consent()';
}


}




/// @nodoc


class DocumentCaptureStep implements EnrollmentStep {
  const DocumentCaptureStep();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentCaptureStep);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'EnrollmentStep.documentCapture()';
}


}




/// @nodoc


class SelfieCaptureStep implements EnrollmentStep {
  const SelfieCaptureStep();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SelfieCaptureStep);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'EnrollmentStep.selfieCapture()';
}


}




/// @nodoc
mixin _$EnrollmentSession {

/// Exists only to guarantee FR-004's "exactly one session" invariant
/// under repeated/concurrent activation of the primary action; never
/// sent to the backend or analytics as a stable identifier.
 String get id; EnrollmentStep get stepReached;/// In-memory only; used solely to decide UI copy ("continue where you
/// left off"), not a resumability deadline.
 DateTime get startedAt;
/// Create a copy of EnrollmentSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EnrollmentSessionCopyWith<EnrollmentSession> get copyWith => _$EnrollmentSessionCopyWithImpl<EnrollmentSession>(this as EnrollmentSession, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as EnrollmentSession;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EnrollmentSession&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.stepReached, _this.stepReached) || other.stepReached == _this.stepReached)&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt));
}


@override
int get hashCode {
  final _this = this as EnrollmentSession;
  return Object.hash(runtimeType,_this.id,_this.stepReached,_this.startedAt);
}

@override
String toString() {
  final _this = this as EnrollmentSession;
  return 'EnrollmentSession(id: ${_this.id}, stepReached: ${_this.stepReached}, startedAt: ${_this.startedAt})';
}


}

/// @nodoc
abstract mixin class $EnrollmentSessionCopyWith<$Res>  {
  factory $EnrollmentSessionCopyWith(EnrollmentSession value, $Res Function(EnrollmentSession) _then) = _$EnrollmentSessionCopyWithImpl;
@useResult
$Res call({
 String id, EnrollmentStep stepReached, DateTime startedAt
});


$EnrollmentStepCopyWith<$Res> get stepReached;

}
/// @nodoc
class _$EnrollmentSessionCopyWithImpl<$Res>
    implements $EnrollmentSessionCopyWith<$Res> {
  _$EnrollmentSessionCopyWithImpl(this._self, this._then);

  final EnrollmentSession _self;
  final $Res Function(EnrollmentSession) _then;

/// Create a copy of EnrollmentSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? stepReached = null,Object? startedAt = null,}) {
  return _then(EnrollmentSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,stepReached: null == stepReached ? _self.stepReached : stepReached // ignore: cast_nullable_to_non_nullable
as EnrollmentStep,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of EnrollmentSession
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EnrollmentStepCopyWith<$Res> get stepReached {
  
  return $EnrollmentStepCopyWith<$Res>(_self.stepReached, (value) {
    return _then(_self.copyWith(stepReached: value));
  });
}
}


/// Adds pattern-matching-related methods to [EnrollmentSession].
extension EnrollmentSessionPatterns on EnrollmentSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EnrollmentSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EnrollmentSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EnrollmentSession value)  $default,){
final _that = this;
switch (_that) {
case _EnrollmentSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EnrollmentSession value)?  $default,){
final _that = this;
switch (_that) {
case _EnrollmentSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  EnrollmentStep stepReached,  DateTime startedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EnrollmentSession() when $default != null:
return $default(_that.id,_that.stepReached,_that.startedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  EnrollmentStep stepReached,  DateTime startedAt)  $default,) {final _that = this;
switch (_that) {
case _EnrollmentSession():
return $default(_that.id,_that.stepReached,_that.startedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  EnrollmentStep stepReached,  DateTime startedAt)?  $default,) {final _that = this;
switch (_that) {
case _EnrollmentSession() when $default != null:
return $default(_that.id,_that.stepReached,_that.startedAt);case _:
  return null;

}
}

}

/// @nodoc


class _EnrollmentSession implements EnrollmentSession {
  const _EnrollmentSession({required this.id, required this.stepReached, required this.startedAt});
  

/// Exists only to guarantee FR-004's "exactly one session" invariant
/// under repeated/concurrent activation of the primary action; never
/// sent to the backend or analytics as a stable identifier.
@override final  String id;
@override final  EnrollmentStep stepReached;
/// In-memory only; used solely to decide UI copy ("continue where you
/// left off"), not a resumability deadline.
@override final  DateTime startedAt;

/// Create a copy of EnrollmentSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EnrollmentSessionCopyWith<_EnrollmentSession> get copyWith => __$EnrollmentSessionCopyWithImpl<_EnrollmentSession>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EnrollmentSession&&(identical(other.id, id) || other.id == id)&&(identical(other.stepReached, stepReached) || other.stepReached == stepReached)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,stepReached,startedAt);
}

@override
String toString() {
    return 'EnrollmentSession(id: $id, stepReached: $stepReached, startedAt: $startedAt)';
}


}

/// @nodoc
abstract mixin class _$EnrollmentSessionCopyWith<$Res> implements $EnrollmentSessionCopyWith<$Res> {
  factory _$EnrollmentSessionCopyWith(_EnrollmentSession value, $Res Function(_EnrollmentSession) _then) = __$EnrollmentSessionCopyWithImpl;
@override @useResult
$Res call({
 String id, EnrollmentStep stepReached, DateTime startedAt
});


@override $EnrollmentStepCopyWith<$Res> get stepReached;

}
/// @nodoc
class __$EnrollmentSessionCopyWithImpl<$Res>
    implements _$EnrollmentSessionCopyWith<$Res> {
  __$EnrollmentSessionCopyWithImpl(this._self, this._then);

  final _EnrollmentSession _self;
  final $Res Function(_EnrollmentSession) _then;

/// Create a copy of EnrollmentSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? stepReached = null,Object? startedAt = null,}) {
  return _then(_EnrollmentSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,stepReached: null == stepReached ? _self.stepReached : stepReached // ignore: cast_nullable_to_non_nullable
as EnrollmentStep,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of EnrollmentSession
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EnrollmentStepCopyWith<$Res> get stepReached {
  
  return $EnrollmentStepCopyWith<$Res>(_self.stepReached, (value) {
    return _then(_self.copyWith(stepReached: value));
  });
}
}

// dart format on
