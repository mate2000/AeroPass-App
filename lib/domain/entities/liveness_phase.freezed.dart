// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'liveness_phase.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LivenessInstruction {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LivenessInstruction);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'LivenessInstruction()';
}


}

/// @nodoc
class $LivenessInstructionCopyWith<$Res>  {
$LivenessInstructionCopyWith(LivenessInstruction _, $Res Function(LivenessInstruction) __);
}


/// Adds pattern-matching-related methods to [LivenessInstruction].
extension LivenessInstructionPatterns on LivenessInstruction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LivenessInstructionMoveCloser value)?  moveCloser,TResult Function( LivenessInstructionMoveBack value)?  moveBack,TResult Function( LivenessInstructionCenterFace value)?  centerFace,TResult Function( LivenessInstructionHoldStill value)?  holdStill,TResult Function( LivenessInstructionLookAtCamera value)?  lookAtCamera,TResult Function( LivenessInstructionImproveLighting value)?  improveLighting,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LivenessInstructionMoveCloser() when moveCloser != null:
return moveCloser(_that);case LivenessInstructionMoveBack() when moveBack != null:
return moveBack(_that);case LivenessInstructionCenterFace() when centerFace != null:
return centerFace(_that);case LivenessInstructionHoldStill() when holdStill != null:
return holdStill(_that);case LivenessInstructionLookAtCamera() when lookAtCamera != null:
return lookAtCamera(_that);case LivenessInstructionImproveLighting() when improveLighting != null:
return improveLighting(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LivenessInstructionMoveCloser value)  moveCloser,required TResult Function( LivenessInstructionMoveBack value)  moveBack,required TResult Function( LivenessInstructionCenterFace value)  centerFace,required TResult Function( LivenessInstructionHoldStill value)  holdStill,required TResult Function( LivenessInstructionLookAtCamera value)  lookAtCamera,required TResult Function( LivenessInstructionImproveLighting value)  improveLighting,}){
final _that = this;
switch (_that) {
case LivenessInstructionMoveCloser():
return moveCloser(_that);case LivenessInstructionMoveBack():
return moveBack(_that);case LivenessInstructionCenterFace():
return centerFace(_that);case LivenessInstructionHoldStill():
return holdStill(_that);case LivenessInstructionLookAtCamera():
return lookAtCamera(_that);case LivenessInstructionImproveLighting():
return improveLighting(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LivenessInstructionMoveCloser value)?  moveCloser,TResult? Function( LivenessInstructionMoveBack value)?  moveBack,TResult? Function( LivenessInstructionCenterFace value)?  centerFace,TResult? Function( LivenessInstructionHoldStill value)?  holdStill,TResult? Function( LivenessInstructionLookAtCamera value)?  lookAtCamera,TResult? Function( LivenessInstructionImproveLighting value)?  improveLighting,}){
final _that = this;
switch (_that) {
case LivenessInstructionMoveCloser() when moveCloser != null:
return moveCloser(_that);case LivenessInstructionMoveBack() when moveBack != null:
return moveBack(_that);case LivenessInstructionCenterFace() when centerFace != null:
return centerFace(_that);case LivenessInstructionHoldStill() when holdStill != null:
return holdStill(_that);case LivenessInstructionLookAtCamera() when lookAtCamera != null:
return lookAtCamera(_that);case LivenessInstructionImproveLighting() when improveLighting != null:
return improveLighting(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  moveCloser,TResult Function()?  moveBack,TResult Function()?  centerFace,TResult Function()?  holdStill,TResult Function()?  lookAtCamera,TResult Function()?  improveLighting,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LivenessInstructionMoveCloser() when moveCloser != null:
return moveCloser();case LivenessInstructionMoveBack() when moveBack != null:
return moveBack();case LivenessInstructionCenterFace() when centerFace != null:
return centerFace();case LivenessInstructionHoldStill() when holdStill != null:
return holdStill();case LivenessInstructionLookAtCamera() when lookAtCamera != null:
return lookAtCamera();case LivenessInstructionImproveLighting() when improveLighting != null:
return improveLighting();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  moveCloser,required TResult Function()  moveBack,required TResult Function()  centerFace,required TResult Function()  holdStill,required TResult Function()  lookAtCamera,required TResult Function()  improveLighting,}) {final _that = this;
switch (_that) {
case LivenessInstructionMoveCloser():
return moveCloser();case LivenessInstructionMoveBack():
return moveBack();case LivenessInstructionCenterFace():
return centerFace();case LivenessInstructionHoldStill():
return holdStill();case LivenessInstructionLookAtCamera():
return lookAtCamera();case LivenessInstructionImproveLighting():
return improveLighting();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  moveCloser,TResult? Function()?  moveBack,TResult? Function()?  centerFace,TResult? Function()?  holdStill,TResult? Function()?  lookAtCamera,TResult? Function()?  improveLighting,}) {final _that = this;
switch (_that) {
case LivenessInstructionMoveCloser() when moveCloser != null:
return moveCloser();case LivenessInstructionMoveBack() when moveBack != null:
return moveBack();case LivenessInstructionCenterFace() when centerFace != null:
return centerFace();case LivenessInstructionHoldStill() when holdStill != null:
return holdStill();case LivenessInstructionLookAtCamera() when lookAtCamera != null:
return lookAtCamera();case LivenessInstructionImproveLighting() when improveLighting != null:
return improveLighting();case _:
  return null;

}
}

}

