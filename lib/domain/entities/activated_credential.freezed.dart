// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activated_credential.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ActivatedCredential {

/// Non-empty. Announced in full to assistive technology (FR-014).
 String get holderName;/// Exactly four ASCII digits.
 String get documentLast4;/// ISO 3166-1 alpha-3, upper case (e.g. `COL`).
 String get issuingCountry;/// UTC. Displayed as "Creada el …".
 DateTime get issuedAt;/// UTC, strictly after [issuedAt]. Displayed as "Válida hasta …"
/// (FR-004) — never computed by the app.
 DateTime get validUntil;
/// Create a copy of ActivatedCredential
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActivatedCredentialCopyWith<ActivatedCredential> get copyWith => _$ActivatedCredentialCopyWithImpl<ActivatedCredential>(this as ActivatedCredential, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ActivatedCredential;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActivatedCredential&&(identical(other.holderName, _this.holderName) || other.holderName == _this.holderName)&&(identical(other.documentLast4, _this.documentLast4) || other.documentLast4 == _this.documentLast4)&&(identical(other.issuingCountry, _this.issuingCountry) || other.issuingCountry == _this.issuingCountry)&&(identical(other.issuedAt, _this.issuedAt) || other.issuedAt == _this.issuedAt)&&(identical(other.validUntil, _this.validUntil) || other.validUntil == _this.validUntil));
}


@override
int get hashCode {
  final _this = this as ActivatedCredential;
  return Object.hash(runtimeType,_this.holderName,_this.documentLast4,_this.issuingCountry,_this.issuedAt,_this.validUntil);
}

@override
String toString() {
  final _this = this as ActivatedCredential;
  return 'ActivatedCredential(holderName: ${_this.holderName}, documentLast4: ${_this.documentLast4}, issuingCountry: ${_this.issuingCountry}, issuedAt: ${_this.issuedAt}, validUntil: ${_this.validUntil})';
}


}

/// @nodoc
abstract mixin class $ActivatedCredentialCopyWith<$Res>  {
  factory $ActivatedCredentialCopyWith(ActivatedCredential value, $Res Function(ActivatedCredential) _then) = _$ActivatedCredentialCopyWithImpl;
@useResult
$Res call({
 String holderName, String documentLast4, String issuingCountry, DateTime issuedAt, DateTime validUntil
});




}
/// @nodoc
class _$ActivatedCredentialCopyWithImpl<$Res>
    implements $ActivatedCredentialCopyWith<$Res> {
  _$ActivatedCredentialCopyWithImpl(this._self, this._then);

  final ActivatedCredential _self;
  final $Res Function(ActivatedCredential) _then;

/// Create a copy of ActivatedCredential
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? holderName = null,Object? documentLast4 = null,Object? issuingCountry = null,Object? issuedAt = null,Object? validUntil = null,}) {
  return _then(ActivatedCredential(
holderName: null == holderName ? _self.holderName : holderName // ignore: cast_nullable_to_non_nullable
as String,documentLast4: null == documentLast4 ? _self.documentLast4 : documentLast4 // ignore: cast_nullable_to_non_nullable
as String,issuingCountry: null == issuingCountry ? _self.issuingCountry : issuingCountry // ignore: cast_nullable_to_non_nullable
as String,issuedAt: null == issuedAt ? _self.issuedAt : issuedAt // ignore: cast_nullable_to_non_nullable
as DateTime,validUntil: null == validUntil ? _self.validUntil : validUntil // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ActivatedCredential].
extension ActivatedCredentialPatterns on ActivatedCredential {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActivatedCredential value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActivatedCredential() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActivatedCredential value)  $default,){
final _that = this;
switch (_that) {
case _ActivatedCredential():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActivatedCredential value)?  $default,){
final _that = this;
switch (_that) {
case _ActivatedCredential() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String holderName,  String documentLast4,  String issuingCountry,  DateTime issuedAt,  DateTime validUntil)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActivatedCredential() when $default != null:
return $default(_that.holderName,_that.documentLast4,_that.issuingCountry,_that.issuedAt,_that.validUntil);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String holderName,  String documentLast4,  String issuingCountry,  DateTime issuedAt,  DateTime validUntil)  $default,) {final _that = this;
switch (_that) {
case _ActivatedCredential():
return $default(_that.holderName,_that.documentLast4,_that.issuingCountry,_that.issuedAt,_that.validUntil);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String holderName,  String documentLast4,  String issuingCountry,  DateTime issuedAt,  DateTime validUntil)?  $default,) {final _that = this;
switch (_that) {
case _ActivatedCredential() when $default != null:
return $default(_that.holderName,_that.documentLast4,_that.issuingCountry,_that.issuedAt,_that.validUntil);case _:
  return null;

}
}

}

