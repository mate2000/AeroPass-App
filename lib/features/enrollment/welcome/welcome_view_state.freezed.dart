// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'welcome_view_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WelcomeViewState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is WelcomeViewState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'WelcomeViewState()';
}


}

/// @nodoc
class $WelcomeViewStateCopyWith<$Res>  {
$WelcomeViewStateCopyWith(WelcomeViewState _, $Res Function(WelcomeViewState) __);
}


/// Adds pattern-matching-related methods to [WelcomeViewState].
extension WelcomeViewStatePatterns on WelcomeViewState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( WelcomeViewChecking value)?  checking,TResult Function( WelcomeViewDeviceUnsupported value)?  deviceUnsupported,TResult Function( WelcomeViewContent value)?  content,required TResult orElse(),}){
final _that = this;
switch (_that) {
case WelcomeViewChecking() when checking != null:
return checking(_that);case WelcomeViewDeviceUnsupported() when deviceUnsupported != null:
return deviceUnsupported(_that);case WelcomeViewContent() when content != null:
return content(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( WelcomeViewChecking value)  checking,required TResult Function( WelcomeViewDeviceUnsupported value)  deviceUnsupported,required TResult Function( WelcomeViewContent value)  content,}){
final _that = this;
switch (_that) {
case WelcomeViewChecking():
return checking(_that);case WelcomeViewDeviceUnsupported():
return deviceUnsupported(_that);case WelcomeViewContent():
return content(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( WelcomeViewChecking value)?  checking,TResult? Function( WelcomeViewDeviceUnsupported value)?  deviceUnsupported,TResult? Function( WelcomeViewContent value)?  content,}){
final _that = this;
switch (_that) {
case WelcomeViewChecking() when checking != null:
return checking(_that);case WelcomeViewDeviceUnsupported() when deviceUnsupported != null:
return deviceUnsupported(_that);case WelcomeViewContent() when content != null:
return content(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  checking,TResult Function( DeviceUnsupportedReason reason)?  deviceUnsupported,TResult Function( WelcomeScreenVariant variant,  bool unrefreshed,  ExpiryReason? expiryReason)?  content,required TResult orElse(),}) {final _that = this;
switch (_that) {
case WelcomeViewChecking() when checking != null:
return checking();case WelcomeViewDeviceUnsupported() when deviceUnsupported != null:
return deviceUnsupported(_that.reason);case WelcomeViewContent() when content != null:
return content(_that.variant,_that.unrefreshed,_that.expiryReason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  checking,required TResult Function( DeviceUnsupportedReason reason)  deviceUnsupported,required TResult Function( WelcomeScreenVariant variant,  bool unrefreshed,  ExpiryReason? expiryReason)  content,}) {final _that = this;
switch (_that) {
case WelcomeViewChecking():
return checking();case WelcomeViewDeviceUnsupported():
return deviceUnsupported(_that.reason);case WelcomeViewContent():
return content(_that.variant,_that.unrefreshed,_that.expiryReason);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  checking,TResult? Function( DeviceUnsupportedReason reason)?  deviceUnsupported,TResult? Function( WelcomeScreenVariant variant,  bool unrefreshed,  ExpiryReason? expiryReason)?  content,}) {final _that = this;
switch (_that) {
case WelcomeViewChecking() when checking != null:
return checking();case WelcomeViewDeviceUnsupported() when deviceUnsupported != null:
return deviceUnsupported(_that.reason);case WelcomeViewContent() when content != null:
return content(_that.variant,_that.unrefreshed,_that.expiryReason);case _:
  return null;

}
}

}

/// @nodoc


class WelcomeViewChecking implements WelcomeViewState {
  const WelcomeViewChecking();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is WelcomeViewChecking);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'WelcomeViewState.checking()';
}


}




/// @nodoc


class WelcomeViewDeviceUnsupported implements WelcomeViewState {
  const WelcomeViewDeviceUnsupported({required this.reason});
  