/// @nodoc


class LivenessInstructionMoveCloser implements LivenessInstruction {
  const LivenessInstructionMoveCloser();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LivenessInstructionMoveCloser);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'LivenessInstruction.moveCloser()';
}


}




/// @nodoc


class LivenessInstructionMoveBack implements LivenessInstruction {
  const LivenessInstructionMoveBack();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LivenessInstructionMoveBack);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'LivenessInstruction.moveBack()';
}


}




/// @nodoc


class LivenessInstructionCenterFace implements LivenessInstruction {
  const LivenessInstructionCenterFace();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LivenessInstructionCenterFace);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'LivenessInstruction.centerFace()';
}


}




/// @nodoc


class LivenessInstructionHoldStill implements LivenessInstruction {
  const LivenessInstructionHoldStill();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LivenessInstructionHoldStill);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'LivenessInstruction.holdStill()';
}


}




/// @nodoc


class LivenessInstructionLookAtCamera implements LivenessInstruction {
  const LivenessInstructionLookAtCamera();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LivenessInstructionLookAtCamera);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'LivenessInstruction.lookAtCamera()';
}


}




/// @nodoc


class LivenessInstructionImproveLighting implements LivenessInstruction {
  const LivenessInstructionImproveLighting();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LivenessInstructionImproveLighting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'LivenessInstruction.improveLighting()';
}


}




/// @nodoc
mixin _$LivenessPhase {

/// 0-based, ordinal within this attempt.
 int get index;/// As reported for this attempt — the phase indicator's dot count.
 int get totalPhases; LivenessInstruction get instruction;
/// Create a copy of LivenessPhase
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LivenessPhaseCopyWith<LivenessPhase> get copyWith => _$LivenessPhaseCopyWithImpl<LivenessPhase>(this as LivenessPhase, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LivenessPhase;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LivenessPhase&&(identical(other.index, _this.index) || other.index == _this.index)&&(identical(other.totalPhases, _this.totalPhases) || other.totalPhases == _this.totalPhases)&&(identical(other.instruction, _this.instruction) || other.instruction == _this.instruction));
}


@override
int get hashCode {
  final _this = this as LivenessPhase;
  return Object.hash(runtimeType,_this.index,_this.totalPhases,_this.instruction);
}

@override
String toString() {
  final _this = this as LivenessPhase;
  return 'LivenessPhase(index: ${_this.index}, totalPhases: ${_this.totalPhases}, instruction: ${_this.instruction})';
}


}

