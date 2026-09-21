// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credential_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CredentialStatus {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CredentialStatus);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'CredentialStatus()';
}


}

/// @nodoc
class $CredentialStatusCopyWith<$Res>  {
$CredentialStatusCopyWith(CredentialStatus _, $Res Function(CredentialStatus) __);
}


/// Adds pattern-matching-related methods to [CredentialStatus].
extension CredentialStatusPatterns on CredentialStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( NoCredential value)?  noCredential,TResult Function( Valid value)?  valid,TResult Function( ExpiredOrRevoked value)?  expiredOrRevoked,TResult Function( Unreachable value)?  unreachable,required TResult orElse(),}){
final _that = this;
switch (_that) {
case NoCredential() when noCredential != null:
return noCredential(_that);case Valid() when valid != null:
return valid(_that);case ExpiredOrRevoked() when expiredOrRevoked != null:
return expiredOrRevoked(_that);case Unreachable() when unreachable != null:
return unreachable(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( NoCredential value)  noCredential,required TResult Function( Valid value)  valid,required TResult Function( ExpiredOrRevoked value)  expiredOrRevoked,required TResult Function( Unreachable value)  unreachable,}){
final _that = this;
switch (_that) {
case NoCredential():
return noCredential(_that);case Valid():
return valid(_that);case ExpiredOrRevoked():
return expiredOrRevoked(_that);case Unreachable():
return unreachable(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( NoCredential value)?  noCredential,TResult? Function( Valid value)?  valid,TResult? Function( ExpiredOrRevoked value)?  expiredOrRevoked,TResult? Function( Unreachable value)?  unreachable,}){
final _that = this;
switch (_that) {
case NoCredential() when noCredential != null:
return noCredential(_that);case Valid() when valid != null:
return valid(_that);case ExpiredOrRevoked() when expiredOrRevoked != null:
return expiredOrRevoked(_that);case Unreachable() when unreachable != null:
return unreachable(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  noCredential,TResult Function( DateTime validUntil)?  valid,TResult Function( ExpiryReason reason)?  expiredOrRevoked,TResult Function( CredentialStatus? lastKnownStatus)?  unreachable,required TResult orElse(),}) {final _that = this;
switch (_that) {
case NoCredential() when noCredential != null:
return noCredential();case Valid() when valid != null:
return valid(_that.validUntil);case ExpiredOrRevoked() when expiredOrRevoked != null:
return expiredOrRevoked(_that.reason);case Unreachable() when unreachable != null:
return unreachable(_that.lastKnownStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  noCredential,required TResult Function( DateTime validUntil)  valid,required TResult Function( ExpiryReason reason)  expiredOrRevoked,required TResult Function( CredentialStatus? lastKnownStatus)  unreachable,}) {final _that = this;
switch (_that) {
case NoCredential():
return noCredential();case Valid():
return valid(_that.validUntil);case ExpiredOrRevoked():
return expiredOrRevoked(_that.reason);case Unreachable():
return unreachable(_that.lastKnownStatus);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  noCredential,TResult? Function( DateTime validUntil)?  valid,TResult? Function( ExpiryReason reason)?  expiredOrRevoked,TResult? Function( CredentialStatus? lastKnownStatus)?  unreachable,}) {final _that = this;
switch (_that) {
case NoCredential() when noCredential != null:
return noCredential();case Valid() when valid != null:
return valid(_that.validUntil);case ExpiredOrRevoked() when expiredOrRevoked != null:
return expiredOrRevoked(_that.reason);case Unreachable() when unreachable != null:
return unreachable(_that.lastKnownStatus);case _:
  return null;

}
}

}

/// @nodoc


class NoCredential implements CredentialStatus {
  const NoCredential();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is NoCredential);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'CredentialStatus.noCredential()';
}


}




/// @nodoc


class Valid implements CredentialStatus {
  const Valid({required this.validUntil});
  

 final  DateTime validUntil;

/// Create a copy of CredentialStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ValidCopyWith<Valid> get copyWith => _$ValidCopyWithImpl<Valid>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Valid&&(identical(other.validUntil, validUntil) || other.validUntil == validUntil));
}


@override
int get hashCode {
    return Object.hash(runtimeType,validUntil);
}

@override
String toString() {
    return 'CredentialStatus.valid(validUntil: $validUntil)';
}


}