 final  DeviceUnsupportedReason reason;

/// Create a copy of WelcomeViewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WelcomeViewDeviceUnsupportedCopyWith<WelcomeViewDeviceUnsupported> get copyWith => _$WelcomeViewDeviceUnsupportedCopyWithImpl<WelcomeViewDeviceUnsupported>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is WelcomeViewDeviceUnsupported&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode {
    return Object.hash(runtimeType,reason);
}

@override
String toString() {
    return 'WelcomeViewState.deviceUnsupported(reason: $reason)';
}


}

/// @nodoc
abstract mixin class $WelcomeViewDeviceUnsupportedCopyWith<$Res> implements $WelcomeViewStateCopyWith<$Res> {
  factory $WelcomeViewDeviceUnsupportedCopyWith(WelcomeViewDeviceUnsupported value, $Res Function(WelcomeViewDeviceUnsupported) _then) = _$WelcomeViewDeviceUnsupportedCopyWithImpl;
@useResult
$Res call({
 DeviceUnsupportedReason reason
});




}
/// @nodoc
class _$WelcomeViewDeviceUnsupportedCopyWithImpl<$Res>
    implements $WelcomeViewDeviceUnsupportedCopyWith<$Res> {
  _$WelcomeViewDeviceUnsupportedCopyWithImpl(this._self, this._then);

  final WelcomeViewDeviceUnsupported _self;
  final $Res Function(WelcomeViewDeviceUnsupported) _then;

/// Create a copy of WelcomeViewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reason = null,}) {
  return _then(WelcomeViewDeviceUnsupported(
reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as DeviceUnsupportedReason,
  ));
}


}

/// @nodoc


class WelcomeViewContent implements WelcomeViewState {
  const WelcomeViewContent({required this.variant, this.unrefreshed = false, this.expiryReason});
  

 final  WelcomeScreenVariant variant;
@JsonKey() final  bool unrefreshed;
/// Only set when [variant] is `reenrollmentRequired` — which distinct
/// explanation to show (FR-006).
 final  ExpiryReason? expiryReason;

/// Create a copy of WelcomeViewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WelcomeViewContentCopyWith<WelcomeViewContent> get copyWith => _$WelcomeViewContentCopyWithImpl<WelcomeViewContent>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is WelcomeViewContent&&(identical(other.variant, variant) || other.variant == variant)&&(identical(other.unrefreshed, unrefreshed) || other.unrefreshed == unrefreshed)&&(identical(other.expiryReason, expiryReason) || other.expiryReason == expiryReason));
}


@override
int get hashCode {
    return Object.hash(runtimeType,variant,unrefreshed,expiryReason);
}

@override
String toString() {
    return 'WelcomeViewState.content(variant: $variant, unrefreshed: $unrefreshed, expiryReason: $expiryReason)';
}


}

/// @nodoc
abstract mixin class $WelcomeViewContentCopyWith<$Res> implements $WelcomeViewStateCopyWith<$Res> {
  factory $WelcomeViewContentCopyWith(WelcomeViewContent value, $Res Function(WelcomeViewContent) _then) = _$WelcomeViewContentCopyWithImpl;
@useResult
$Res call({
 WelcomeScreenVariant variant, bool unrefreshed, ExpiryReason? expiryReason
});




}
/// @nodoc
class _$WelcomeViewContentCopyWithImpl<$Res>
    implements $WelcomeViewContentCopyWith<$Res> {
  _$WelcomeViewContentCopyWithImpl(this._self, this._then);

  final WelcomeViewContent _self;
  final $Res Function(WelcomeViewContent) _then;

/// Create a copy of WelcomeViewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? variant = null,Object? unrefreshed = null,Object? expiryReason = freezed,}) {
  return _then(WelcomeViewContent(
variant: null == variant ? _self.variant : variant // ignore: cast_nullable_to_non_nullable
as WelcomeScreenVariant,unrefreshed: null == unrefreshed ? _self.unrefreshed : unrefreshed // ignore: cast_nullable_to_non_nullable
as bool,expiryReason: freezed == expiryReason ? _self.expiryReason : expiryReason // ignore: cast_nullable_to_non_nullable
as ExpiryReason?,
  ));
}


}

// dart format on
