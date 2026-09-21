// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'capture_view_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CaptureViewState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CaptureViewState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'CaptureViewState()';
}


}

/// @nodoc
class $CaptureViewStateCopyWith<$Res>  {
$CaptureViewStateCopyWith(CaptureViewState _, $Res Function(CaptureViewState) __);
}


/// Adds pattern-matching-related methods to [CaptureViewState].
extension CaptureViewStatePatterns on CaptureViewState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CaptureViewChecking value)?  checking,TResult Function( CaptureViewPermissionDenied value)?  permissionDenied,TResult Function( CaptureViewReady value)?  ready,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CaptureViewChecking() when checking != null:
return checking(_that);case CaptureViewPermissionDenied() when permissionDenied != null:
return permissionDenied(_that);case CaptureViewReady() when ready != null:
return ready(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CaptureViewChecking value)  checking,required TResult Function( CaptureViewPermissionDenied value)  permissionDenied,required TResult Function( CaptureViewReady value)  ready,}){
final _that = this;
switch (_that) {
case CaptureViewChecking():
return checking(_that);case CaptureViewPermissionDenied():
return permissionDenied(_that);case CaptureViewReady():
return ready(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CaptureViewChecking value)?  checking,TResult? Function( CaptureViewPermissionDenied value)?  permissionDenied,TResult? Function( CaptureViewReady value)?  ready,}){
final _that = this;
switch (_that) {
case CaptureViewChecking() when checking != null:
return checking(_that);case CaptureViewPermissionDenied() when permissionDenied != null:
return permissionDenied(_that);case CaptureViewReady() when ready != null:
return ready(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  checking,TResult Function( bool permanent)?  permissionDenied,TResult Function( CaptureRejectionReason? lastRejectionReason,  bool offline)?  ready,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CaptureViewChecking() when checking != null:
return checking();case CaptureViewPermissionDenied() when permissionDenied != null:
return permissionDenied(_that.permanent);case CaptureViewReady() when ready != null:
return ready(_that.lastRejectionReason,_that.offline);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  checking,required TResult Function( bool permanent)  permissionDenied,required TResult Function( CaptureRejectionReason? lastRejectionReason,  bool offline)  ready,}) {final _that = this;
switch (_that) {
case CaptureViewChecking():
return checking();case CaptureViewPermissionDenied():
return permissionDenied(_that.permanent);case CaptureViewReady():
return ready(_that.lastRejectionReason,_that.offline);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  checking,TResult? Function( bool permanent)?  permissionDenied,TResult? Function( CaptureRejectionReason? lastRejectionReason,  bool offline)?  ready,}) {final _that = this;
switch (_that) {
case CaptureViewChecking() when checking != null:
return checking();case CaptureViewPermissionDenied() when permissionDenied != null:
return permissionDenied(_that.permanent);case CaptureViewReady() when ready != null:
return ready(_that.lastRejectionReason,_that.offline);case _:
  return null;

}
}

}

/// @nodoc


class CaptureViewChecking implements CaptureViewState {
  const CaptureViewChecking();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CaptureViewChecking);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'CaptureViewState.checking()';
}


}




/// @nodoc


class CaptureViewPermissionDenied implements CaptureViewState {
  const CaptureViewPermissionDenied({required this.permanent});
  

 final  bool permanent;

/// Create a copy of CaptureViewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CaptureViewPermissionDeniedCopyWith<CaptureViewPermissionDenied> get copyWith => _$CaptureViewPermissionDeniedCopyWithImpl<CaptureViewPermissionDenied>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CaptureViewPermissionDenied&&(identical(other.permanent, permanent) || other.permanent == permanent));
}


@override
int get hashCode {
    return Object.hash(runtimeType,permanent);
}

@override
String toString() {
    return 'CaptureViewState.permissionDenied(permanent: $permanent)';
}


}

/// @nodoc
abstract mixin class $CaptureViewPermissionDeniedCopyWith<$Res> implements $CaptureViewStateCopyWith<$Res> {
  factory $CaptureViewPermissionDeniedCopyWith(CaptureViewPermissionDenied value, $Res Function(CaptureViewPermissionDenied) _then) = _$CaptureViewPermissionDeniedCopyWithImpl;
@useResult
$Res call({
 bool permanent
});




}
/// @nodoc
class _$CaptureViewPermissionDeniedCopyWithImpl<$Res>
    implements $CaptureViewPermissionDeniedCopyWith<$Res> {
  _$CaptureViewPermissionDeniedCopyWithImpl(this._self, this._then);

  final CaptureViewPermissionDenied _self;
  final $Res Function(CaptureViewPermissionDenied) _then;

/// Create a copy of CaptureViewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? permanent = null,}) {
  return _then(CaptureViewPermissionDenied(
permanent: null == permanent ? _self.permanent : permanent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class CaptureViewReady implements CaptureViewState {
  const CaptureViewReady({this.lastRejectionReason, this.offline = false});
  

 final  CaptureRejectionReason? lastRejectionReason;
@JsonKey() final  bool offline;

/// Create a copy of CaptureViewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CaptureViewReadyCopyWith<CaptureViewReady> get copyWith => _$CaptureViewReadyCopyWithImpl<CaptureViewReady>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CaptureViewReady&&(identical(other.lastRejectionReason, lastRejectionReason) || other.lastRejectionReason == lastRejectionReason)&&(identical(other.offline, offline) || other.offline == offline));
}


@override
int get hashCode {
    return Object.hash(runtimeType,lastRejectionReason,offline);
}

@override
String toString() {
    return 'CaptureViewState.ready(lastRejectionReason: $lastRejectionReason, offline: $offline)';
}


}

/// @nodoc
abstract mixin class $CaptureViewReadyCopyWith<$Res> implements $CaptureViewStateCopyWith<$Res> {
  factory $CaptureViewReadyCopyWith(CaptureViewReady value, $Res Function(CaptureViewReady) _then) = _$CaptureViewReadyCopyWithImpl;
@useResult
$Res call({
 CaptureRejectionReason? lastRejectionReason, bool offline
});




}
/// @nodoc
class _$CaptureViewReadyCopyWithImpl<$Res>
    implements $CaptureViewReadyCopyWith<$Res> {
  _$CaptureViewReadyCopyWithImpl(this._self, this._then);

  final CaptureViewReady _self;
  final $Res Function(CaptureViewReady) _then;

/// Create a copy of CaptureViewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? lastRejectionReason = freezed,Object? offline = null,}) {
  return _then(CaptureViewReady(
lastRejectionReason: freezed == lastRejectionReason ? _self.lastRejectionReason : lastRejectionReason // ignore: cast_nullable_to_non_nullable
as CaptureRejectionReason?,offline: null == offline ? _self.offline : offline // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
