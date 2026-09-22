// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'liveness_sample_outcome.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LivenessSampleOutcome {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LivenessSampleOutcome);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'LivenessSampleOutcome()';
}


}

/// @nodoc
class $LivenessSampleOutcomeCopyWith<$Res>  {
$LivenessSampleOutcomeCopyWith(LivenessSampleOutcome _, $Res Function(LivenessSampleOutcome) __);
}


/// Adds pattern-matching-related methods to [LivenessSampleOutcome].
extension LivenessSampleOutcomePatterns on LivenessSampleOutcome {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LivenessSampleOutcomeInProgress value)?  inProgress,TResult Function( LivenessSampleOutcomeCompleted value)?  completed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LivenessSampleOutcomeInProgress() when inProgress != null:
return inProgress(_that);case LivenessSampleOutcomeCompleted() when completed != null:
return completed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LivenessSampleOutcomeInProgress value)  inProgress,required TResult Function( LivenessSampleOutcomeCompleted value)  completed,}){
final _that = this;
switch (_that) {
case LivenessSampleOutcomeInProgress():
return inProgress(_that);case LivenessSampleOutcomeCompleted():
return completed(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LivenessSampleOutcomeInProgress value)?  inProgress,TResult? Function( LivenessSampleOutcomeCompleted value)?  completed,}){
final _that = this;
switch (_that) {
case LivenessSampleOutcomeInProgress() when inProgress != null:
return inProgress(_that);case LivenessSampleOutcomeCompleted() when completed != null:
return completed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( LivenessPhase phase)?  inProgress,TResult Function( LivenessOutcome outcome)?  completed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LivenessSampleOutcomeInProgress() when inProgress != null:
return inProgress(_that.phase);case LivenessSampleOutcomeCompleted() when completed != null:
return completed(_that.outcome);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( LivenessPhase phase)  inProgress,required TResult Function( LivenessOutcome outcome)  completed,}) {final _that = this;
switch (_that) {
case LivenessSampleOutcomeInProgress():
return inProgress(_that.phase);case LivenessSampleOutcomeCompleted():
return completed(_that.outcome);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( LivenessPhase phase)?  inProgress,TResult? Function( LivenessOutcome outcome)?  completed,}) {final _that = this;
switch (_that) {
case LivenessSampleOutcomeInProgress() when inProgress != null:
return inProgress(_that.phase);case LivenessSampleOutcomeCompleted() when completed != null:
return completed(_that.outcome);case _:
  return null;

}
}

}

/// @nodoc


class LivenessSampleOutcomeInProgress implements LivenessSampleOutcome {
  const LivenessSampleOutcomeInProgress({required this.phase});
  

 final  LivenessPhase phase;

/// Create a copy of LivenessSampleOutcome
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LivenessSampleOutcomeInProgressCopyWith<LivenessSampleOutcomeInProgress> get copyWith => _$LivenessSampleOutcomeInProgressCopyWithImpl<LivenessSampleOutcomeInProgress>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LivenessSampleOutcomeInProgress&&(identical(other.phase, phase) || other.phase == phase));
}


@override
int get hashCode {
    return Object.hash(runtimeType,phase);
}

@override
String toString() {
    return 'LivenessSampleOutcome.inProgress(phase: $phase)';
}


}

/// @nodoc
abstract mixin class $LivenessSampleOutcomeInProgressCopyWith<$Res> implements $LivenessSampleOutcomeCopyWith<$Res> {
  factory $LivenessSampleOutcomeInProgressCopyWith(LivenessSampleOutcomeInProgress value, $Res Function(LivenessSampleOutcomeInProgress) _then) = _$LivenessSampleOutcomeInProgressCopyWithImpl;
@useResult
$Res call({
 LivenessPhase phase
});


$LivenessPhaseCopyWith<$Res> get phase;

}
/// @nodoc
class _$LivenessSampleOutcomeInProgressCopyWithImpl<$Res>
    implements $LivenessSampleOutcomeInProgressCopyWith<$Res> {
  _$LivenessSampleOutcomeInProgressCopyWithImpl(this._self, this._then);

  final LivenessSampleOutcomeInProgress _self;
  final $Res Function(LivenessSampleOutcomeInProgress) _then;

/// Create a copy of LivenessSampleOutcome
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? phase = null,}) {
  return _then(LivenessSampleOutcomeInProgress(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as LivenessPhase,
  ));
}

/// Create a copy of LivenessSampleOutcome
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


class LivenessSampleOutcomeCompleted implements LivenessSampleOutcome {
  const LivenessSampleOutcomeCompleted({required this.outcome});
  

 final  LivenessOutcome outcome;

/// Create a copy of LivenessSampleOutcome
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LivenessSampleOutcomeCompletedCopyWith<LivenessSampleOutcomeCompleted> get copyWith => _$LivenessSampleOutcomeCompletedCopyWithImpl<LivenessSampleOutcomeCompleted>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LivenessSampleOutcomeCompleted&&(identical(other.outcome, outcome) || other.outcome == outcome));
}


@override
int get hashCode {
    return Object.hash(runtimeType,outcome);
}

@override
String toString() {
    return 'LivenessSampleOutcome.completed(outcome: $outcome)';
}


}

/// @nodoc
abstract mixin class $LivenessSampleOutcomeCompletedCopyWith<$Res> implements $LivenessSampleOutcomeCopyWith<$Res> {
  factory $LivenessSampleOutcomeCompletedCopyWith(LivenessSampleOutcomeCompleted value, $Res Function(LivenessSampleOutcomeCompleted) _then) = _$LivenessSampleOutcomeCompletedCopyWithImpl;
@useResult
$Res call({
 LivenessOutcome outcome
});


$LivenessOutcomeCopyWith<$Res> get outcome;

}
/// @nodoc
class _$LivenessSampleOutcomeCompletedCopyWithImpl<$Res>
    implements $LivenessSampleOutcomeCompletedCopyWith<$Res> {
  _$LivenessSampleOutcomeCompletedCopyWithImpl(this._self, this._then);

  final LivenessSampleOutcomeCompleted _self;
  final $Res Function(LivenessSampleOutcomeCompleted) _then;

/// Create a copy of LivenessSampleOutcome
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? outcome = null,}) {
  return _then(LivenessSampleOutcomeCompleted(
outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as LivenessOutcome,
  ));
}

/// Create a copy of LivenessSampleOutcome
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LivenessOutcomeCopyWith<$Res> get outcome {
  
  return $LivenessOutcomeCopyWith<$Res>(_self.outcome, (value) {
    return _then(_self.copyWith(outcome: value));
  });
}
}

// dart format on
