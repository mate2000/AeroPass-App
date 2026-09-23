// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verification_progress_viewmodel.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VerificationProgressViewState implements DiagnosticableTreeMixin {

 Map<VerificationStage, StageStatus> get stages;
/// Create a copy of VerificationProgressViewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerificationProgressViewStateCopyWith<VerificationProgressViewState> get copyWith => _$VerificationProgressViewStateCopyWithImpl<VerificationProgressViewState>(this as VerificationProgressViewState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  final _this = this as VerificationProgressViewState;
  properties
    ..add(DiagnosticsProperty('type', 'VerificationProgressViewState'))
    ..add(DiagnosticsProperty('stages', _this.stages));
}

@override
bool operator ==(Object other) {
  final _this = this as VerificationProgressViewState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerificationProgressViewState&&const DeepCollectionEquality().equals(other.stages, _this.stages));
}


@override
int get hashCode {
  final _this = this as VerificationProgressViewState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.stages));
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  final _this = this as VerificationProgressViewState;
  return 'VerificationProgressViewState(stages: ${_this.stages})';
}


}

/// @nodoc
abstract mixin class $VerificationProgressViewStateCopyWith<$Res>  {
  factory $VerificationProgressViewStateCopyWith(VerificationProgressViewState value, $Res Function(VerificationProgressViewState) _then) = _$VerificationProgressViewStateCopyWithImpl;
@useResult
$Res call({
 Map<VerificationStage, StageStatus> stages
});




}
/// @nodoc
class _$VerificationProgressViewStateCopyWithImpl<$Res>
    implements $VerificationProgressViewStateCopyWith<$Res> {
  _$VerificationProgressViewStateCopyWithImpl(this._self, this._then);

  final VerificationProgressViewState _self;
  final $Res Function(VerificationProgressViewState) _then;

/// Create a copy of VerificationProgressViewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stages = null,}) {
  return _then(_self.copyWith(
stages: null == stages ? _self.stages : stages // ignore: cast_nullable_to_non_nullable
as Map<VerificationStage, StageStatus>,
  ));
}

}


/// Adds pattern-matching-related methods to [VerificationProgressViewState].
extension VerificationProgressViewStatePatterns on VerificationProgressViewState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( VerificationWaiting value)?  waiting,TResult Function( VerificationFailed value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case VerificationWaiting() when waiting != null:
return waiting(_that);case VerificationFailed() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( VerificationWaiting value)  waiting,required TResult Function( VerificationFailed value)  failed,}){
final _that = this;
switch (_that) {
case VerificationWaiting():
return waiting(_that);case VerificationFailed():
return failed(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( VerificationWaiting value)?  waiting,TResult? Function( VerificationFailed value)?  failed,}){
final _that = this;
switch (_that) {
case VerificationWaiting() when waiting != null:
return waiting(_that);case VerificationFailed() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( Map<VerificationStage, StageStatus> stages,  bool slowNoticeVisible)?  waiting,TResult Function( Map<VerificationStage, StageStatus> stages,  VerificationStage failedStage)?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case VerificationWaiting() when waiting != null:
return waiting(_that.stages,_that.slowNoticeVisible);case VerificationFailed() when failed != null:
return failed(_that.stages,_that.failedStage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( Map<VerificationStage, StageStatus> stages,  bool slowNoticeVisible)  waiting,required TResult Function( Map<VerificationStage, StageStatus> stages,  VerificationStage failedStage)  failed,}) {final _that = this;
switch (_that) {
case VerificationWaiting():
return waiting(_that.stages,_that.slowNoticeVisible);case VerificationFailed():
return failed(_that.stages,_that.failedStage);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( Map<VerificationStage, StageStatus> stages,  bool slowNoticeVisible)?  waiting,TResult? Function( Map<VerificationStage, StageStatus> stages,  VerificationStage failedStage)?  failed,}) {final _that = this;
switch (_that) {
case VerificationWaiting() when waiting != null:
return waiting(_that.stages,_that.slowNoticeVisible);case VerificationFailed() when failed != null:
return failed(_that.stages,_that.failedStage);case _:
  return null;

}
}

}

/// @nodoc


class VerificationWaiting with DiagnosticableTreeMixin implements VerificationProgressViewState {
  const VerificationWaiting({required  Map<VerificationStage, StageStatus> stages, required this.slowNoticeVisible}): _stages = stages;
  

 final  Map<VerificationStage, StageStatus> _stages;
@override Map<VerificationStage, StageStatus> get stages {
  if (_stages is EqualUnmodifiableMapView) return _stages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_stages);
}

 final  bool slowNoticeVisible;

/// Create a copy of VerificationProgressViewState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerificationWaitingCopyWith<VerificationWaiting> get copyWith => _$VerificationWaitingCopyWithImpl<VerificationWaiting>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
    ..add(DiagnosticsProperty('type', 'VerificationProgressViewState.waiting'))
    ..add(DiagnosticsProperty('stages', stages))..add(DiagnosticsProperty('slowNoticeVisible', slowNoticeVisible));
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is VerificationWaiting&&const DeepCollectionEquality().equals(other.stages, _stages)&&(identical(other.slowNoticeVisible, slowNoticeVisible) || other.slowNoticeVisible == slowNoticeVisible));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_stages),slowNoticeVisible);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'VerificationProgressViewState.waiting(stages: $stages, slowNoticeVisible: $slowNoticeVisible)';
}


}

