// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'capture_outcome.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$QualityAssessment {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is QualityAssessment);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'QualityAssessment()';
}


}

/// @nodoc
class $QualityAssessmentCopyWith<$Res>  {
$QualityAssessmentCopyWith(QualityAssessment _, $Res Function(QualityAssessment) __);
}


/// Adds pattern-matching-related methods to [QualityAssessment].
extension QualityAssessmentPatterns on QualityAssessment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( QualityAssessmentUsable value)?  usable,TResult Function( QualityAssessmentRejected value)?  rejected,required TResult orElse(),}){
final _that = this;
switch (_that) {
case QualityAssessmentUsable() when usable != null:
return usable(_that);case QualityAssessmentRejected() when rejected != null:
return rejected(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( QualityAssessmentUsable value)  usable,required TResult Function( QualityAssessmentRejected value)  rejected,}){
final _that = this;
switch (_that) {
case QualityAssessmentUsable():
return usable(_that);case QualityAssessmentRejected():
return rejected(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( QualityAssessmentUsable value)?  usable,TResult? Function( QualityAssessmentRejected value)?  rejected,}){
final _that = this;
switch (_that) {
case QualityAssessmentUsable() when usable != null:
return usable(_that);case QualityAssessmentRejected() when rejected != null:
return rejected(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  usable,TResult Function( QualityRejectionReason reason)?  rejected,required TResult orElse(),}) {final _that = this;
switch (_that) {
case QualityAssessmentUsable() when usable != null:
return usable();case QualityAssessmentRejected() when rejected != null:
return rejected(_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  usable,required TResult Function( QualityRejectionReason reason)  rejected,}) {final _that = this;
switch (_that) {
case QualityAssessmentUsable():
return usable();case QualityAssessmentRejected():
return rejected(_that.reason);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  usable,TResult? Function( QualityRejectionReason reason)?  rejected,}) {final _that = this;
switch (_that) {
case QualityAssessmentUsable() when usable != null:
return usable();case QualityAssessmentRejected() when rejected != null:
return rejected(_that.reason);case _:
  return null;

}
}

}

/// @nodoc


class QualityAssessmentUsable implements QualityAssessment {
  const QualityAssessmentUsable();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is QualityAssessmentUsable);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'QualityAssessment.usable()';
}


}




/// @nodoc


class QualityAssessmentRejected implements QualityAssessment {
  const QualityAssessmentRejected({required this.reason});
  

 final  QualityRejectionReason reason;

/// Create a copy of QualityAssessment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QualityAssessmentRejectedCopyWith<QualityAssessmentRejected> get copyWith => _$QualityAssessmentRejectedCopyWithImpl<QualityAssessmentRejected>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is QualityAssessmentRejected&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode {
    return Object.hash(runtimeType,reason);
}

@override
String toString() {
    return 'QualityAssessment.rejected(reason: $reason)';
}


}

/// @nodoc
abstract mixin class $QualityAssessmentRejectedCopyWith<$Res> implements $QualityAssessmentCopyWith<$Res> {
  factory $QualityAssessmentRejectedCopyWith(QualityAssessmentRejected value, $Res Function(QualityAssessmentRejected) _then) = _$QualityAssessmentRejectedCopyWithImpl;
@useResult
$Res call({
 QualityRejectionReason reason
});




}
/// @nodoc
class _$QualityAssessmentRejectedCopyWithImpl<$Res>
    implements $QualityAssessmentRejectedCopyWith<$Res> {
  _$QualityAssessmentRejectedCopyWithImpl(this._self, this._then);

  final QualityAssessmentRejected _self;
  final $Res Function(QualityAssessmentRejected) _then;

/// Create a copy of QualityAssessment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reason = null,}) {
  return _then(QualityAssessmentRejected(
reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as QualityRejectionReason,
  ));
}


}

/// @nodoc
mixin _$CaptureOutcome {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CaptureOutcome);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'CaptureOutcome()';
}


}

/// @nodoc
class $CaptureOutcomeCopyWith<$Res>  {
$CaptureOutcomeCopyWith(CaptureOutcome _, $Res Function(CaptureOutcome) __);
}


/// Adds pattern-matching-related methods to [CaptureOutcome].
extension CaptureOutcomePatterns on CaptureOutcome {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CaptureOutcomeAccepted value)?  accepted,TResult Function( CaptureOutcomeRejected value)?  rejected,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CaptureOutcomeAccepted() when accepted != null:
return accepted(_that);case CaptureOutcomeRejected() when rejected != null:
return rejected(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CaptureOutcomeAccepted value)  accepted,required TResult Function( CaptureOutcomeRejected value)  rejected,}){
final _that = this;
switch (_that) {
case CaptureOutcomeAccepted():
return accepted(_that);case CaptureOutcomeRejected():
return rejected(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CaptureOutcomeAccepted value)?  accepted,TResult? Function( CaptureOutcomeRejected value)?  rejected,}){
final _that = this;
switch (_that) {
case CaptureOutcomeAccepted() when accepted != null:
return accepted(_that);case CaptureOutcomeRejected() when rejected != null:
return rejected(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  accepted,TResult Function( CaptureRejectionReason reason)?  rejected,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CaptureOutcomeAccepted() when accepted != null:
return accepted();case CaptureOutcomeRejected() when rejected != null:
return rejected(_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  accepted,required TResult Function( CaptureRejectionReason reason)  rejected,}) {final _that = this;
switch (_that) {
case CaptureOutcomeAccepted():
return accepted();case CaptureOutcomeRejected():
return rejected(_that.reason);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  accepted,TResult? Function( CaptureRejectionReason reason)?  rejected,}) {final _that = this;
switch (_that) {
case CaptureOutcomeAccepted() when accepted != null:
return accepted();case CaptureOutcomeRejected() when rejected != null:
return rejected(_that.reason);case _:
  return null;

}
}

}

/// @nodoc


class CaptureOutcomeAccepted implements CaptureOutcome {
  const CaptureOutcomeAccepted();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CaptureOutcomeAccepted);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'CaptureOutcome.accepted()';
}


}




/// @nodoc


class CaptureOutcomeRejected implements CaptureOutcome {
  const CaptureOutcomeRejected({required this.reason});
  

 final  CaptureRejectionReason reason;

/// Create a copy of CaptureOutcome
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CaptureOutcomeRejectedCopyWith<CaptureOutcomeRejected> get copyWith => _$CaptureOutcomeRejectedCopyWithImpl<CaptureOutcomeRejected>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CaptureOutcomeRejected&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode {
    return Object.hash(runtimeType,reason);
}

@override
String toString() {
    return 'CaptureOutcome.rejected(reason: $reason)';
}


}

/// @nodoc
abstract mixin class $CaptureOutcomeRejectedCopyWith<$Res> implements $CaptureOutcomeCopyWith<$Res> {
  factory $CaptureOutcomeRejectedCopyWith(CaptureOutcomeRejected value, $Res Function(CaptureOutcomeRejected) _then) = _$CaptureOutcomeRejectedCopyWithImpl;
@useResult
$Res call({
 CaptureRejectionReason reason
});




}
/// @nodoc
class _$CaptureOutcomeRejectedCopyWithImpl<$Res>
    implements $CaptureOutcomeRejectedCopyWith<$Res> {
  _$CaptureOutcomeRejectedCopyWithImpl(this._self, this._then);

  final CaptureOutcomeRejected _self;
  final $Res Function(CaptureOutcomeRejected) _then;

/// Create a copy of CaptureOutcome
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reason = null,}) {
  return _then(CaptureOutcomeRejected(
reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as CaptureRejectionReason,
  ));
}


}

// dart format on
