// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credential_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CredentialSummary {

 String? get holderName;/// Exactly four digits, or null. The full number is never held (FR-002).
 String? get documentLast4; CredentialDisplayState get state; bool get confirmed;
/// Create a copy of CredentialSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CredentialSummaryCopyWith<CredentialSummary> get copyWith => _$CredentialSummaryCopyWithImpl<CredentialSummary>(this as CredentialSummary, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CredentialSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CredentialSummary&&(identical(other.holderName, _this.holderName) || other.holderName == _this.holderName)&&(identical(other.documentLast4, _this.documentLast4) || other.documentLast4 == _this.documentLast4)&&(identical(other.state, _this.state) || other.state == _this.state)&&(identical(other.confirmed, _this.confirmed) || other.confirmed == _this.confirmed));
}


@override
int get hashCode {
  final _this = this as CredentialSummary;
  return Object.hash(runtimeType,_this.holderName,_this.documentLast4,_this.state,_this.confirmed);
}

@override
String toString() {
  final _this = this as CredentialSummary;
  return 'CredentialSummary(holderName: ${_this.holderName}, documentLast4: ${_this.documentLast4}, state: ${_this.state}, confirmed: ${_this.confirmed})';
}


}

/// @nodoc
abstract mixin class $CredentialSummaryCopyWith<$Res>  {
  factory $CredentialSummaryCopyWith(CredentialSummary value, $Res Function(CredentialSummary) _then) = _$CredentialSummaryCopyWithImpl;
@useResult
$Res call({
 String? holderName, String? documentLast4, CredentialDisplayState state, bool confirmed
});




}
/// @nodoc
class _$CredentialSummaryCopyWithImpl<$Res>
    implements $CredentialSummaryCopyWith<$Res> {
  _$CredentialSummaryCopyWithImpl(this._self, this._then);

  final CredentialSummary _self;
  final $Res Function(CredentialSummary) _then;

/// Create a copy of CredentialSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? holderName = freezed,Object? documentLast4 = freezed,Object? state = null,Object? confirmed = null,}) {
  return _then(CredentialSummary(
holderName: freezed == holderName ? _self.holderName : holderName // ignore: cast_nullable_to_non_nullable
as String?,documentLast4: freezed == documentLast4 ? _self.documentLast4 : documentLast4 // ignore: cast_nullable_to_non_nullable
as String?,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as CredentialDisplayState,confirmed: null == confirmed ? _self.confirmed : confirmed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CredentialSummary].
extension CredentialSummaryPatterns on CredentialSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CredentialSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CredentialSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CredentialSummary value)  $default,){
final _that = this;
switch (_that) {
case _CredentialSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CredentialSummary value)?  $default,){
final _that = this;
switch (_that) {
case _CredentialSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? holderName,  String? documentLast4,  CredentialDisplayState state,  bool confirmed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CredentialSummary() when $default != null:
return $default(_that.holderName,_that.documentLast4,_that.state,_that.confirmed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? holderName,  String? documentLast4,  CredentialDisplayState state,  bool confirmed)  $default,) {final _that = this;
switch (_that) {
case _CredentialSummary():
return $default(_that.holderName,_that.documentLast4,_that.state,_that.confirmed);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? holderName,  String? documentLast4,  CredentialDisplayState state,  bool confirmed)?  $default,) {final _that = this;
switch (_that) {
case _CredentialSummary() when $default != null:
return $default(_that.holderName,_that.documentLast4,_that.state,_that.confirmed);case _:
  return null;

}
}

}

/// @nodoc


class _CredentialSummary extends CredentialSummary {
  const _CredentialSummary({this.holderName, this.documentLast4, required this.state, required this.confirmed}): super._();
  

@override final  String? holderName;
/// Exactly four digits, or null. The full number is never held (FR-002).
@override final  String? documentLast4;
@override final  CredentialDisplayState state;
@override final  bool confirmed;

/// Create a copy of CredentialSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CredentialSummaryCopyWith<_CredentialSummary> get copyWith => __$CredentialSummaryCopyWithImpl<_CredentialSummary>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CredentialSummary&&(identical(other.holderName, holderName) || other.holderName == holderName)&&(identical(other.documentLast4, documentLast4) || other.documentLast4 == documentLast4)&&(identical(other.state, state) || other.state == state)&&(identical(other.confirmed, confirmed) || other.confirmed == confirmed));
}


@override
int get hashCode {
    return Object.hash(runtimeType,holderName,documentLast4,state,confirmed);
}

@override
String toString() {
    return 'CredentialSummary(holderName: $holderName, documentLast4: $documentLast4, state: $state, confirmed: $confirmed)';
}


}

/// @nodoc
abstract mixin class _$CredentialSummaryCopyWith<$Res> implements $CredentialSummaryCopyWith<$Res> {
  factory _$CredentialSummaryCopyWith(_CredentialSummary value, $Res Function(_CredentialSummary) _then) = __$CredentialSummaryCopyWithImpl;
@override @useResult
$Res call({
 String? holderName, String? documentLast4, CredentialDisplayState state, bool confirmed
});




}
/// @nodoc
class __$CredentialSummaryCopyWithImpl<$Res>
    implements _$CredentialSummaryCopyWith<$Res> {
  __$CredentialSummaryCopyWithImpl(this._self, this._then);

  final _CredentialSummary _self;
  final $Res Function(_CredentialSummary) _then;

/// Create a copy of CredentialSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? holderName = freezed,Object? documentLast4 = freezed,Object? state = null,Object? confirmed = null,}) {
  return _then(_CredentialSummary(
holderName: freezed == holderName ? _self.holderName : holderName // ignore: cast_nullable_to_non_nullable
as String?,documentLast4: freezed == documentLast4 ? _self.documentLast4 : documentLast4 // ignore: cast_nullable_to_non_nullable
as String?,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as CredentialDisplayState,confirmed: null == confirmed ? _self.confirmed : confirmed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