/// @nodoc


class _ActivatedCredential implements ActivatedCredential {
  const _ActivatedCredential({required this.holderName, required this.documentLast4, required this.issuingCountry, required this.issuedAt, required this.validUntil});
  

/// Non-empty. Announced in full to assistive technology (FR-014).
@override final  String holderName;
/// Exactly four ASCII digits.
@override final  String documentLast4;
/// ISO 3166-1 alpha-3, upper case (e.g. `COL`).
@override final  String issuingCountry;
/// UTC. Displayed as "Creada el …".
@override final  DateTime issuedAt;
/// UTC, strictly after [issuedAt]. Displayed as "Válida hasta …"
/// (FR-004) — never computed by the app.
@override final  DateTime validUntil;

/// Create a copy of ActivatedCredential
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActivatedCredentialCopyWith<_ActivatedCredential> get copyWith => __$ActivatedCredentialCopyWithImpl<_ActivatedCredential>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivatedCredential&&(identical(other.holderName, holderName) || other.holderName == holderName)&&(identical(other.documentLast4, documentLast4) || other.documentLast4 == documentLast4)&&(identical(other.issuingCountry, issuingCountry) || other.issuingCountry == issuingCountry)&&(identical(other.issuedAt, issuedAt) || other.issuedAt == issuedAt)&&(identical(other.validUntil, validUntil) || other.validUntil == validUntil));
}


@override
int get hashCode {
    return Object.hash(runtimeType,holderName,documentLast4,issuingCountry,issuedAt,validUntil);
}

@override
String toString() {
    return 'ActivatedCredential(holderName: $holderName, documentLast4: $documentLast4, issuingCountry: $issuingCountry, issuedAt: $issuedAt, validUntil: $validUntil)';
}


}

/// @nodoc
abstract mixin class _$ActivatedCredentialCopyWith<$Res> implements $ActivatedCredentialCopyWith<$Res> {
  factory _$ActivatedCredentialCopyWith(_ActivatedCredential value, $Res Function(_ActivatedCredential) _then) = __$ActivatedCredentialCopyWithImpl;
@override @useResult
$Res call({
 String holderName, String documentLast4, String issuingCountry, DateTime issuedAt, DateTime validUntil
});




}
/// @nodoc
class __$ActivatedCredentialCopyWithImpl<$Res>
    implements _$ActivatedCredentialCopyWith<$Res> {
  __$ActivatedCredentialCopyWithImpl(this._self, this._then);

  final _ActivatedCredential _self;
  final $Res Function(_ActivatedCredential) _then;

/// Create a copy of ActivatedCredential
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? holderName = null,Object? documentLast4 = null,Object? issuingCountry = null,Object? issuedAt = null,Object? validUntil = null,}) {
  return _then(_ActivatedCredential(
holderName: null == holderName ? _self.holderName : holderName // ignore: cast_nullable_to_non_nullable
as String,documentLast4: null == documentLast4 ? _self.documentLast4 : documentLast4 // ignore: cast_nullable_to_non_nullable
as String,issuingCountry: null == issuingCountry ? _self.issuingCountry : issuingCountry // ignore: cast_nullable_to_non_nullable
as String,issuedAt: null == issuedAt ? _self.issuedAt : issuedAt // ignore: cast_nullable_to_non_nullable
as DateTime,validUntil: null == validUntil ? _self.validUntil : validUntil // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
