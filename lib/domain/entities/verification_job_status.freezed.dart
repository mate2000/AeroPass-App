// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verification_job_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VerificationJobStatus {

 StageStatus get documentCheck; StageStatus get faceComparison;/// 011-error-tecnico: until when a cold launch resumes this job
/// (backend-owned, 24 h after a failure). Null means not resumable.
 DateTime? get resumableUntil;
/// Create a copy of VerificationJobStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerificationJobStatusCopyWith<VerificationJobStatus> get copyWith => _$VerificationJobStatusCopyWithImpl<VerificationJobStatus>(this as VerificationJobStatus, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as VerificationJobStatus;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerificationJobStatus&&(identical(other.documentCheck, _this.documentCheck) || other.documentCheck == _this.documentCheck)&&(identical(other.faceComparison, _this.faceComparison) || other.faceComparison == _this.faceComparison)&&(identical(other.resumableUntil, _this.resumableUntil) || other.resumableUntil == _this.resumableUntil));
}


@override
int get hashCode {
  final _this = this as VerificationJobStatus;
  return Object.hash(runtimeType,_this.documentCheck,_this.faceComparison,_this.resumableUntil);
}

@override
String toString() {
  final _this = this as VerificationJobStatus;
  return 'VerificationJobStatus(documentCheck: ${_this.documentCheck}, faceComparison: ${_this.faceComparison}, resumableUntil: ${_this.resumableUntil})';
}


}

/// @nodoc
abstract mixin class $VerificationJobStatusCopyWith<$Res>  {
  factory $VerificationJobStatusCopyWith(VerificationJobStatus value, $Res Function(VerificationJobStatus) _then) = _$VerificationJobStatusCopyWithImpl;
@useResult
$Res call({
 StageStatus documentCheck, StageStatus faceComparison, DateTime? resumableUntil
});




}
/// @nodoc
class _$VerificationJobStatusCopyWithImpl<$Res>
    implements $VerificationJobStatusCopyWith<$Res> {
  _$VerificationJobStatusCopyWithImpl(this._self, this._then);

  final VerificationJobStatus _self;
  final $Res Function(VerificationJobStatus) _then;

/// Create a copy of VerificationJobStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? documentCheck = null,Object? faceComparison = null,Object? resumableUntil = freezed,}) {
  return _then(_self.copyWith(
documentCheck: null == documentCheck ? _self.documentCheck : documentCheck // ignore: cast_nullable_to_non_nullable
as StageStatus,faceComparison: null == faceComparison ? _self.faceComparison : faceComparison // ignore: cast_nullable_to_non_nullable
as StageStatus,resumableUntil: freezed == resumableUntil ? _self.resumableUntil : resumableUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [VerificationJobStatus].
extension VerificationJobStatusPatterns on VerificationJobStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( VerificationJobInProgress value)?  inProgress,TResult Function( VerificationJobCompleted value)?  completed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case VerificationJobInProgress() when inProgress != null:
return inProgress(_that);case VerificationJobCompleted() when completed != null:
return completed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( VerificationJobInProgress value)  inProgress,required TResult Function( VerificationJobCompleted value)  completed,}){
final _that = this;
switch (_that) {
case VerificationJobInProgress():
return inProgress(_that);case VerificationJobCompleted():
return completed(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( VerificationJobInProgress value)?  inProgress,TResult? Function( VerificationJobCompleted value)?  completed,}){
final _that = this;
switch (_that) {
case VerificationJobInProgress() when inProgress != null:
return inProgress(_that);case VerificationJobCompleted() when completed != null:
return completed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( StageStatus documentCheck,  StageStatus faceComparison,  DateTime? resumableUntil)?  inProgress,TResult Function( VerificationOutcome outcome,  StageStatus documentCheck,  StageStatus faceComparison,  DateTime? resumableUntil)?  completed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case VerificationJobInProgress() when inProgress != null:
return inProgress(_that.documentCheck,_that.faceComparison,_that.resumableUntil);case VerificationJobCompleted() when completed != null:
return completed(_that.outcome,_that.documentCheck,_that.faceComparison,_that.resumableUntil);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( StageStatus documentCheck,  StageStatus faceComparison,  DateTime? resumableUntil)  inProgress,required TResult Function( VerificationOutcome outcome,  StageStatus documentCheck,  StageStatus faceComparison,  DateTime? resumableUntil)  completed,}) {final _that = this;
switch (_that) {
case VerificationJobInProgress():
return inProgress(_that.documentCheck,_that.faceComparison,_that.resumableUntil);case VerificationJobCompleted():
return completed(_that.outcome,_that.documentCheck,_that.faceComparison,_that.resumableUntil);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( StageStatus documentCheck,  StageStatus faceComparison,  DateTime? resumableUntil)?  inProgress,TResult? Function( VerificationOutcome outcome,  StageStatus documentCheck,  StageStatus faceComparison,  DateTime? resumableUntil)?  completed,}) {final _that = this;
switch (_that) {
case VerificationJobInProgress() when inProgress != null:
return inProgress(_that.documentCheck,_that.faceComparison,_that.resumableUntil);case VerificationJobCompleted() when completed != null:
return completed(_that.outcome,_that.documentCheck,_that.faceComparison,_that.resumableUntil);case _:
  return null;

}
}

}

/// @nodoc


class VerificationJobInProgress implements VerificationJobStatus {
  const VerificationJobInProgress({required this.documentCheck, required this.faceComparison, this.resumableUntil});
  

@override final  StageStatus documentCheck;
@override final  StageStatus faceComparison;
/// 011-error-tecnico: until when a cold launch resumes this job
/// (backend-owned, 24 h after a failure). Null means not resumable.
@override final  DateTime? resumableUntil;

/// Create a copy of VerificationJobStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerificationJobInProgressCopyWith<VerificationJobInProgress> get copyWith => _$VerificationJobInProgressCopyWithImpl<VerificationJobInProgress>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is VerificationJobInProgress&&(identical(other.documentCheck, documentCheck) || other.documentCheck == documentCheck)&&(identical(other.faceComparison, faceComparison) || other.faceComparison == faceComparison)&&(identical(other.resumableUntil, resumableUntil) || other.resumableUntil == resumableUntil));
}


@override
int get hashCode {
    return Object.hash(runtimeType,documentCheck,faceComparison,resumableUntil);
}

@override
String toString() {
    return 'VerificationJobStatus.inProgress(documentCheck: $documentCheck, faceComparison: $faceComparison, resumableUntil: $resumableUntil)';
}


}

