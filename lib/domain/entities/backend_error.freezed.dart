// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'backend_error.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BackendError {

 BackendErrorCode get code; int get status;/// From the `Retry-After` header, on 429 and 503.
 Duration? get retryAfter;/// From `detalles.campos` on a 422: the offending field names.
 List<String> get fields;
/// Create a copy of BackendError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BackendErrorCopyWith<BackendError> get copyWith => _$BackendErrorCopyWithImpl<BackendError>(this as BackendError, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BackendError;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BackendError&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.retryAfter, _this.retryAfter) || other.retryAfter == _this.retryAfter)&&const DeepCollectionEquality().equals(other.fields, _this.fields));
}


@override
int get hashCode {
  final _this = this as BackendError;
  return Object.hash(runtimeType,_this.code,_this.status,_this.retryAfter,const DeepCollectionEquality().hash(_this.fields));
}

@override
String toString() {
  final _this = this as BackendError;
  return 'BackendError(code: ${_this.code}, status: ${_this.status}, retryAfter: ${_this.retryAfter}, fields: ${_this.fields})';
}


}

/// @nodoc
abstract mixin class $BackendErrorCopyWith<$Res>  {
  factory $BackendErrorCopyWith(BackendError value, $Res Function(BackendError) _then) = _$BackendErrorCopyWithImpl;
@useResult
$Res call({
 BackendErrorCode code, int status, Duration? retryAfter, List<String> fields
});




}
/// @nodoc
class _$BackendErrorCopyWithImpl<$Res>
    implements $BackendErrorCopyWith<$Res> {
  _$BackendErrorCopyWithImpl(this._self, this._then);

  final BackendError _self;
  final $Res Function(BackendError) _then;

/// Create a copy of BackendError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? status = null,Object? retryAfter = freezed,Object? fields = null,}) {
  return _then(BackendError(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as BackendErrorCode,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,retryAfter: freezed == retryAfter ? _self.retryAfter : retryAfter // ignore: cast_nullable_to_non_nullable
as Duration?,fields: null == fields ? _self.fields : fields // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [BackendError].
extension BackendErrorPatterns on BackendError {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BackendError value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BackendError() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BackendError value)  $default,){
final _that = this;
switch (_that) {
case _BackendError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BackendError value)?  $default,){
final _that = this;
switch (_that) {
case _BackendError() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( BackendErrorCode code,  int status,  Duration? retryAfter,  List<String> fields)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BackendError() when $default != null:
return $default(_that.code,_that.status,_that.retryAfter,_that.fields);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( BackendErrorCode code,  int status,  Duration? retryAfter,  List<String> fields)  $default,) {final _that = this;
switch (_that) {
case _BackendError():
return $default(_that.code,_that.status,_that.retryAfter,_that.fields);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( BackendErrorCode code,  int status,  Duration? retryAfter,  List<String> fields)?  $default,) {final _that = this;
switch (_that) {
case _BackendError() when $default != null:
return $default(_that.code,_that.status,_that.retryAfter,_that.fields);case _:
  return null;

}
}

}

/// @nodoc


class _BackendError implements BackendError {
  const _BackendError({required this.code, required this.status, this.retryAfter,  List<String> fields = const <String>[]}): _fields = fields;
  

@override final  BackendErrorCode code;
@override final  int status;
/// From the `Retry-After` header, on 429 and 503.
@override final  Duration? retryAfter;
/// From `detalles.campos` on a 422: the offending field names.
 final  List<String> _fields;
/// From `detalles.campos` on a 422: the offending field names.
@override@JsonKey() List<String> get fields {
  if (_fields is EqualUnmodifiableListView) return _fields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fields);
}


/// Create a copy of BackendError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BackendErrorCopyWith<_BackendError> get copyWith => __$BackendErrorCopyWithImpl<_BackendError>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BackendError&&(identical(other.code, code) || other.code == code)&&(identical(other.status, status) || other.status == status)&&(identical(other.retryAfter, retryAfter) || other.retryAfter == retryAfter)&&const DeepCollectionEquality().equals(other.fields, _fields));
}


@override
int get hashCode {
    return Object.hash(runtimeType,code,status,retryAfter,const DeepCollectionEquality().hash(_fields));
}

@override
String toString() {
    return 'BackendError(code: $code, status: $status, retryAfter: $retryAfter, fields: $fields)';
}


}

/// @nodoc
abstract mixin class _$BackendErrorCopyWith<$Res> implements $BackendErrorCopyWith<$Res> {
  factory _$BackendErrorCopyWith(_BackendError value, $Res Function(_BackendError) _then) = __$BackendErrorCopyWithImpl;
@override @useResult
$Res call({
 BackendErrorCode code, int status, Duration? retryAfter, List<String> fields
});




}
/// @nodoc
class __$BackendErrorCopyWithImpl<$Res>
    implements _$BackendErrorCopyWith<$Res> {
  __$BackendErrorCopyWithImpl(this._self, this._then);

  final _BackendError _self;
  final $Res Function(_BackendError) _then;

/// Create a copy of BackendError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? status = null,Object? retryAfter = freezed,Object? fields = null,}) {
  return _then(_BackendError(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as BackendErrorCode,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,retryAfter: freezed == retryAfter ? _self.retryAfter : retryAfter // ignore: cast_nullable_to_non_nullable
as Duration?,fields: null == fields ? _self._fields : fields // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
