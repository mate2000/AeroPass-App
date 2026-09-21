// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'consent_view_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ConsentViewState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ConsentViewState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ConsentViewState()';
}


}

/// @nodoc
class $ConsentViewStateCopyWith<$Res>  {
$ConsentViewStateCopyWith(ConsentViewState _, $Res Function(ConsentViewState) __);
}


/// Adds pattern-matching-related methods to [ConsentViewState].
extension ConsentViewStatePatterns on ConsentViewState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ConsentViewLoading value)?  loading,TResult Function( ConsentViewUnavailable value)?  unavailable,TResult Function( ConsentViewReady value)?  ready,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ConsentViewLoading() when loading != null:
return loading(_that);case ConsentViewUnavailable() when unavailable != null:
return unavailable(_that);case ConsentViewReady() when ready != null:
return ready(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ConsentViewLoading value)  loading,required TResult Function( ConsentViewUnavailable value)  unavailable,required TResult Function( ConsentViewReady value)  ready,}){
final _that = this;
switch (_that) {
case ConsentViewLoading():
return loading(_that);case ConsentViewUnavailable():
return unavailable(_that);case ConsentViewReady():
return ready(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ConsentViewLoading value)?  loading,TResult? Function( ConsentViewUnavailable value)?  unavailable,TResult? Function( ConsentViewReady value)?  ready,}){
final _that = this;
switch (_that) {
case ConsentViewLoading() when loading != null:
return loading(_that);case ConsentViewUnavailable() when unavailable != null:
return unavailable(_that);case ConsentViewReady() when ready != null:
return ready(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( UnavailableReason reason)?  unavailable,TResult Function( ConsentTextVersion text,  bool checkboxChecked,  bool hasPriorRecord)?  ready,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ConsentViewLoading() when loading != null:
return loading();case ConsentViewUnavailable() when unavailable != null:
return unavailable(_that.reason);case ConsentViewReady() when ready != null:
return ready(_that.text,_that.checkboxChecked,_that.hasPriorRecord);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( UnavailableReason reason)  unavailable,required TResult Function( ConsentTextVersion text,  bool checkboxChecked,  bool hasPriorRecord)  ready,}) {final _that = this;
switch (_that) {
case ConsentViewLoading():
return loading();case ConsentViewUnavailable():
return unavailable(_that.reason);case ConsentViewReady():
return ready(_that.text,_that.checkboxChecked,_that.hasPriorRecord);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( UnavailableReason reason)?  unavailable,TResult? Function( ConsentTextVersion text,  bool checkboxChecked,  bool hasPriorRecord)?  ready,}) {final _that = this;
switch (_that) {
case ConsentViewLoading() when loading != null:
return loading();case ConsentViewUnavailable() when unavailable != null:
return unavailable(_that.reason);case ConsentViewReady() when ready != null:
return ready(_that.text,_that.checkboxChecked,_that.hasPriorRecord);case _:
  return null;

}
}

}

/// @nodoc


class ConsentViewLoading implements ConsentViewState {
  const ConsentViewLoading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ConsentViewLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ConsentViewState.loading()';
}


}




/// @nodoc


class ConsentViewUnavailable implements ConsentViewState {
  const ConsentViewUnavailable({required this.reason});
  

 final  UnavailableReason reason;

/// Create a copy of ConsentViewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConsentViewUnavailableCopyWith<ConsentViewUnavailable> get copyWith => _$ConsentViewUnavailableCopyWithImpl<ConsentViewUnavailable>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ConsentViewUnavailable&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode {
    return Object.hash(runtimeType,reason);
}

@override
String toString() {
    return 'ConsentViewState.unavailable(reason: $reason)';
}


}

/// @nodoc
abstract mixin class $ConsentViewUnavailableCopyWith<$Res> implements $ConsentViewStateCopyWith<$Res> {
  factory $ConsentViewUnavailableCopyWith(ConsentViewUnavailable value, $Res Function(ConsentViewUnavailable) _then) = _$ConsentViewUnavailableCopyWithImpl;
@useResult
$Res call({
 UnavailableReason reason
});




}
/// @nodoc
class _$ConsentViewUnavailableCopyWithImpl<$Res>
    implements $ConsentViewUnavailableCopyWith<$Res> {
  _$ConsentViewUnavailableCopyWithImpl(this._self, this._then);

  final ConsentViewUnavailable _self;
  final $Res Function(ConsentViewUnavailable) _then;

/// Create a copy of ConsentViewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reason = null,}) {
  return _then(ConsentViewUnavailable(
reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as UnavailableReason,
  ));
}


}

/// @nodoc


class ConsentViewReady implements ConsentViewState {
  const ConsentViewReady({required this.text, this.checkboxChecked = false, this.hasPriorRecord = false});
  

 final  ConsentTextVersion text;
@JsonKey() final  bool checkboxChecked;
/// FR-014: true when a local `ConsentRecord` exists for a version
/// other than [text]'s own `id` — the gate is being re-presented
/// because the terms changed, not shown for the first time.
@JsonKey() final  bool hasPriorRecord;

/// Create a copy of ConsentViewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConsentViewReadyCopyWith<ConsentViewReady> get copyWith => _$ConsentViewReadyCopyWithImpl<ConsentViewReady>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ConsentViewReady&&(identical(other.text, text) || other.text == text)&&(identical(other.checkboxChecked, checkboxChecked) || other.checkboxChecked == checkboxChecked)&&(identical(other.hasPriorRecord, hasPriorRecord) || other.hasPriorRecord == hasPriorRecord));
}


@override
int get hashCode {
    return Object.hash(runtimeType,text,checkboxChecked,hasPriorRecord);
}

@override
String toString() {
    return 'ConsentViewState.ready(text: $text, checkboxChecked: $checkboxChecked, hasPriorRecord: $hasPriorRecord)';
}


}

/// @nodoc
abstract mixin class $ConsentViewReadyCopyWith<$Res> implements $ConsentViewStateCopyWith<$Res> {
  factory $ConsentViewReadyCopyWith(ConsentViewReady value, $Res Function(ConsentViewReady) _then) = _$ConsentViewReadyCopyWithImpl;
@useResult
$Res call({
 ConsentTextVersion text, bool checkboxChecked, bool hasPriorRecord
});


$ConsentTextVersionCopyWith<$Res> get text;

}
/// @nodoc
class _$ConsentViewReadyCopyWithImpl<$Res>
    implements $ConsentViewReadyCopyWith<$Res> {
  _$ConsentViewReadyCopyWithImpl(this._self, this._then);

  final ConsentViewReady _self;
  final $Res Function(ConsentViewReady) _then;

/// Create a copy of ConsentViewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? text = null,Object? checkboxChecked = null,Object? hasPriorRecord = null,}) {
  return _then(ConsentViewReady(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as ConsentTextVersion,checkboxChecked: null == checkboxChecked ? _self.checkboxChecked : checkboxChecked // ignore: cast_nullable_to_non_nullable
as bool,hasPriorRecord: null == hasPriorRecord ? _self.hasPriorRecord : hasPriorRecord // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of ConsentViewState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConsentTextVersionCopyWith<$Res> get text {
  
  return $ConsentTextVersionCopyWith<$Res>(_self.text, (value) {
    return _then(_self.copyWith(text: value));
  });
}
}

// dart format on