/// @nodoc
abstract mixin class $VerificationWaitingCopyWith<$Res> implements $VerificationProgressViewStateCopyWith<$Res> {
  factory $VerificationWaitingCopyWith(VerificationWaiting value, $Res Function(VerificationWaiting) _then) = _$VerificationWaitingCopyWithImpl;
@override @useResult
$Res call({
 Map<VerificationStage, StageStatus> stages, bool slowNoticeVisible
});




}
/// @nodoc
class _$VerificationWaitingCopyWithImpl<$Res>
    implements $VerificationWaitingCopyWith<$Res> {
  _$VerificationWaitingCopyWithImpl(this._self, this._then);

  final VerificationWaiting _self;
  final $Res Function(VerificationWaiting) _then;

/// Create a copy of VerificationProgressViewState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stages = null,Object? slowNoticeVisible = null,}) {
  return _then(VerificationWaiting(
stages: null == stages ? _self._stages : stages // ignore: cast_nullable_to_non_nullable
as Map<VerificationStage, StageStatus>,slowNoticeVisible: null == slowNoticeVisible ? _self.slowNoticeVisible : slowNoticeVisible // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class VerificationFailed with DiagnosticableTreeMixin implements VerificationProgressViewState {
  const VerificationFailed({required  Map<VerificationStage, StageStatus> stages, required this.failedStage}): _stages = stages;
  

 final  Map<VerificationStage, StageStatus> _stages;
@override Map<VerificationStage, StageStatus> get stages {
  if (_stages is EqualUnmodifiableMapView) return _stages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_stages);
}

 final  VerificationStage failedStage;

/// Create a copy of VerificationProgressViewState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerificationFailedCopyWith<VerificationFailed> get copyWith => _$VerificationFailedCopyWithImpl<VerificationFailed>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
    ..add(DiagnosticsProperty('type', 'VerificationProgressViewState.failed'))
    ..add(DiagnosticsProperty('stages', stages))..add(DiagnosticsProperty('failedStage', failedStage));
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is VerificationFailed&&const DeepCollectionEquality().equals(other.stages, _stages)&&(identical(other.failedStage, failedStage) || other.failedStage == failedStage));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_stages),failedStage);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'VerificationProgressViewState.failed(stages: $stages, failedStage: $failedStage)';
}


}

/// @nodoc
abstract mixin class $VerificationFailedCopyWith<$Res> implements $VerificationProgressViewStateCopyWith<$Res> {
  factory $VerificationFailedCopyWith(VerificationFailed value, $Res Function(VerificationFailed) _then) = _$VerificationFailedCopyWithImpl;
@override @useResult
$Res call({
 Map<VerificationStage, StageStatus> stages, VerificationStage failedStage
});




}
/// @nodoc
class _$VerificationFailedCopyWithImpl<$Res>
    implements $VerificationFailedCopyWith<$Res> {
  _$VerificationFailedCopyWithImpl(this._self, this._then);

  final VerificationFailed _self;
  final $Res Function(VerificationFailed) _then;

/// Create a copy of VerificationProgressViewState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stages = null,Object? failedStage = null,}) {
  return _then(VerificationFailed(
stages: null == stages ? _self._stages : stages // ignore: cast_nullable_to_non_nullable
as Map<VerificationStage, StageStatus>,failedStage: null == failedStage ? _self.failedStage : failedStage // ignore: cast_nullable_to_non_nullable
as VerificationStage,
  ));
}


}

// dart format on
