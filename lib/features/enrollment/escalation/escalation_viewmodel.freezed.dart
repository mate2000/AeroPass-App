// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'escalation_viewmodel.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EscalationViewState implements DiagnosticableTreeMixin {




@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
    ..add(DiagnosticsProperty('type', 'EscalationViewState'))
    ;
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EscalationViewState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'EscalationViewState()';
}


}

/// @nodoc
class $EscalationViewStateCopyWith<$Res>  {
$EscalationViewStateCopyWith(EscalationViewState _, $Res Function(EscalationViewState) __);
}


/// Adds pattern-matching-related methods to [EscalationViewState].
extension EscalationViewStatePatterns on EscalationViewState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( EscalationViewLoading value)?  loading,TResult Function( EscalationViewOpen value)?  open,TResult Function( EscalationViewDeclined value)?  declined,TResult Function( EscalationViewExpired value)?  expired,TResult Function( EscalationViewUnavailable value)?  unavailable,TResult Function( EscalationViewLaneOnly value)?  laneOnly,required TResult orElse(),}){
final _that = this;
switch (_that) {
case EscalationViewLoading() when loading != null:
return loading(_that);case EscalationViewOpen() when open != null:
return open(_that);case EscalationViewDeclined() when declined != null:
return declined(_that);case EscalationViewExpired() when expired != null:
return expired(_that);case EscalationViewUnavailable() when unavailable != null:
return unavailable(_that);case EscalationViewLaneOnly() when laneOnly != null:
return laneOnly(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( EscalationViewLoading value)  loading,required TResult Function( EscalationViewOpen value)  open,required TResult Function( EscalationViewDeclined value)  declined,required TResult Function( EscalationViewExpired value)  expired,required TResult Function( EscalationViewUnavailable value)  unavailable,required TResult Function( EscalationViewLaneOnly value)  laneOnly,}){
final _that = this;
switch (_that) {
case EscalationViewLoading():
return loading(_that);case EscalationViewOpen():
return open(_that);case EscalationViewDeclined():
return declined(_that);case EscalationViewExpired():
return expired(_that);case EscalationViewUnavailable():
return unavailable(_that);case EscalationViewLaneOnly():
return laneOnly(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( EscalationViewLoading value)?  loading,TResult? Function( EscalationViewOpen value)?  open,TResult? Function( EscalationViewDeclined value)?  declined,TResult? Function( EscalationViewExpired value)?  expired,TResult? Function( EscalationViewUnavailable value)?  unavailable,TResult? Function( EscalationViewLaneOnly value)?  laneOnly,}){
final _that = this;
switch (_that) {
case EscalationViewLoading() when loading != null:
return loading(_that);case EscalationViewOpen() when open != null:
return open(_that);case EscalationViewDeclined() when declined != null:
return declined(_that);case EscalationViewExpired() when expired != null:
return expired(_that);case EscalationViewUnavailable() when unavailable != null:
return unavailable(_that);case EscalationViewLaneOnly() when laneOnly != null:
return laneOnly(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( List<AgentChannel> channels)?  open,TResult Function()?  declined,TResult Function()?  expired,TResult Function()?  unavailable,TResult Function()?  laneOnly,required TResult orElse(),}) {final _that = this;
switch (_that) {
case EscalationViewLoading() when loading != null:
return loading();case EscalationViewOpen() when open != null:
return open(_that.channels);case EscalationViewDeclined() when declined != null:
return declined();case EscalationViewExpired() when expired != null:
return expired();case EscalationViewUnavailable() when unavailable != null:
return unavailable();case EscalationViewLaneOnly() when laneOnly != null:
return laneOnly();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( List<AgentChannel> channels)  open,required TResult Function()  declined,required TResult Function()  expired,required TResult Function()  unavailable,required TResult Function()  laneOnly,}) {final _that = this;
switch (_that) {
case EscalationViewLoading():
return loading();case EscalationViewOpen():
return open(_that.channels);case EscalationViewDeclined():
return declined();case EscalationViewExpired():
return expired();case EscalationViewUnavailable():
return unavailable();case EscalationViewLaneOnly():
return laneOnly();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( List<AgentChannel> channels)?  open,TResult? Function()?  declined,TResult? Function()?  expired,TResult? Function()?  unavailable,TResult? Function()?  laneOnly,}) {final _that = this;
switch (_that) {
case EscalationViewLoading() when loading != null:
return loading();case EscalationViewOpen() when open != null:
return open(_that.channels);case EscalationViewDeclined() when declined != null:
return declined();case EscalationViewExpired() when expired != null:
return expired();case EscalationViewUnavailable() when unavailable != null:
return unavailable();case EscalationViewLaneOnly() when laneOnly != null:
return laneOnly();case _:
  return null;

}
}

}

/// @nodoc


class EscalationViewLoading with DiagnosticableTreeMixin implements EscalationViewState {
  const EscalationViewLoading();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
    ..add(DiagnosticsProperty('type', 'EscalationViewState.loading'))
    ;
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EscalationViewLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'EscalationViewState.loading()';
}


}




/// @nodoc


class EscalationViewOpen with DiagnosticableTreeMixin implements EscalationViewState {
  const EscalationViewOpen({required  List<AgentChannel> channels}): _channels = channels;
  