/// @nodoc
abstract mixin class $ValidCopyWith<$Res> implements $CredentialStatusCopyWith<$Res> {
  factory $ValidCopyWith(Valid value, $Res Function(Valid) _then) = _$ValidCopyWithImpl;
@useResult
$Res call({
 DateTime validUntil
});




}
/// @nodoc
class _$ValidCopyWithImpl<$Res>
    implements $ValidCopyWith<$Res> {
  _$ValidCopyWithImpl(this._self, this._then);

  final Valid _self;
  final $Res Function(Valid) _then;

/// Create a copy of CredentialStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? validUntil = null,}) {
  return _then(Valid(
validUntil: null == validUntil ? _self.validUntil : validUntil // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc


class ExpiredOrRevoked implements CredentialStatus {
  const ExpiredOrRevoked({required this.reason});
  

 final  ExpiryReason reason;

/// Create a copy of CredentialStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpiredOrRevokedCopyWith<ExpiredOrRevoked> get copyWith => _$ExpiredOrRevokedCopyWithImpl<ExpiredOrRevoked>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpiredOrRevoked&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode {
    return Object.hash(runtimeType,reason);
}

@override
String toString() {
    return 'CredentialStatus.expiredOrRevoked(reason: $reason)';
}


}

/// @nodoc
abstract mixin class $ExpiredOrRevokedCopyWith<$Res> implements $CredentialStatusCopyWith<$Res> {
  factory $ExpiredOrRevokedCopyWith(ExpiredOrRevoked value, $Res Function(ExpiredOrRevoked) _then) = _$ExpiredOrRevokedCopyWithImpl;
@useResult
$Res call({
 ExpiryReason reason
});




}
/// @nodoc
class _$ExpiredOrRevokedCopyWithImpl<$Res>
    implements $ExpiredOrRevokedCopyWith<$Res> {
  _$ExpiredOrRevokedCopyWithImpl(this._self, this._then);

  final ExpiredOrRevoked _self;
  final $Res Function(ExpiredOrRevoked) _then;

/// Create a copy of CredentialStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reason = null,}) {
  return _then(ExpiredOrRevoked(
reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as ExpiryReason,
  ));
}


}

/// @nodoc


class Unreachable implements CredentialStatus {
  const Unreachable({this.lastKnownStatus});
  

 final  CredentialStatus? lastKnownStatus;

/// Create a copy of CredentialStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnreachableCopyWith<Unreachable> get copyWith => _$UnreachableCopyWithImpl<Unreachable>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Unreachable&&(identical(other.lastKnownStatus, lastKnownStatus) || other.lastKnownStatus == lastKnownStatus));
}


@override
int get hashCode {
    return Object.hash(runtimeType,lastKnownStatus);
}

@override
String toString() {
    return 'CredentialStatus.unreachable(lastKnownStatus: $lastKnownStatus)';
}


}

/// @nodoc
abstract mixin class $UnreachableCopyWith<$Res> implements $CredentialStatusCopyWith<$Res> {
  factory $UnreachableCopyWith(Unreachable value, $Res Function(Unreachable) _then) = _$UnreachableCopyWithImpl;
@useResult
$Res call({
 CredentialStatus? lastKnownStatus
});


$CredentialStatusCopyWith<$Res>? get lastKnownStatus;

}
/// @nodoc
class _$UnreachableCopyWithImpl<$Res>
    implements $UnreachableCopyWith<$Res> {
  _$UnreachableCopyWithImpl(this._self, this._then);

  final Unreachable _self;
  final $Res Function(Unreachable) _then;

/// Create a copy of CredentialStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? lastKnownStatus = freezed,}) {
  return _then(Unreachable(
lastKnownStatus: freezed == lastKnownStatus ? _self.lastKnownStatus : lastKnownStatus // ignore: cast_nullable_to_non_nullable
as CredentialStatus?,
  ));
}

/// Create a copy of CredentialStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CredentialStatusCopyWith<$Res>? get lastKnownStatus {
    if (_self.lastKnownStatus == null) {
    return null;
  }

  return $CredentialStatusCopyWith<$Res>(_self.lastKnownStatus!, (value) {
    return _then(_self.copyWith(lastKnownStatus: value));
  });
}
}

// dart format on
