// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'passenger_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PassengerRecord {

 String get passengerId; DocumentType get documentType; String get holderName; String get maskedNumber; DateTime get documentExpiry; PassengerState get state; int get failedAttempts; String? get identityId;
/// Create a copy of PassengerRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PassengerRecordCopyWith<PassengerRecord> get copyWith => _$PassengerRecordCopyWithImpl<PassengerRecord>(this as PassengerRecord, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PassengerRecord;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PassengerRecord&&(identical(other.passengerId, _this.passengerId) || other.passengerId == _this.passengerId)&&(identical(other.documentType, _this.documentType) || other.documentType == _this.documentType)&&(identical(other.holderName, _this.holderName) || other.holderName == _this.holderName)&&(identical(other.maskedNumber, _this.maskedNumber) || other.maskedNumber == _this.maskedNumber)&&(identical(other.documentExpiry, _this.documentExpiry) || other.documentExpiry == _this.documentExpiry)&&(identical(other.state, _this.state) || other.state == _this.state)&&(identical(other.failedAttempts, _this.failedAttempts) || other.failedAttempts == _this.failedAttempts)&&(identical(other.identityId, _this.identityId) || other.identityId == _this.identityId));
}


@override
int get hashCode {
  final _this = this as PassengerRecord;
  return Object.hash(runtimeType,_this.passengerId,_this.documentType,_this.holderName,_this.maskedNumber,_this.documentExpiry,_this.state,_this.failedAttempts,_this.identityId);
}

@override
String toString() {
  final _this = this as PassengerRecord;
  return 'PassengerRecord(passengerId: ${_this.passengerId}, documentType: ${_this.documentType}, holderName: ${_this.holderName}, maskedNumber: ${_this.maskedNumber}, documentExpiry: ${_this.documentExpiry}, state: ${_this.state}, failedAttempts: ${_this.failedAttempts}, identityId: ${_this.identityId})';
}


}

/// @nodoc
abstract mixin class $PassengerRecordCopyWith<$Res>  {
  factory $PassengerRecordCopyWith(PassengerRecord value, $Res Function(PassengerRecord) _then) = _$PassengerRecordCopyWithImpl;
@useResult
$Res call({
 String passengerId, DocumentType documentType, String holderName, String maskedNumber, DateTime documentExpiry, PassengerState state, int failedAttempts, String? identityId
});




}
/// @nodoc
class _$PassengerRecordCopyWithImpl<$Res>
    implements $PassengerRecordCopyWith<$Res> {
  _$PassengerRecordCopyWithImpl(this._self, this._then);

  final PassengerRecord _self;
  final $Res Function(PassengerRecord) _then;

/// Create a copy of PassengerRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? passengerId = null,Object? documentType = null,Object? holderName = null,Object? maskedNumber = null,Object? documentExpiry = null,Object? state = null,Object? failedAttempts = null,Object? identityId = freezed,}) {
  return _then(PassengerRecord(
passengerId: null == passengerId ? _self.passengerId : passengerId // ignore: cast_nullable_to_non_nullable
as String,documentType: null == documentType ? _self.documentType : documentType // ignore: cast_nullable_to_non_nullable
as DocumentType,holderName: null == holderName ? _self.holderName : holderName // ignore: cast_nullable_to_non_nullable
as String,maskedNumber: null == maskedNumber ? _self.maskedNumber : maskedNumber // ignore: cast_nullable_to_non_nullable
as String,documentExpiry: null == documentExpiry ? _self.documentExpiry : documentExpiry // ignore: cast_nullable_to_non_nullable
as DateTime,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as PassengerState,failedAttempts: null == failedAttempts ? _self.failedAttempts : failedAttempts // ignore: cast_nullable_to_non_nullable
as int,identityId: freezed == identityId ? _self.identityId : identityId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PassengerRecord].
extension PassengerRecordPatterns on PassengerRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PassengerRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PassengerRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PassengerRecord value)  $default,){
final _that = this;
switch (_that) {
case _PassengerRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PassengerRecord value)?  $default,){
final _that = this;
switch (_that) {
case _PassengerRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String passengerId,  DocumentType documentType,  String holderName,  String maskedNumber,  DateTime documentExpiry,  PassengerState state,  int failedAttempts,  String? identityId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PassengerRecord() when $default != null:
return $default(_that.passengerId,_that.documentType,_that.holderName,_that.maskedNumber,_that.documentExpiry,_that.state,_that.failedAttempts,_that.identityId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String passengerId,  DocumentType documentType,  String holderName,  String maskedNumber,  DateTime documentExpiry,  PassengerState state,  int failedAttempts,  String? identityId)  $default,) {final _that = this;
switch (_that) {
case _PassengerRecord():
return $default(_that.passengerId,_that.documentType,_that.holderName,_that.maskedNumber,_that.documentExpiry,_that.state,_that.failedAttempts,_that.identityId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String passengerId,  DocumentType documentType,  String holderName,  String maskedNumber,  DateTime documentExpiry,  PassengerState state,  int failedAttempts,  String? identityId)?  $default,) {final _that = this;
switch (_that) {
case _PassengerRecord() when $default != null:
return $default(_that.passengerId,_that.documentType,_that.holderName,_that.maskedNumber,_that.documentExpiry,_that.state,_that.failedAttempts,_that.identityId);case _:
  return null;

}
}

}

/// @nodoc


class _PassengerRecord implements PassengerRecord {
  const _PassengerRecord({required this.passengerId, required this.documentType, required this.holderName, required this.maskedNumber, required this.documentExpiry, required this.state, required this.failedAttempts, this.identityId});
  

@override final  String passengerId;
@override final  DocumentType documentType;
@override final  String holderName;
@override final  String maskedNumber;
@override final  DateTime documentExpiry;
@override final  PassengerState state;
@override final  int failedAttempts;
@override final  String? identityId;

/// Create a copy of PassengerRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PassengerRecordCopyWith<_PassengerRecord> get copyWith => __$PassengerRecordCopyWithImpl<_PassengerRecord>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PassengerRecord&&(identical(other.passengerId, passengerId) || other.passengerId == passengerId)&&(identical(other.documentType, documentType) || other.documentType == documentType)&&(identical(other.holderName, holderName) || other.holderName == holderName)&&(identical(other.maskedNumber, maskedNumber) || other.maskedNumber == maskedNumber)&&(identical(other.documentExpiry, documentExpiry) || other.documentExpiry == documentExpiry)&&(identical(other.state, state) || other.state == state)&&(identical(other.failedAttempts, failedAttempts) || other.failedAttempts == failedAttempts)&&(identical(other.identityId, identityId) || other.identityId == identityId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,passengerId,documentType,holderName,maskedNumber,documentExpiry,state,failedAttempts,identityId);
}

@override
String toString() {
    return 'PassengerRecord(passengerId: $passengerId, documentType: $documentType, holderName: $holderName, maskedNumber: $maskedNumber, documentExpiry: $documentExpiry, state: $state, failedAttempts: $failedAttempts, identityId: $identityId)';
}


}