 final  List<AgentChannel> _channels;
 List<AgentChannel> get channels {
  if (_channels is EqualUnmodifiableListView) return _channels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_channels);
}


/// Create a copy of EscalationViewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EscalationViewOpenCopyWith<EscalationViewOpen> get copyWith => _$EscalationViewOpenCopyWithImpl<EscalationViewOpen>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
    ..add(DiagnosticsProperty('type', 'EscalationViewState.open'))
    ..add(DiagnosticsProperty('channels', channels));
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EscalationViewOpen&&const DeepCollectionEquality().equals(other.channels, _channels));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_channels));
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'EscalationViewState.open(channels: $channels)';
}


}

/// @nodoc
abstract mixin class $EscalationViewOpenCopyWith<$Res> implements $EscalationViewStateCopyWith<$Res> {
  factory $EscalationViewOpenCopyWith(EscalationViewOpen value, $Res Function(EscalationViewOpen) _then) = _$EscalationViewOpenCopyWithImpl;
@useResult
$Res call({
 List<AgentChannel> channels
});




}
/// @nodoc
class _$EscalationViewOpenCopyWithImpl<$Res>
    implements $EscalationViewOpenCopyWith<$Res> {
  _$EscalationViewOpenCopyWithImpl(this._self, this._then);

  final EscalationViewOpen _self;
  final $Res Function(EscalationViewOpen) _then;

/// Create a copy of EscalationViewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? channels = null,}) {
  return _then(EscalationViewOpen(
channels: null == channels ? _self._channels : channels // ignore: cast_nullable_to_non_nullable
as List<AgentChannel>,
  ));
}


}

/// @nodoc


class EscalationViewDeclined with DiagnosticableTreeMixin implements EscalationViewState {
  const EscalationViewDeclined();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
    ..add(DiagnosticsProperty('type', 'EscalationViewState.declined'))
    ;
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EscalationViewDeclined);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'EscalationViewState.declined()';
}


}




/// @nodoc


class EscalationViewExpired with DiagnosticableTreeMixin implements EscalationViewState {
  const EscalationViewExpired();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
    ..add(DiagnosticsProperty('type', 'EscalationViewState.expired'))
    ;
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EscalationViewExpired);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'EscalationViewState.expired()';
}


}




/// @nodoc


class EscalationViewUnavailable with DiagnosticableTreeMixin implements EscalationViewState {
  const EscalationViewUnavailable();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
    ..add(DiagnosticsProperty('type', 'EscalationViewState.unavailable'))
    ;
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EscalationViewUnavailable);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'EscalationViewState.unavailable()';
}


}




/// @nodoc


class EscalationViewLaneOnly with DiagnosticableTreeMixin implements EscalationViewState {
  const EscalationViewLaneOnly();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
    ..add(DiagnosticsProperty('type', 'EscalationViewState.laneOnly'))
    ;
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EscalationViewLaneOnly);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'EscalationViewState.laneOnly()';
}


}




// dart format on
