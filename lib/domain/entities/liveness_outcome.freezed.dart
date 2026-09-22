// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'liveness_outcome.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LivenessOutcome {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LivenessOutcome);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'LivenessOutcome()';
}


}

/// @nodoc
class $LivenessOutcomeCopyWith<$Res>  {
$LivenessOutcomeCopyWith(LivenessOutcome _, $Res Function(LivenessOutcome) __);
}


/// Adds pattern-matching-related methods to [LivenessOutcome].
extension LivenessOutcomePatterns on LivenessOutcome {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LivenessOutcomeSuccess value)?  success,TResult Function( LivenessOutcomeQualityFailure value)?  qualityFailure,TResult Function( LivenessOutcomeUnclassifiedFailure value)?  unclassifiedFailure,TResult Function( LivenessOutcomeAttackDetected value)?  attackDetected,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LivenessOutcomeSuccess() when success != null:
return success(_that);case LivenessOutcomeQualityFailure() when qualityFailure != null:
return qualityFailure(_that);case LivenessOutcomeUnclassifiedFailure() when unclassifiedFailure != null:
return unclassifiedFailure(_that);case LivenessOutcomeAttackDetected() when attackDetected != null:
return attackDetected(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LivenessOutcomeSuccess value)  success,required TResult Function( LivenessOutcomeQualityFailure value)  qualityFailure,required TResult Function( LivenessOutcomeUnclassifiedFailure value)  unclassifiedFailure,required TResult Function( LivenessOutcomeAttackDetected value)  attackDetected,}){
final _that = this;
switch (_that) {
case LivenessOutcomeSuccess():
return success(_that);case LivenessOutcomeQualityFailure():
return qualityFailure(_that);case LivenessOutcomeUnclassifiedFailure():
return unclassifiedFailure(_that);case LivenessOutcomeAttackDetected():
return attackDetected(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LivenessOutcomeSuccess value)?  success,TResult? Function( LivenessOutcomeQualityFailure value)?  qualityFailure,TResult? Function( LivenessOutcomeUnclassifiedFailure value)?  unclassifiedFailure,TResult? Function( LivenessOutcomeAttackDetected value)?  attackDetected,}){
final _that = this;
switch (_that) {
case LivenessOutcomeSuccess() when success != null:
return success(_that);case LivenessOutcomeQualityFailure() when qualityFailure != null:
return qualityFailure(_that);case LivenessOutcomeUnclassifiedFailure() when unclassifiedFailure != null:
return unclassifiedFailure(_that);case LivenessOutcomeAttackDetected() when attackDetected != null:
return attackDetected(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  success,TResult Function( LivenessQualityReason reason)?  qualityFailure,TResult Function()?  unclassifiedFailure,TResult Function()?  attackDetected,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LivenessOutcomeSuccess() when success != null:
return success();case LivenessOutcomeQualityFailure() when qualityFailure != null:
return qualityFailure(_that.reason);case LivenessOutcomeUnclassifiedFailure() when unclassifiedFailure != null:
return unclassifiedFailure();case LivenessOutcomeAttackDetected() when attackDetected != null:
return attackDetected();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  success,required TResult Function( LivenessQualityReason reason)  qualityFailure,required TResult Function()  unclassifiedFailure,required TResult Function()  attackDetected,}) {final _that = this;
switch (_that) {
case LivenessOutcomeSuccess():
return success();case LivenessOutcomeQualityFailure():
return qualityFailure(_that.reason);case LivenessOutcomeUnclassifiedFailure():
return unclassifiedFailure();case LivenessOutcomeAttackDetected():
return attackDetected();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  success,TResult? Function( LivenessQualityReason reason)?  qualityFailure,TResult? Function()?  unclassifiedFailure,TResult? Function()?  attackDetected,}) {final _that = this;
switch (_that) {
case LivenessOutcomeSuccess() when success != null:
return success();case LivenessOutcomeQualityFailure() when qualityFailure != null:
return qualityFailure(_that.reason);case LivenessOutcomeUnclassifiedFailure() when unclassifiedFailure != null:
return unclassifiedFailure();case LivenessOutcomeAttackDetected() when attackDetected != null:
return attackDetected();case _:
  return null;

}
}

}

/// @nodoc


class LivenessOutcomeSuccess implements LivenessOutcome {
  const LivenessOutcomeSuccess();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LivenessOutcomeSuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'LivenessOutcome.success()';
}


}




/// @nodoc


class LivenessOutcomeQualityFailure implements LivenessOutcome {
  const LivenessOutcomeQualityFailure({required this.reason});
  

 final  LivenessQualityReason reason;

/// Create a copy of LivenessOutcome
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LivenessOutcomeQualityFailureCopyWith<LivenessOutcomeQualityFailure> get copyWith => _$LivenessOutcomeQualityFailureCopyWithImpl<LivenessOutcomeQualityFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LivenessOutcomeQualityFailure&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode {
    return Object.hash(runtimeType,reason);
}

@override
String toString() {
    return 'LivenessOutcome.qualityFailure(reason: $reason)';
}


}

/// @nodoc
abstract mixin class $LivenessOutcomeQualityFailureCopyWith<$Res> implements $LivenessOutcomeCopyWith<$Res> {
  factory $LivenessOutcomeQualityFailureCopyWith(LivenessOutcomeQualityFailure value, $Res Function(LivenessOutcomeQualityFailure) _then) = _$LivenessOutcomeQualityFailureCopyWithImpl;
@useResult
$Res call({
 LivenessQualityReason reason
});




}
/// @nodoc
class _$LivenessOutcomeQualityFailureCopyWithImpl<$Res>
    implements $LivenessOutcomeQualityFailureCopyWith<$Res> {
  _$LivenessOutcomeQualityFailureCopyWithImpl(this._self, this._then);

  final LivenessOutcomeQualityFailure _self;
  final $Res Function(LivenessOutcomeQualityFailure) _then;

/// Create a copy of LivenessOutcome
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reason = null,}) {
  return _then(LivenessOutcomeQualityFailure(
reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as LivenessQualityReason,
  ));
}


}

/// @nodoc


class LivenessOutcomeUnclassifiedFailure implements LivenessOutcome {
  const LivenessOutcomeUnclassifiedFailure();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LivenessOutcomeUnclassifiedFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'LivenessOutcome.unclassifiedFailure()';
}


}




/// @nodoc


class LivenessOutcomeAttackDetected implements LivenessOutcome {
  const LivenessOutcomeAttackDetected();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LivenessOutcomeAttackDetected);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'LivenessOutcome.attackDetected()';
}


}




// dart format on
