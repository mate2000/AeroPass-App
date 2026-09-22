// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'liveness_capture_view_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LivenessCaptureViewState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LivenessCaptureViewState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'LivenessCaptureViewState()';
}


}

/// @nodoc
class $LivenessCaptureViewStateCopyWith<$Res>  {
$LivenessCaptureViewStateCopyWith(LivenessCaptureViewState _, $Res Function(LivenessCaptureViewState) __);
}


/// Adds pattern-matching-related methods to [LivenessCaptureViewState].
extension LivenessCaptureViewStatePatterns on LivenessCaptureViewState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LivenessCaptureViewLoading value)?  loading,TResult Function( LivenessCaptureViewRunning value)?  running,TResult Function( LivenessCaptureViewOutcome value)?  outcome,TResult Function( LivenessCaptureViewStalled value)?  stalled,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LivenessCaptureViewLoading() when loading != null:
return loading(_that);case LivenessCaptureViewRunning() when running != null:
return running(_that);case LivenessCaptureViewOutcome() when outcome != null:
return outcome(_that);case LivenessCaptureViewStalled() when stalled != null:
return stalled(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LivenessCaptureViewLoading value)  loading,required TResult Function( LivenessCaptureViewRunning value)  running,required TResult Function( LivenessCaptureViewOutcome value)  outcome,required TResult Function( LivenessCaptureViewStalled value)  stalled,}){
final _that = this;
switch (_that) {
case LivenessCaptureViewLoading():
return loading(_that);case LivenessCaptureViewRunning():
return running(_that);case LivenessCaptureViewOutcome():
return outcome(_that);case LivenessCaptureViewStalled():
return stalled(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LivenessCaptureViewLoading value)?  loading,TResult? Function( LivenessCaptureViewRunning value)?  running,TResult? Function( LivenessCaptureViewOutcome value)?  outcome,TResult? Function( LivenessCaptureViewStalled value)?  stalled,}){
final _that = this;
switch (_that) {
case LivenessCaptureViewLoading() when loading != null:
return loading(_that);case LivenessCaptureViewRunning() when running != null:
return running(_that);case LivenessCaptureViewOutcome() when outcome != null:
return outcome(_that);case LivenessCaptureViewStalled() when stalled != null:
return stalled(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( LivenessPhase phase,  double progress)?  running,TResult Function( LivenessOutcome outcome,  bool limitReached)?  outcome,TResult Function()?  stalled,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LivenessCaptureViewLoading() when loading != null:
return loading();case LivenessCaptureViewRunning() when running != null:
return running(_that.phase,_that.progress);case LivenessCaptureViewOutcome() when outcome != null:
return outcome(_that.outcome,_that.limitReached);case LivenessCaptureViewStalled() when stalled != null:
return stalled();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( LivenessPhase phase,  double progress)  running,required TResult Function( LivenessOutcome outcome,  bool limitReached)  outcome,required TResult Function()  stalled,}) {final _that = this;
switch (_that) {
case LivenessCaptureViewLoading():
return loading();case LivenessCaptureViewRunning():
return running(_that.phase,_that.progress);case LivenessCaptureViewOutcome():
return outcome(_that.outcome,_that.limitReached);case LivenessCaptureViewStalled():
return stalled();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( LivenessPhase phase,  double progress)?  running,TResult? Function( LivenessOutcome outcome,  bool limitReached)?  outcome,TResult? Function()?  stalled,}) {final _that = this;
switch (_that) {
case LivenessCaptureViewLoading() when loading != null:
return loading();case LivenessCaptureViewRunning() when running != null:
return running(_that.phase,_that.progress);case LivenessCaptureViewOutcome() when outcome != null:
return outcome(_that.outcome,_that.limitReached);case LivenessCaptureViewStalled() when stalled != null:
return stalled();case _:
  return null;

}
}

}

/// @nodoc


class LivenessCaptureViewLoading implements LivenessCaptureViewState {
  const LivenessCaptureViewLoading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LivenessCaptureViewLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'LivenessCaptureViewState.loading()';
}


}




/// @nodoc


class LivenessCaptureViewRunning implements LivenessCaptureViewState {
  const LivenessCaptureViewRunning({required this.phase, required this.progress});
  