/// @nodoc
abstract mixin class _$PassengerRecordCopyWith<$Res> implements $PassengerRecordCopyWith<$Res> {
  factory _$PassengerRecordCopyWith(_PassengerRecord value, $Res Function(_PassengerRecord) _then) = __$PassengerRecordCopyWithImpl;
@override @useResult
$Res call({
 String passengerId, DocumentType documentType, String holderName, String maskedNumber, DateTime documentExpiry, PassengerState state, int failedAttempts, String? identityId
});




}
/// @nodoc
class __$PassengerRecordCopyWithImpl<$Res>
    implements _$PassengerRecordCopyWith<$Res> {
  __$PassengerRecordCopyWithImpl(this._self, this._then);

  final _PassengerRecord _self;
  final $Res Function(_PassengerRecord) _then;

/// Create a copy of PassengerRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? passengerId = null,Object? documentType = null,Object? holderName = null,Object? maskedNumber = null,Object? documentExpiry = null,Object? state = null,Object? failedAttempts = null,Object? identityId = freezed,}) {
  return _then(_PassengerRecord(
passengerId: null == passengerId ? _self.passengerId : passengerId // ignore: cast_nullable_to_non_nullable
as String,documentType: null == documentType ? _self.documentType : documentType // ignore: cast_nullable_to_non_nullable
as DocumentType,holderName: null == holderName ? _self.holderName : holderName // ignore: cast_nullable_to_non_nullable
as String,maskedNumber: null == maskedNumber ? _self.maskedNumber : maskedNumber // ignore: cast_nullable_to_non_nullable
as String,documentExpiry: null == documentExpiry ? _self.documentExpiry : documentExpiry // ignore: cast_nullable_to_non_nullable
as DateTime,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as PassengerState,failedAttempts: null == failedAttempts ? _self.failedAttempts : failedAttempts // ignore: cast_nullable_to_non_nullable
as int,identityId: freezed == identityId ? _self.identityId : identityId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
