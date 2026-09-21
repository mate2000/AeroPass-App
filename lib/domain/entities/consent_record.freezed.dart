// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'consent_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ConsentRecord {

/// References the `ConsentTextVersion.id` shown at confirmation time.
 String get textVersionId;/// Durable anonymous identifier, generated at confirmation
/// (research.md §3).
 EnrollmentAttemptId get enrollmentAttemptId;/// FR-005: never bundles another purpose.
 ProcessingScope get scope; DateTime get confirmedAt; ConsentRecordStatus get status;/// Set when `status` becomes `withdrawalPending`; null while `active`.
 DateTime? get withdrawalRequestedAt;
/// Create a copy of ConsentRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConsentRecordCopyWith<ConsentRecord> get copyWith => _$ConsentRecordCopyWithImpl<ConsentRecord>(this as ConsentRecord, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ConsentRecord;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConsentRecord&&(identical(other.textVersionId, _this.textVersionId) || other.textVersionId == _this.textVersionId)&&(identical(other.enrollmentAttemptId, _this.enrollmentAttemptId) || other.enrollmentAttemptId == _this.enrollmentAttemptId)&&(identical(other.scope, _this.scope) || other.scope == _this.scope)&&(identical(other.confirmedAt, _this.confirmedAt) || other.confirmedAt == _this.confirmedAt)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.withdrawalRequestedAt, _this.withdrawalRequestedAt) || other.withdrawalRequestedAt == _this.withdrawalRequestedAt));
}


@override
int get hashCode {
  final _this = this as ConsentRecord;
  return Object.hash(runtimeType,_this.textVersionId,_this.enrollmentAttemptId,_this.scope,_this.confirmedAt,_this.status,_this.withdrawalRequestedAt);
}

@override
String toString() {
  final _this = this as ConsentRecord;
  return 'ConsentRecord(textVersionId: ${_this.textVersionId}, enrollmentAttemptId: ${_this.enrollmentAttemptId}, scope: ${_this.scope}, confirmedAt: ${_this.confirmedAt}, status: ${_this.status}, withdrawalRequestedAt: ${_this.withdrawalRequestedAt})';
}


}