 final  LivenessPhase phase;
 final  double progress;

/// Create a copy of LivenessCaptureViewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LivenessCaptureViewRunningCopyWith<LivenessCaptureViewRunning> get copyWith => _$LivenessCaptureViewRunningCopyWithImpl<LivenessCaptureViewRunning>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LivenessCaptureViewRunning&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.progress, progress) || other.progress == progress));
}


@override
int get hashCode {
    return Object.hash(runtimeType,phase,progress);
}

@override
String toString() {
    return 'LivenessCaptureViewState.running(phase: $phase, progress: $progress)';
}


}

/// @nodoc
abstract mixin class $LivenessCaptureViewRunningCopyWith<$Res> implements $LivenessCaptureViewStateCopyWith<$Res> {
  factory $LivenessCaptureViewRunningCopyWith(LivenessCaptureViewRunning value, $Res Function(LivenessCaptureViewRunning) _then) = _$LivenessCaptureViewRunningCopyWithImpl;
@useResult
$Res call({
 LivenessPhase phase, double progress
});


$LivenessPhaseCopyWith<$Res> get phase;

}
/// @nodoc
class _$LivenessCaptureViewRunningCopyWithImpl<$Res>
    implements $LivenessCaptureViewRunningCopyWith<$Res> {
  _$LivenessCaptureViewRunningCopyWithImpl(this._self, this._then);

  final LivenessCaptureViewRunning _self;
  final $Res Function(LivenessCaptureViewRunning) _then;

/// Create a copy of LivenessCaptureViewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? phase = null,Object? progress = null,}) {
  return _then(LivenessCaptureViewRunning(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as LivenessPhase,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

/// Create a copy of LivenessCaptureViewState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LivenessPhaseCopyWith<$Res> get phase {
  
  return $LivenessPhaseCopyWith<$Res>(_self.phase, (value) {
    return _then(_self.copyWith(phase: value));
  });
}
}

/// @nodoc


class LivenessCaptureViewOutcome implements LivenessCaptureViewState {
  const LivenessCaptureViewOutcome({required this.outcome, required this.limitReached});
  

 final  LivenessOutcome outcome;
 final  bool limitReached;

/// Create a copy of LivenessCaptureViewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LivenessCaptureViewOutcomeCopyWith<LivenessCaptureViewOutcome> get copyWith => _$LivenessCaptureViewOutcomeCopyWithImpl<LivenessCaptureViewOutcome>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LivenessCaptureViewOutcome&&(identical(other.outcome, outcome) || other.outcome == outcome)&&(identical(other.limitReached, limitReached) || other.limitReached == limitReached));
}


@override
int get hashCode {
    return Object.hash(runtimeType,outcome,limitReached);
}

@override
String toString() {
    return 'LivenessCaptureViewState.outcome(outcome: $outcome, limitReached: $limitReached)';
}


}

/// @nodoc
abstract mixin class $LivenessCaptureViewOutcomeCopyWith<$Res> implements $LivenessCaptureViewStateCopyWith<$Res> {
  factory $LivenessCaptureViewOutcomeCopyWith(LivenessCaptureViewOutcome value, $Res Function(LivenessCaptureViewOutcome) _then) = _$LivenessCaptureViewOutcomeCopyWithImpl;
@useResult
$Res call({
 LivenessOutcome outcome, bool limitReached
});


$LivenessOutcomeCopyWith<$Res> get outcome;

}
/// @nodoc
class _$LivenessCaptureViewOutcomeCopyWithImpl<$Res>
    implements $LivenessCaptureViewOutcomeCopyWith<$Res> {
  _$LivenessCaptureViewOutcomeCopyWithImpl(this._self, this._then);

  final LivenessCaptureViewOutcome _self;
  final $Res Function(LivenessCaptureViewOutcome) _then;

/// Create a copy of LivenessCaptureViewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? outcome = null,Object? limitReached = null,}) {
  return _then(LivenessCaptureViewOutcome(
outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as LivenessOutcome,limitReached: null == limitReached ? _self.limitReached : limitReached // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of LivenessCaptureViewState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LivenessOutcomeCopyWith<$Res> get outcome {
  
  return $LivenessOutcomeCopyWith<$Res>(_self.outcome, (value) {
    return _then(_self.copyWith(outcome: value));
  });
}
}

/// @nodoc


class LivenessCaptureViewStalled implements LivenessCaptureViewState {
  const LivenessCaptureViewStalled();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LivenessCaptureViewStalled);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'LivenessCaptureViewState.stalled()';
}


}




// dart format on