/// @nodoc
abstract mixin class $LivenessPhaseCopyWith<$Res>  {
  factory $LivenessPhaseCopyWith(LivenessPhase value, $Res Function(LivenessPhase) _then) = _$LivenessPhaseCopyWithImpl;
@useResult
$Res call({
 int index, int totalPhases, LivenessInstruction instruction
});


$LivenessInstructionCopyWith<$Res> get instruction;

}
/// @nodoc
class _$LivenessPhaseCopyWithImpl<$Res>
    implements $LivenessPhaseCopyWith<$Res> {
  _$LivenessPhaseCopyWithImpl(this._self, this._then);

  final LivenessPhase _self;
  final $Res Function(LivenessPhase) _then;

/// Create a copy of LivenessPhase
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? index = null,Object? totalPhases = null,Object? instruction = null,}) {
  return _then(LivenessPhase(
index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,totalPhases: null == totalPhases ? _self.totalPhases : totalPhases // ignore: cast_nullable_to_non_nullable
as int,instruction: null == instruction ? _self.instruction : instruction // ignore: cast_nullable_to_non_nullable
as LivenessInstruction,
  ));
}
/// Create a copy of LivenessPhase
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LivenessInstructionCopyWith<$Res> get instruction {
  
  return $LivenessInstructionCopyWith<$Res>(_self.instruction, (value) {
    return _then(_self.copyWith(instruction: value));
  });
}
}


/// Adds pattern-matching-related methods to [LivenessPhase].
extension LivenessPhasePatterns on LivenessPhase {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LivenessPhase value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LivenessPhase() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LivenessPhase value)  $default,){
final _that = this;
switch (_that) {
case _LivenessPhase():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LivenessPhase value)?  $default,){
final _that = this;
switch (_that) {
case _LivenessPhase() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int index,  int totalPhases,  LivenessInstruction instruction)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LivenessPhase() when $default != null:
return $default(_that.index,_that.totalPhases,_that.instruction);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int index,  int totalPhases,  LivenessInstruction instruction)  $default,) {final _that = this;
switch (_that) {
case _LivenessPhase():
return $default(_that.index,_that.totalPhases,_that.instruction);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int index,  int totalPhases,  LivenessInstruction instruction)?  $default,) {final _that = this;
switch (_that) {
case _LivenessPhase() when $default != null:
return $default(_that.index,_that.totalPhases,_that.instruction);case _:
  return null;

}
}

}

/// @nodoc


class _LivenessPhase implements LivenessPhase {
  const _LivenessPhase({required this.index, required this.totalPhases, required this.instruction});
  

/// 0-based, ordinal within this attempt.
@override final  int index;
/// As reported for this attempt — the phase indicator's dot count.
@override final  int totalPhases;
@override final  LivenessInstruction instruction;

/// Create a copy of LivenessPhase
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LivenessPhaseCopyWith<_LivenessPhase> get copyWith => __$LivenessPhaseCopyWithImpl<_LivenessPhase>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LivenessPhase&&(identical(other.index, index) || other.index == index)&&(identical(other.totalPhases, totalPhases) || other.totalPhases == totalPhases)&&(identical(other.instruction, instruction) || other.instruction == instruction));
}


@override
int get hashCode {
    return Object.hash(runtimeType,index,totalPhases,instruction);
}

@override
String toString() {
    return 'LivenessPhase(index: $index, totalPhases: $totalPhases, instruction: $instruction)';
}


}

/// @nodoc
abstract mixin class _$LivenessPhaseCopyWith<$Res> implements $LivenessPhaseCopyWith<$Res> {
  factory _$LivenessPhaseCopyWith(_LivenessPhase value, $Res Function(_LivenessPhase) _then) = __$LivenessPhaseCopyWithImpl;
@override @useResult
$Res call({
 int index, int totalPhases, LivenessInstruction instruction
});


@override $LivenessInstructionCopyWith<$Res> get instruction;

}
/// @nodoc
class __$LivenessPhaseCopyWithImpl<$Res>
    implements _$LivenessPhaseCopyWith<$Res> {
  __$LivenessPhaseCopyWithImpl(this._self, this._then);

  final _LivenessPhase _self;
  final $Res Function(_LivenessPhase) _then;

/// Create a copy of LivenessPhase
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? index = null,Object? totalPhases = null,Object? instruction = null,}) {
  return _then(_LivenessPhase(
index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,totalPhases: null == totalPhases ? _self.totalPhases : totalPhases // ignore: cast_nullable_to_non_nullable
as int,instruction: null == instruction ? _self.instruction : instruction // ignore: cast_nullable_to_non_nullable
as LivenessInstruction,
  ));
}

/// Create a copy of LivenessPhase
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LivenessInstructionCopyWith<$Res> get instruction {
  
  return $LivenessInstructionCopyWith<$Res>(_self.instruction, (value) {
    return _then(_self.copyWith(instruction: value));
  });
}
}

// dart format on