/// @nodoc
abstract mixin class $ConsentRecordCopyWith<$Res>  {
  factory $ConsentRecordCopyWith(ConsentRecord value, $Res Function(ConsentRecord) _then) = _$ConsentRecordCopyWithImpl;
@useResult
$Res call({
 String textVersionId, EnrollmentAttemptId enrollmentAttemptId, ProcessingScope scope, DateTime confirmedAt, ConsentRecordStatus status, DateTime? withdrawalRequestedAt
});


$EnrollmentAttemptIdCopyWith<$Res> get enrollmentAttemptId;

}
/// @nodoc
class _$ConsentRecordCopyWithImpl<$Res>
    implements $ConsentRecordCopyWith<$Res> {
  _$ConsentRecordCopyWithImpl(this._self, this._then);

  final ConsentRecord _self;
  final $Res Function(ConsentRecord) _then;

/// Create a copy of ConsentRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? textVersionId = null,Object? enrollmentAttemptId = null,Object? scope = null,Object? confirmedAt = null,Object? status = null,Object? withdrawalRequestedAt = freezed,}) {
  return _then(ConsentRecord(
textVersionId: null == textVersionId ? _self.textVersionId : textVersionId // ignore: cast_nullable_to_non_nullable
as String,enrollmentAttemptId: null == enrollmentAttemptId ? _self.enrollmentAttemptId : enrollmentAttemptId // ignore: cast_nullable_to_non_nullable
as EnrollmentAttemptId,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as ProcessingScope,confirmedAt: null == confirmedAt ? _self.confirmedAt : confirmedAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConsentRecordStatus,withdrawalRequestedAt: freezed == withdrawalRequestedAt ? _self.withdrawalRequestedAt : withdrawalRequestedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of ConsentRecord
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EnrollmentAttemptIdCopyWith<$Res> get enrollmentAttemptId {
  
  return $EnrollmentAttemptIdCopyWith<$Res>(_self.enrollmentAttemptId, (value) {
    return _then(_self.copyWith(enrollmentAttemptId: value));
  });
}
}


/// Adds pattern-matching-related methods to [ConsentRecord].
extension ConsentRecordPatterns on ConsentRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConsentRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConsentRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConsentRecord value)  $default,){
final _that = this;
switch (_that) {
case _ConsentRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConsentRecord value)?  $default,){
final _that = this;
switch (_that) {
case _ConsentRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String textVersionId,  EnrollmentAttemptId enrollmentAttemptId,  ProcessingScope scope,  DateTime confirmedAt,  ConsentRecordStatus status,  DateTime? withdrawalRequestedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConsentRecord() when $default != null:
return $default(_that.textVersionId,_that.enrollmentAttemptId,_that.scope,_that.confirmedAt,_that.status,_that.withdrawalRequestedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String textVersionId,  EnrollmentAttemptId enrollmentAttemptId,  ProcessingScope scope,  DateTime confirmedAt,  ConsentRecordStatus status,  DateTime? withdrawalRequestedAt)  $default,) {final _that = this;
switch (_that) {
case _ConsentRecord():
return $default(_that.textVersionId,_that.enrollmentAttemptId,_that.scope,_that.confirmedAt,_that.status,_that.withdrawalRequestedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String textVersionId,  EnrollmentAttemptId enrollmentAttemptId,  ProcessingScope scope,  DateTime confirmedAt,  ConsentRecordStatus status,  DateTime? withdrawalRequestedAt)?  $default,) {final _that = this;
switch (_that) {
case _ConsentRecord() when $default != null:
return $default(_that.textVersionId,_that.enrollmentAttemptId,_that.scope,_that.confirmedAt,_that.status,_that.withdrawalRequestedAt);case _:
  return null;

}
}

}

/// @nodoc


class _ConsentRecord implements ConsentRecord {
  const _ConsentRecord({required this.textVersionId, required this.enrollmentAttemptId, required this.scope, required this.confirmedAt, required this.status, this.withdrawalRequestedAt});
  

/// References the `ConsentTextVersion.id` shown at confirmation time.
@override final  String textVersionId;
/// Durable anonymous identifier, generated at confirmation
/// (research.md §3).
@override final  EnrollmentAttemptId enrollmentAttemptId;
/// FR-005: never bundles another purpose.
@override final  ProcessingScope scope;
@override final  DateTime confirmedAt;
@override final  ConsentRecordStatus status;
/// Set when `status` becomes `withdrawalPending`; null while `active`.
@override final  DateTime? withdrawalRequestedAt;

/// Create a copy of ConsentRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConsentRecordCopyWith<_ConsentRecord> get copyWith => __$ConsentRecordCopyWithImpl<_ConsentRecord>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConsentRecord&&(identical(other.textVersionId, textVersionId) || other.textVersionId == textVersionId)&&(identical(other.enrollmentAttemptId, enrollmentAttemptId) || other.enrollmentAttemptId == enrollmentAttemptId)&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.confirmedAt, confirmedAt) || other.confirmedAt == confirmedAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.withdrawalRequestedAt, withdrawalRequestedAt) || other.withdrawalRequestedAt == withdrawalRequestedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,textVersionId,enrollmentAttemptId,scope,confirmedAt,status,withdrawalRequestedAt);
}

@override
String toString() {
    return 'ConsentRecord(textVersionId: $textVersionId, enrollmentAttemptId: $enrollmentAttemptId, scope: $scope, confirmedAt: $confirmedAt, status: $status, withdrawalRequestedAt: $withdrawalRequestedAt)';
}


}

/// @nodoc
abstract mixin class _$ConsentRecordCopyWith<$Res> implements $ConsentRecordCopyWith<$Res> {
  factory _$ConsentRecordCopyWith(_ConsentRecord value, $Res Function(_ConsentRecord) _then) = __$ConsentRecordCopyWithImpl;
@override @useResult
$Res call({
 String textVersionId, EnrollmentAttemptId enrollmentAttemptId, ProcessingScope scope, DateTime confirmedAt, ConsentRecordStatus status, DateTime? withdrawalRequestedAt
});


@override $EnrollmentAttemptIdCopyWith<$Res> get enrollmentAttemptId;

}
/// @nodoc
class __$ConsentRecordCopyWithImpl<$Res>
    implements _$ConsentRecordCopyWith<$Res> {
  __$ConsentRecordCopyWithImpl(this._self, this._then);

  final _ConsentRecord _self;
  final $Res Function(_ConsentRecord) _then;

/// Create a copy of ConsentRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? textVersionId = null,Object? enrollmentAttemptId = null,Object? scope = null,Object? confirmedAt = null,Object? status = null,Object? withdrawalRequestedAt = freezed,}) {
  return _then(_ConsentRecord(
textVersionId: null == textVersionId ? _self.textVersionId : textVersionId // ignore: cast_nullable_to_non_nullable
as String,enrollmentAttemptId: null == enrollmentAttemptId ? _self.enrollmentAttemptId : enrollmentAttemptId // ignore: cast_nullable_to_non_nullable
as EnrollmentAttemptId,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as ProcessingScope,confirmedAt: null == confirmedAt ? _self.confirmedAt : confirmedAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConsentRecordStatus,withdrawalRequestedAt: freezed == withdrawalRequestedAt ? _self.withdrawalRequestedAt : withdrawalRequestedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of ConsentRecord
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EnrollmentAttemptIdCopyWith<$Res> get enrollmentAttemptId {
  
  return $EnrollmentAttemptIdCopyWith<$Res>(_self.enrollmentAttemptId, (value) {
    return _then(_self.copyWith(enrollmentAttemptId: value));
  });
}
}

// dart format on
