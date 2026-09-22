// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'field_reverification_outcome.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FieldReverificationOutcome {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FieldReverificationOutcome);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'FieldReverificationOutcome()';
}


}

/// @nodoc
class $FieldReverificationOutcomeCopyWith<$Res>  {
$FieldReverificationOutcomeCopyWith(FieldReverificationOutcome _, $Res Function(FieldReverificationOutcome) __);
}


/// Adds pattern-matching-related methods to [FieldReverificationOutcome].
extension FieldReverificationOutcomePatterns on FieldReverificationOutcome {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( FieldReverificationOutcomeConfirmed value)?  confirmed,TResult Function( FieldReverificationOutcomeDisagreed value)?  disagreed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case FieldReverificationOutcomeConfirmed() when confirmed != null:
return confirmed(_that);case FieldReverificationOutcomeDisagreed() when disagreed != null:
return disagreed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( FieldReverificationOutcomeConfirmed value)  confirmed,required TResult Function( FieldReverificationOutcomeDisagreed value)  disagreed,}){
final _that = this;
switch (_that) {
case FieldReverificationOutcomeConfirmed():
return confirmed(_that);case FieldReverificationOutcomeDisagreed():
return disagreed(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( FieldReverificationOutcomeConfirmed value)?  confirmed,TResult? Function( FieldReverificationOutcomeDisagreed value)?  disagreed,}){
final _that = this;
switch (_that) {
case FieldReverificationOutcomeConfirmed() when confirmed != null:
return confirmed(_that);case FieldReverificationOutcomeDisagreed() when disagreed != null:
return disagreed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  confirmed,TResult Function()?  disagreed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case FieldReverificationOutcomeConfirmed() when confirmed != null:
return confirmed();case FieldReverificationOutcomeDisagreed() when disagreed != null:
return disagreed();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  confirmed,required TResult Function()  disagreed,}) {final _that = this;
switch (_that) {
case FieldReverificationOutcomeConfirmed():
return confirmed();case FieldReverificationOutcomeDisagreed():
return disagreed();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  confirmed,TResult? Function()?  disagreed,}) {final _that = this;
switch (_that) {
case FieldReverificationOutcomeConfirmed() when confirmed != null:
return confirmed();case FieldReverificationOutcomeDisagreed() when disagreed != null:
return disagreed();case _:
  return null;

}
}

}

/// @nodoc


class FieldReverificationOutcomeConfirmed implements FieldReverificationOutcome {
  const FieldReverificationOutcomeConfirmed();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FieldReverificationOutcomeConfirmed);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'FieldReverificationOutcome.confirmed()';
}


}




/// @nodoc


class FieldReverificationOutcomeDisagreed implements FieldReverificationOutcome {
  const FieldReverificationOutcomeDisagreed();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FieldReverificationOutcomeDisagreed);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'FieldReverificationOutcome.disagreed()';
}


}




// dart format on
