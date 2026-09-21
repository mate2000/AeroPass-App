// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device_capability.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DeviceCapability {

 bool get hasUsableCamera;/// Checked against the interim minimum-spec baseline (Android 8.0 /
/// iOS 15.0 — research.md §2), pending the product team's formal
/// value.
 bool get osVersionSupported;
/// Create a copy of DeviceCapability
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeviceCapabilityCopyWith<DeviceCapability> get copyWith => _$DeviceCapabilityCopyWithImpl<DeviceCapability>(this as DeviceCapability, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DeviceCapability;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeviceCapability&&(identical(other.hasUsableCamera, _this.hasUsableCamera) || other.hasUsableCamera == _this.hasUsableCamera)&&(identical(other.osVersionSupported, _this.osVersionSupported) || other.osVersionSupported == _this.osVersionSupported));
}


@override
int get hashCode {
  final _this = this as DeviceCapability;
  return Object.hash(runtimeType,_this.hasUsableCamera,_this.osVersionSupported);
}

@override
String toString() {
  final _this = this as DeviceCapability;
  return 'DeviceCapability(hasUsableCamera: ${_this.hasUsableCamera}, osVersionSupported: ${_this.osVersionSupported})';
}


}

/// @nodoc
abstract mixin class $DeviceCapabilityCopyWith<$Res>  {
  factory $DeviceCapabilityCopyWith(DeviceCapability value, $Res Function(DeviceCapability) _then) = _$DeviceCapabilityCopyWithImpl;
@useResult
$Res call({
 bool hasUsableCamera, bool osVersionSupported
});




}
/// @nodoc
class _$DeviceCapabilityCopyWithImpl<$Res>
    implements $DeviceCapabilityCopyWith<$Res> {
  _$DeviceCapabilityCopyWithImpl(this._self, this._then);

  final DeviceCapability _self;
  final $Res Function(DeviceCapability) _then;

/// Create a copy of DeviceCapability
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hasUsableCamera = null,Object? osVersionSupported = null,}) {
  return _then(DeviceCapability(
hasUsableCamera: null == hasUsableCamera ? _self.hasUsableCamera : hasUsableCamera // ignore: cast_nullable_to_non_nullable
as bool,osVersionSupported: null == osVersionSupported ? _self.osVersionSupported : osVersionSupported // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DeviceCapability].
extension DeviceCapabilityPatterns on DeviceCapability {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeviceCapability value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeviceCapability() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeviceCapability value)  $default,){
final _that = this;
switch (_that) {
case _DeviceCapability():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeviceCapability value)?  $default,){
final _that = this;
switch (_that) {
case _DeviceCapability() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool hasUsableCamera,  bool osVersionSupported)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeviceCapability() when $default != null:
return $default(_that.hasUsableCamera,_that.osVersionSupported);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool hasUsableCamera,  bool osVersionSupported)  $default,) {final _that = this;
switch (_that) {
case _DeviceCapability():
return $default(_that.hasUsableCamera,_that.osVersionSupported);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool hasUsableCamera,  bool osVersionSupported)?  $default,) {final _that = this;
switch (_that) {
case _DeviceCapability() when $default != null:
return $default(_that.hasUsableCamera,_that.osVersionSupported);case _:
  return null;

}
}

}

/// @nodoc


class _DeviceCapability extends DeviceCapability {
  const _DeviceCapability({required this.hasUsableCamera, required this.osVersionSupported}): super._();
  

@override final  bool hasUsableCamera;
/// Checked against the interim minimum-spec baseline (Android 8.0 /
/// iOS 15.0 — research.md §2), pending the product team's formal
/// value.
@override final  bool osVersionSupported;

/// Create a copy of DeviceCapability
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeviceCapabilityCopyWith<_DeviceCapability> get copyWith => __$DeviceCapabilityCopyWithImpl<_DeviceCapability>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeviceCapability&&(identical(other.hasUsableCamera, hasUsableCamera) || other.hasUsableCamera == hasUsableCamera)&&(identical(other.osVersionSupported, osVersionSupported) || other.osVersionSupported == osVersionSupported));
}


@override
int get hashCode {
    return Object.hash(runtimeType,hasUsableCamera,osVersionSupported);
}

@override
String toString() {
    return 'DeviceCapability(hasUsableCamera: $hasUsableCamera, osVersionSupported: $osVersionSupported)';
}


}

/// @nodoc
abstract mixin class _$DeviceCapabilityCopyWith<$Res> implements $DeviceCapabilityCopyWith<$Res> {
  factory _$DeviceCapabilityCopyWith(_DeviceCapability value, $Res Function(_DeviceCapability) _then) = __$DeviceCapabilityCopyWithImpl;
@override @useResult
$Res call({
 bool hasUsableCamera, bool osVersionSupported
});




}
/// @nodoc
class __$DeviceCapabilityCopyWithImpl<$Res>
    implements _$DeviceCapabilityCopyWith<$Res> {
  __$DeviceCapabilityCopyWithImpl(this._self, this._then);

  final _DeviceCapability _self;
  final $Res Function(_DeviceCapability) _then;

/// Create a copy of DeviceCapability
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hasUsableCamera = null,Object? osVersionSupported = null,}) {
  return _then(_DeviceCapability(
hasUsableCamera: null == hasUsableCamera ? _self.hasUsableCamera : hasUsableCamera // ignore: cast_nullable_to_non_nullable
as bool,osVersionSupported: null == osVersionSupported ? _self.osVersionSupported : osVersionSupported // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
