// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'issuance_outcome.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$IssuanceOutcome {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is IssuanceOutcome);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'IssuanceOutcome()';
}


}

/// @nodoc
class $IssuanceOutcomeCopyWith<$Res>  {
$IssuanceOutcomeCopyWith(IssuanceOutcome _, $Res Function(IssuanceOutcome) __);
}


/// Adds pattern-matching-related methods to [IssuanceOutcome].
extension IssuanceOutcomePatterns on IssuanceOutcome {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( IssuanceActivated value)?  activated,TResult Function( IssuanceNotActive value)?  notActive,TResult Function( IssuanceIncomplete value)?  incomplete,required TResult orElse(),}){
final _that = this;
switch (_that) {
case IssuanceActivated() when activated != null:
return activated(_that);case IssuanceNotActive() when notActive != null:
return notActive(_that);case IssuanceIncomplete() when incomplete != null:
return incomplete(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( IssuanceActivated value)  activated,required TResult Function( IssuanceNotActive value)  notActive,required TResult Function( IssuanceIncomplete value)  incomplete,}){
final _that = this;
switch (_that) {
case IssuanceActivated():
return activated(_that);case IssuanceNotActive():
return notActive(_that);case IssuanceIncomplete():
return incomplete(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( IssuanceActivated value)?  activated,TResult? Function( IssuanceNotActive value)?  notActive,TResult? Function( IssuanceIncomplete value)?  incomplete,}){
final _that = this;
switch (_that) {
case IssuanceActivated() when activated != null:
return activated(_that);case IssuanceNotActive() when notActive != null:
return notActive(_that);case IssuanceIncomplete() when incomplete != null:
return incomplete(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( ActivatedCredential credential)?  activated,TResult Function( CredentialLifecycleStatus status)?  notActive,TResult Function()?  incomplete,required TResult orElse(),}) {final _that = this;
switch (_that) {
case IssuanceActivated() when activated != null:
return activated(_that.credential);case IssuanceNotActive() when notActive != null:
return notActive(_that.status);case IssuanceIncomplete() when incomplete != null:
return incomplete();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( ActivatedCredential credential)  activated,required TResult Function( CredentialLifecycleStatus status)  notActive,required TResult Function()  incomplete,}) {final _that = this;
switch (_that) {
case IssuanceActivated():
return activated(_that.credential);case IssuanceNotActive():
return notActive(_that.status);case IssuanceIncomplete():
return incomplete();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( ActivatedCredential credential)?  activated,TResult? Function( CredentialLifecycleStatus status)?  notActive,TResult? Function()?  incomplete,}) {final _that = this;
switch (_that) {
case IssuanceActivated() when activated != null:
return activated(_that.credential);case IssuanceNotActive() when notActive != null:
return notActive(_that.status);case IssuanceIncomplete() when incomplete != null:
return incomplete();case _:
  return null;

}
}

}

/// @nodoc


class IssuanceActivated implements IssuanceOutcome {
  const IssuanceActivated({required this.credential});
  

 final  ActivatedCredential credential;

/// Create a copy of IssuanceOutcome
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IssuanceActivatedCopyWith<IssuanceActivated> get copyWith => _$IssuanceActivatedCopyWithImpl<IssuanceActivated>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is IssuanceActivated&&(identical(other.credential, credential) || other.credential == credential));
}


@override
int get hashCode {
    return Object.hash(runtimeType,credential);
}

@override
String toString() {
    return 'IssuanceOutcome.activated(credential: $credential)';
}


}

/// @nodoc
abstract mixin class $IssuanceActivatedCopyWith<$Res> implements $IssuanceOutcomeCopyWith<$Res> {
  factory $IssuanceActivatedCopyWith(IssuanceActivated value, $Res Function(IssuanceActivated) _then) = _$IssuanceActivatedCopyWithImpl;
@useResult
$Res call({
 ActivatedCredential credential
});


$ActivatedCredentialCopyWith<$Res> get credential;

}
/// @nodoc
class _$IssuanceActivatedCopyWithImpl<$Res>
    implements $IssuanceActivatedCopyWith<$Res> {
  _$IssuanceActivatedCopyWithImpl(this._self, this._then);

  final IssuanceActivated _self;
  final $Res Function(IssuanceActivated) _then;

/// Create a copy of IssuanceOutcome
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? credential = null,}) {
  return _then(IssuanceActivated(
credential: null == credential ? _self.credential : credential // ignore: cast_nullable_to_non_nullable
as ActivatedCredential,
  ));
}

/// Create a copy of IssuanceOutcome
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ActivatedCredentialCopyWith<$Res> get credential {
  
  return $ActivatedCredentialCopyWith<$Res>(_self.credential, (value) {
    return _then(_self.copyWith(credential: value));
  });
}
}

/// @nodoc


class IssuanceNotActive implements IssuanceOutcome {
  const IssuanceNotActive({required this.status});
  

 final  CredentialLifecycleStatus status;

/// Create a copy of IssuanceOutcome
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IssuanceNotActiveCopyWith<IssuanceNotActive> get copyWith => _$IssuanceNotActiveCopyWithImpl<IssuanceNotActive>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is IssuanceNotActive&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status);
}

@override
String toString() {
    return 'IssuanceOutcome.notActive(status: $status)';
}


}

/// @nodoc
abstract mixin class $IssuanceNotActiveCopyWith<$Res> implements $IssuanceOutcomeCopyWith<$Res> {
  factory $IssuanceNotActiveCopyWith(IssuanceNotActive value, $Res Function(IssuanceNotActive) _then) = _$IssuanceNotActiveCopyWithImpl;
@useResult
$Res call({
 CredentialLifecycleStatus status
});




}
/// @nodoc
class _$IssuanceNotActiveCopyWithImpl<$Res>
    implements $IssuanceNotActiveCopyWith<$Res> {
  _$IssuanceNotActiveCopyWithImpl(this._self, this._then);

  final IssuanceNotActive _self;
  final $Res Function(IssuanceNotActive) _then;

/// Create a copy of IssuanceOutcome
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? status = null,}) {
  return _then(IssuanceNotActive(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CredentialLifecycleStatus,
  ));
}


}

/// @nodoc


class IssuanceIncomplete implements IssuanceOutcome {
  const IssuanceIncomplete();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is IssuanceIncomplete);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'IssuanceOutcome.incomplete()';
}


}




// dart format on