/// @nodoc
abstract mixin class $VerificationJobInProgressCopyWith<$Res> implements $VerificationJobStatusCopyWith<$Res> {
  factory $VerificationJobInProgressCopyWith(VerificationJobInProgress value, $Res Function(VerificationJobInProgress) _then) = _$VerificationJobInProgressCopyWithImpl;
@override @useResult
$Res call({
 StageStatus documentCheck, StageStatus faceComparison, DateTime? resumableUntil
});




}
/// @nodoc
class _$VerificationJobInProgressCopyWithImpl<$Res>
    implements $VerificationJobInProgressCopyWith<$Res> {
  _$VerificationJobInProgressCopyWithImpl(this._self, this._then);

  final VerificationJobInProgress _self;
  final $Res Function(VerificationJobInProgress) _then;

/// Create a copy of VerificationJobStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? documentCheck = null,Object? faceComparison = null,Object? resumableUntil = freezed,}) {
  return _then(VerificationJobInProgress(
documentCheck: null == documentCheck ? _self.documentCheck : documentCheck // ignore: cast_nullable_to_non_nullable
as StageStatus,faceComparison: null == faceComparison ? _self.faceComparison : faceComparison // ignore: cast_nullable_to_non_nullable
as StageStatus,resumableUntil: freezed == resumableUntil ? _self.resumableUntil : resumableUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc


class VerificationJobCompleted implements VerificationJobStatus {
  const VerificationJobCompleted({required this.outcome, required this.documentCheck, required this.faceComparison, this.resumableUntil});
  

 final  VerificationOutcome outcome;
@override final  StageStatus documentCheck;
@override final  StageStatus faceComparison;
@override final  DateTime? resumableUntil;

/// Create a copy of VerificationJobStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerificationJobCompletedCopyWith<VerificationJobCompleted> get copyWith => _$VerificationJobCompletedCopyWithImpl<VerificationJobCompleted>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is VerificationJobCompleted&&(identical(other.outcome, outcome) || other.outcome == outcome)&&(identical(other.documentCheck, documentCheck) || other.documentCheck == documentCheck)&&(identical(other.faceComparison, faceComparison) || other.faceComparison == faceComparison)&&(identical(other.resumableUntil, resumableUntil) || other.resumableUntil == resumableUntil));
}


@override
int get hashCode {
    return Object.hash(runtimeType,outcome,documentCheck,faceComparison,resumableUntil);
}

@override
String toString() {
    return 'VerificationJobStatus.completed(outcome: $outcome, documentCheck: $documentCheck, faceComparison: $faceComparison, resumableUntil: $resumableUntil)';
}


}

/// @nodoc
abstract mixin class $VerificationJobCompletedCopyWith<$Res> implements $VerificationJobStatusCopyWith<$Res> {
  factory $VerificationJobCompletedCopyWith(VerificationJobCompleted value, $Res Function(VerificationJobCompleted) _then) = _$VerificationJobCompletedCopyWithImpl;
@override @useResult
$Res call({
 VerificationOutcome outcome, StageStatus documentCheck, StageStatus faceComparison, DateTime? resumableUntil
});


$VerificationOutcomeCopyWith<$Res> get outcome;

}
/// @nodoc
class _$VerificationJobCompletedCopyWithImpl<$Res>
    implements $VerificationJobCompletedCopyWith<$Res> {
  _$VerificationJobCompletedCopyWithImpl(this._self, this._then);

  final VerificationJobCompleted _self;
  final $Res Function(VerificationJobCompleted) _then;

/// Create a copy of VerificationJobStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? outcome = null,Object? documentCheck = null,Object? faceComparison = null,Object? resumableUntil = freezed,}) {
  return _then(VerificationJobCompleted(
outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as VerificationOutcome,documentCheck: null == documentCheck ? _self.documentCheck : documentCheck // ignore: cast_nullable_to_non_nullable
as StageStatus,faceComparison: null == faceComparison ? _self.faceComparison : faceComparison // ignore: cast_nullable_to_non_nullable
as StageStatus,resumableUntil: freezed == resumableUntil ? _self.resumableUntil : resumableUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of VerificationJobStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VerificationOutcomeCopyWith<$Res> get outcome {
  
  return $VerificationOutcomeCopyWith<$Res>(_self.outcome, (value) {
    return _then(_self.copyWith(outcome: value));
  });
}
}

// dart format on
