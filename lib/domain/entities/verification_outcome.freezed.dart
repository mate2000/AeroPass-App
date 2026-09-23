// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verification_outcome.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VerificationOutcome {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is VerificationOutcome);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'VerificationOutcome()';
}


}

/// @nodoc
class $VerificationOutcomeCopyWith<$Res>  {
$VerificationOutcomeCopyWith(VerificationOutcome _, $Res Function(VerificationOutcome) __);
}


/// Adds pattern-matching-related methods to [VerificationOutcome].
extension VerificationOutcomePatterns on VerificationOutcome {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( VerificationMatched value)?  matched,TResult Function( VerificationDocumentRejected value)?  documentRejected,TResult Function( VerificationFaceMismatch value)?  faceMismatch,TResult Function( VerificationLivenessRejected value)?  livenessRejected,TResult Function( VerificationAttackDetected value)?  attackDetected,TResult Function( VerificationServiceFailure value)?  serviceFailure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case VerificationMatched() when matched != null:
return matched(_that);case VerificationDocumentRejected() when documentRejected != null:
return documentRejected(_that);case VerificationFaceMismatch() when faceMismatch != null:
return faceMismatch(_that);case VerificationLivenessRejected() when livenessRejected != null:
return livenessRejected(_that);case VerificationAttackDetected() when attackDetected != null:
return attackDetected(_that);case VerificationServiceFailure() when serviceFailure != null:
return serviceFailure(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( VerificationMatched value)  matched,required TResult Function( VerificationDocumentRejected value)  documentRejected,required TResult Function( VerificationFaceMismatch value)  faceMismatch,required TResult Function( VerificationLivenessRejected value)  livenessRejected,required TResult Function( VerificationAttackDetected value)  attackDetected,required TResult Function( VerificationServiceFailure value)  serviceFailure,}){
final _that = this;
switch (_that) {
case VerificationMatched():
return matched(_that);case VerificationDocumentRejected():
return documentRejected(_that);case VerificationFaceMismatch():
return faceMismatch(_that);case VerificationLivenessRejected():
return livenessRejected(_that);case VerificationAttackDetected():
return attackDetected(_that);case VerificationServiceFailure():
return serviceFailure(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( VerificationMatched value)?  matched,TResult? Function( VerificationDocumentRejected value)?  documentRejected,TResult? Function( VerificationFaceMismatch value)?  faceMismatch,TResult? Function( VerificationLivenessRejected value)?  livenessRejected,TResult? Function( VerificationAttackDetected value)?  attackDetected,TResult? Function( VerificationServiceFailure value)?  serviceFailure,}){
final _that = this;
switch (_that) {
case VerificationMatched() when matched != null:
return matched(_that);case VerificationDocumentRejected() when documentRejected != null:
return documentRejected(_that);case VerificationFaceMismatch() when faceMismatch != null:
return faceMismatch(_that);case VerificationLivenessRejected() when livenessRejected != null:
return livenessRejected(_that);case VerificationAttackDetected() when attackDetected != null:
return attackDetected(_that);case VerificationServiceFailure() when serviceFailure != null:
return serviceFailure(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  matched,TResult Function()?  documentRejected,TResult Function()?  faceMismatch,TResult Function()?  livenessRejected,TResult Function()?  attackDetected,TResult Function()?  serviceFailure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case VerificationMatched() when matched != null:
return matched();case VerificationDocumentRejected() when documentRejected != null:
return documentRejected();case VerificationFaceMismatch() when faceMismatch != null:
return faceMismatch();case VerificationLivenessRejected() when livenessRejected != null:
return livenessRejected();case VerificationAttackDetected() when attackDetected != null:
return attackDetected();case VerificationServiceFailure() when serviceFailure != null:
return serviceFailure();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  matched,required TResult Function()  documentRejected,required TResult Function()  faceMismatch,required TResult Function()  livenessRejected,required TResult Function()  attackDetected,required TResult Function()  serviceFailure,}) {final _that = this;
switch (_that) {
case VerificationMatched():
return matched();case VerificationDocumentRejected():
return documentRejected();case VerificationFaceMismatch():
return faceMismatch();case VerificationLivenessRejected():
return livenessRejected();case VerificationAttackDetected():
return attackDetected();case VerificationServiceFailure():
return serviceFailure();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  matched,TResult? Function()?  documentRejected,TResult? Function()?  faceMismatch,TResult? Function()?  livenessRejected,TResult? Function()?  attackDetected,TResult? Function()?  serviceFailure,}) {final _that = this;
switch (_that) {
case VerificationMatched() when matched != null:
return matched();case VerificationDocumentRejected() when documentRejected != null:
return documentRejected();case VerificationFaceMismatch() when faceMismatch != null:
return faceMismatch();case VerificationLivenessRejected() when livenessRejected != null:
return livenessRejected();case VerificationAttackDetected() when attackDetected != null:
return attackDetected();case VerificationServiceFailure() when serviceFailure != null:
return serviceFailure();case _:
  return null;

}
}

}

/// @nodoc


class VerificationMatched implements VerificationOutcome {
  const VerificationMatched();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is VerificationMatched);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'VerificationOutcome.matched()';
}


}




/// @nodoc


class VerificationDocumentRejected implements VerificationOutcome {
  const VerificationDocumentRejected();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is VerificationDocumentRejected);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'VerificationOutcome.documentRejected()';
}


}




/// @nodoc


class VerificationFaceMismatch implements VerificationOutcome {
  const VerificationFaceMismatch();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is VerificationFaceMismatch);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'VerificationOutcome.faceMismatch()';
}


}




/// @nodoc


class VerificationLivenessRejected implements VerificationOutcome {
  const VerificationLivenessRejected();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is VerificationLivenessRejected);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'VerificationOutcome.livenessRejected()';
}


}




/// @nodoc


class VerificationAttackDetected implements VerificationOutcome {
  const VerificationAttackDetected();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is VerificationAttackDetected);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'VerificationOutcome.attackDetected()';
}


}




/// @nodoc


class VerificationServiceFailure implements VerificationOutcome {
  const VerificationServiceFailure();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is VerificationServiceFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'VerificationOutcome.serviceFailure()';
}


}




// dart format on
