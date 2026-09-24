// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_confirmation_view_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FieldCorrectionStatus {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FieldCorrectionStatus);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'FieldCorrectionStatus()';
}


}

/// @nodoc
class $FieldCorrectionStatusCopyWith<$Res>  {
$FieldCorrectionStatusCopyWith(FieldCorrectionStatus _, $Res Function(FieldCorrectionStatus) __);
}


/// Adds pattern-matching-related methods to [FieldCorrectionStatus].
extension FieldCorrectionStatusPatterns on FieldCorrectionStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( FieldCorrectionUnedited value)?  unedited,TResult Function( FieldCorrectionInvalidFormat value)?  invalidFormat,TResult Function( FieldCorrectionAcceptedLowConfidence value)?  acceptedLowConfidence,TResult Function( FieldCorrectionReverifying value)?  reverifying,TResult Function( FieldCorrectionAcceptedReverified value)?  acceptedReverified,TResult Function( FieldCorrectionUnresolved value)?  unresolved,required TResult orElse(),}){
final _that = this;
switch (_that) {
case FieldCorrectionUnedited() when unedited != null:
return unedited(_that);case FieldCorrectionInvalidFormat() when invalidFormat != null:
return invalidFormat(_that);case FieldCorrectionAcceptedLowConfidence() when acceptedLowConfidence != null:
return acceptedLowConfidence(_that);case FieldCorrectionReverifying() when reverifying != null:
return reverifying(_that);case FieldCorrectionAcceptedReverified() when acceptedReverified != null:
return acceptedReverified(_that);case FieldCorrectionUnresolved() when unresolved != null:
return unresolved(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( FieldCorrectionUnedited value)  unedited,required TResult Function( FieldCorrectionInvalidFormat value)  invalidFormat,required TResult Function( FieldCorrectionAcceptedLowConfidence value)  acceptedLowConfidence,required TResult Function( FieldCorrectionReverifying value)  reverifying,required TResult Function( FieldCorrectionAcceptedReverified value)  acceptedReverified,required TResult Function( FieldCorrectionUnresolved value)  unresolved,}){
final _that = this;
switch (_that) {
case FieldCorrectionUnedited():
return unedited(_that);case FieldCorrectionInvalidFormat():
return invalidFormat(_that);case FieldCorrectionAcceptedLowConfidence():
return acceptedLowConfidence(_that);case FieldCorrectionReverifying():
return reverifying(_that);case FieldCorrectionAcceptedReverified():
return acceptedReverified(_that);case FieldCorrectionUnresolved():
return unresolved(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( FieldCorrectionUnedited value)?  unedited,TResult? Function( FieldCorrectionInvalidFormat value)?  invalidFormat,TResult? Function( FieldCorrectionAcceptedLowConfidence value)?  acceptedLowConfidence,TResult? Function( FieldCorrectionReverifying value)?  reverifying,TResult? Function( FieldCorrectionAcceptedReverified value)?  acceptedReverified,TResult? Function( FieldCorrectionUnresolved value)?  unresolved,}){
final _that = this;
switch (_that) {
case FieldCorrectionUnedited() when unedited != null:
return unedited(_that);case FieldCorrectionInvalidFormat() when invalidFormat != null:
return invalidFormat(_that);case FieldCorrectionAcceptedLowConfidence() when acceptedLowConfidence != null:
return acceptedLowConfidence(_that);case FieldCorrectionReverifying() when reverifying != null:
return reverifying(_that);case FieldCorrectionAcceptedReverified() when acceptedReverified != null:
return acceptedReverified(_that);case FieldCorrectionUnresolved() when unresolved != null:
return unresolved(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  unedited,TResult Function()?  invalidFormat,TResult Function()?  acceptedLowConfidence,TResult Function()?  reverifying,TResult Function()?  acceptedReverified,TResult Function()?  unresolved,required TResult orElse(),}) {final _that = this;
switch (_that) {
case FieldCorrectionUnedited() when unedited != null:
return unedited();case FieldCorrectionInvalidFormat() when invalidFormat != null:
return invalidFormat();case FieldCorrectionAcceptedLowConfidence() when acceptedLowConfidence != null:
return acceptedLowConfidence();case FieldCorrectionReverifying() when reverifying != null:
return reverifying();case FieldCorrectionAcceptedReverified() when acceptedReverified != null:
return acceptedReverified();case FieldCorrectionUnresolved() when unresolved != null:
return unresolved();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  unedited,required TResult Function()  invalidFormat,required TResult Function()  acceptedLowConfidence,required TResult Function()  reverifying,required TResult Function()  acceptedReverified,required TResult Function()  unresolved,}) {final _that = this;
switch (_that) {
case FieldCorrectionUnedited():
return unedited();case FieldCorrectionInvalidFormat():
return invalidFormat();case FieldCorrectionAcceptedLowConfidence():
return acceptedLowConfidence();case FieldCorrectionReverifying():
return reverifying();case FieldCorrectionAcceptedReverified():
return acceptedReverified();case FieldCorrectionUnresolved():
return unresolved();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  unedited,TResult? Function()?  invalidFormat,TResult? Function()?  acceptedLowConfidence,TResult? Function()?  reverifying,TResult? Function()?  acceptedReverified,TResult? Function()?  unresolved,}) {final _that = this;
switch (_that) {
case FieldCorrectionUnedited() when unedited != null:
return unedited();case FieldCorrectionInvalidFormat() when invalidFormat != null:
return invalidFormat();case FieldCorrectionAcceptedLowConfidence() when acceptedLowConfidence != null:
return acceptedLowConfidence();case FieldCorrectionReverifying() when reverifying != null:
return reverifying();case FieldCorrectionAcceptedReverified() when acceptedReverified != null:
return acceptedReverified();case FieldCorrectionUnresolved() when unresolved != null:
return unresolved();case _:
  return null;

}
}

}

/// @nodoc


class FieldCorrectionUnedited implements FieldCorrectionStatus {
  const FieldCorrectionUnedited();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FieldCorrectionUnedited);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'FieldCorrectionStatus.unedited()';
}


}




/// @nodoc


class FieldCorrectionInvalidFormat implements FieldCorrectionStatus {
  const FieldCorrectionInvalidFormat();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FieldCorrectionInvalidFormat);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'FieldCorrectionStatus.invalidFormat()';
}


}




/// @nodoc


class FieldCorrectionAcceptedLowConfidence implements FieldCorrectionStatus {
  const FieldCorrectionAcceptedLowConfidence();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FieldCorrectionAcceptedLowConfidence);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'FieldCorrectionStatus.acceptedLowConfidence()';
}


}




/// @nodoc


class FieldCorrectionReverifying implements FieldCorrectionStatus {
  const FieldCorrectionReverifying();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FieldCorrectionReverifying);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'FieldCorrectionStatus.reverifying()';
}


}




/// @nodoc


class FieldCorrectionAcceptedReverified implements FieldCorrectionStatus {
  const FieldCorrectionAcceptedReverified();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FieldCorrectionAcceptedReverified);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'FieldCorrectionStatus.acceptedReverified()';
}


}




/// @nodoc


class FieldCorrectionUnresolved implements FieldCorrectionStatus {
  const FieldCorrectionUnresolved();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FieldCorrectionUnresolved);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'FieldCorrectionStatus.unresolved()';
}


}




/// @nodoc
mixin _$FieldRowState {

 FieldKey get key;/// The field's current value — original or edited. The raw/canonical
/// form (ISO-8601 for `expiryDate`); the view formats it for display.
 String get currentValue;/// The machine-extracted value, before any edit. A `ready` state is
/// only ever reached once every field has been confirmed present — a
/// missing field blocks the whole screen instead (FR-009,
/// `DocumentConfirmationViewBlocked`) — so this is never null here.
 String get originalValue;/// The processor's confidence for the original value.
 double get originalConfidence; FieldCorrectionStatus get status;
/// Create a copy of FieldRowState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FieldRowStateCopyWith<FieldRowState> get copyWith => _$FieldRowStateCopyWithImpl<FieldRowState>(this as FieldRowState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FieldRowState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FieldRowState&&(identical(other.key, _this.key) || other.key == _this.key)&&(identical(other.currentValue, _this.currentValue) || other.currentValue == _this.currentValue)&&(identical(other.originalValue, _this.originalValue) || other.originalValue == _this.originalValue)&&(identical(other.originalConfidence, _this.originalConfidence) || other.originalConfidence == _this.originalConfidence)&&(identical(other.status, _this.status) || other.status == _this.status));
}


@override
int get hashCode {
  final _this = this as FieldRowState;
  return Object.hash(runtimeType,_this.key,_this.currentValue,_this.originalValue,_this.originalConfidence,_this.status);
}

@override
String toString() {
  final _this = this as FieldRowState;
  return 'FieldRowState(key: ${_this.key}, currentValue: ${_this.currentValue}, originalValue: ${_this.originalValue}, originalConfidence: ${_this.originalConfidence}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $FieldRowStateCopyWith<$Res>  {
  factory $FieldRowStateCopyWith(FieldRowState value, $Res Function(FieldRowState) _then) = _$FieldRowStateCopyWithImpl;
@useResult
$Res call({
 FieldKey key, String currentValue, String originalValue, double originalConfidence, FieldCorrectionStatus status
});


$FieldCorrectionStatusCopyWith<$Res> get status;

}
/// @nodoc
class _$FieldRowStateCopyWithImpl<$Res>
    implements $FieldRowStateCopyWith<$Res> {
  _$FieldRowStateCopyWithImpl(this._self, this._then);

  final FieldRowState _self;
  final $Res Function(FieldRowState) _then;

/// Create a copy of FieldRowState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? currentValue = null,Object? originalValue = null,Object? originalConfidence = null,Object? status = null,}) {
  return _then(FieldRowState(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as FieldKey,currentValue: null == currentValue ? _self.currentValue : currentValue // ignore: cast_nullable_to_non_nullable
as String,originalValue: null == originalValue ? _self.originalValue : originalValue // ignore: cast_nullable_to_non_nullable
as String,originalConfidence: null == originalConfidence ? _self.originalConfidence : originalConfidence // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FieldCorrectionStatus,
  ));
}
/// Create a copy of FieldRowState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FieldCorrectionStatusCopyWith<$Res> get status {
  
  return $FieldCorrectionStatusCopyWith<$Res>(_self.status, (value) {
    return _then(_self.copyWith(status: value));
  });
}
}


/// Adds pattern-matching-related methods to [FieldRowState].
extension FieldRowStatePatterns on FieldRowState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FieldRowState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FieldRowState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FieldRowState value)  $default,){
final _that = this;
switch (_that) {
case _FieldRowState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FieldRowState value)?  $default,){
final _that = this;
switch (_that) {
case _FieldRowState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FieldKey key,  String currentValue,  String originalValue,  double originalConfidence,  FieldCorrectionStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FieldRowState() when $default != null:
return $default(_that.key,_that.currentValue,_that.originalValue,_that.originalConfidence,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FieldKey key,  String currentValue,  String originalValue,  double originalConfidence,  FieldCorrectionStatus status)  $default,) {final _that = this;
switch (_that) {
case _FieldRowState():
return $default(_that.key,_that.currentValue,_that.originalValue,_that.originalConfidence,_that.status);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FieldKey key,  String currentValue,  String originalValue,  double originalConfidence,  FieldCorrectionStatus status)?  $default,) {final _that = this;
switch (_that) {
case _FieldRowState() when $default != null:
return $default(_that.key,_that.currentValue,_that.originalValue,_that.originalConfidence,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _FieldRowState extends FieldRowState {
  const _FieldRowState({required this.key, required this.currentValue, required this.originalValue, required this.originalConfidence, this.status = const FieldCorrectionStatus.unedited()}): super._();
  

@override final  FieldKey key;
/// The field's current value — original or edited. The raw/canonical
/// form (ISO-8601 for `expiryDate`); the view formats it for display.
@override final  String currentValue;
/// The machine-extracted value, before any edit. A `ready` state is
/// only ever reached once every field has been confirmed present — a
/// missing field blocks the whole screen instead (FR-009,
/// `DocumentConfirmationViewBlocked`) — so this is never null here.
@override final  String originalValue;
/// The processor's confidence for the original value.
@override final  double originalConfidence;
@override@JsonKey() final  FieldCorrectionStatus status;

/// Create a copy of FieldRowState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FieldRowStateCopyWith<_FieldRowState> get copyWith => __$FieldRowStateCopyWithImpl<_FieldRowState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FieldRowState&&(identical(other.key, key) || other.key == key)&&(identical(other.currentValue, currentValue) || other.currentValue == currentValue)&&(identical(other.originalValue, originalValue) || other.originalValue == originalValue)&&(identical(other.originalConfidence, originalConfidence) || other.originalConfidence == originalConfidence)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode {
    return Object.hash(runtimeType,key,currentValue,originalValue,originalConfidence,status);
}

@override
String toString() {
    return 'FieldRowState(key: $key, currentValue: $currentValue, originalValue: $originalValue, originalConfidence: $originalConfidence, status: $status)';
}


}

/// @nodoc
abstract mixin class _$FieldRowStateCopyWith<$Res> implements $FieldRowStateCopyWith<$Res> {
  factory _$FieldRowStateCopyWith(_FieldRowState value, $Res Function(_FieldRowState) _then) = __$FieldRowStateCopyWithImpl;
@override @useResult
$Res call({
 FieldKey key, String currentValue, String originalValue, double originalConfidence, FieldCorrectionStatus status
});


@override $FieldCorrectionStatusCopyWith<$Res> get status;

}
/// @nodoc
class __$FieldRowStateCopyWithImpl<$Res>
    implements _$FieldRowStateCopyWith<$Res> {
  __$FieldRowStateCopyWithImpl(this._self, this._then);

  final _FieldRowState _self;
  final $Res Function(_FieldRowState) _then;

/// Create a copy of FieldRowState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? currentValue = null,Object? originalValue = null,Object? originalConfidence = null,Object? status = null,}) {
  return _then(_FieldRowState(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as FieldKey,currentValue: null == currentValue ? _self.currentValue : currentValue // ignore: cast_nullable_to_non_nullable
as String,originalValue: null == originalValue ? _self.originalValue : originalValue // ignore: cast_nullable_to_non_nullable
as String,originalConfidence: null == originalConfidence ? _self.originalConfidence : originalConfidence // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FieldCorrectionStatus,
  ));
}

/// Create a copy of FieldRowState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FieldCorrectionStatusCopyWith<$Res> get status {
  
  return $FieldCorrectionStatusCopyWith<$Res>(_self.status, (value) {
    return _then(_self.copyWith(status: value));
  });
}
}

/// @nodoc
mixin _$DocumentConfirmationViewState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentConfirmationViewState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'DocumentConfirmationViewState()';
}


}

/// @nodoc
class $DocumentConfirmationViewStateCopyWith<$Res>  {
$DocumentConfirmationViewStateCopyWith(DocumentConfirmationViewState _, $Res Function(DocumentConfirmationViewState) __);
}


/// Adds pattern-matching-related methods to [DocumentConfirmationViewState].
extension DocumentConfirmationViewStatePatterns on DocumentConfirmationViewState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DocumentConfirmationViewLoading value)?  loading,TResult Function( DocumentConfirmationViewBlocked value)?  blocked,TResult Function( DocumentConfirmationViewReady value)?  ready,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DocumentConfirmationViewLoading() when loading != null:
return loading(_that);case DocumentConfirmationViewBlocked() when blocked != null:
return blocked(_that);case DocumentConfirmationViewReady() when ready != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DocumentConfirmationViewLoading value)  loading,required TResult Function( DocumentConfirmationViewBlocked value)  blocked,required TResult Function( DocumentConfirmationViewReady value)  ready,}){
final _that = this;
switch (_that) {
case DocumentConfirmationViewLoading():
return loading(_that);case DocumentConfirmationViewBlocked():
return blocked(_that);case DocumentConfirmationViewReady():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DocumentConfirmationViewLoading value)?  loading,TResult? Function( DocumentConfirmationViewBlocked value)?  blocked,TResult? Function( DocumentConfirmationViewReady value)?  ready,}){
final _that = this;
switch (_that) {
case DocumentConfirmationViewLoading() when loading != null:
return loading(_that);case DocumentConfirmationViewBlocked() when blocked != null:
return blocked(_that);case DocumentConfirmationViewReady() when ready != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( DocumentBlockReason reason)?  blocked,TResult Function( List<FieldRowState> fields,  bool confirming,  bool confirmFailed,  bool typedEntry,  DocumentType? documentType,  bool documentTypeInvalid,  ConfirmFailureKind failureKind,  Duration? retryAfter)?  ready,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DocumentConfirmationViewLoading() when loading != null:
return loading();case DocumentConfirmationViewBlocked() when blocked != null:
return blocked(_that.reason);case DocumentConfirmationViewReady() when ready != null:
return ready(_that.fields,_that.confirming,_that.confirmFailed,_that.typedEntry,_that.documentType,_that.documentTypeInvalid,_that.failureKind,_that.retryAfter);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( DocumentBlockReason reason)  blocked,required TResult Function( List<FieldRowState> fields,  bool confirming,  bool confirmFailed,  bool typedEntry,  DocumentType? documentType,  bool documentTypeInvalid,  ConfirmFailureKind failureKind,  Duration? retryAfter)  ready,}) {final _that = this;
switch (_that) {
case DocumentConfirmationViewLoading():
return loading();case DocumentConfirmationViewBlocked():
return blocked(_that.reason);case DocumentConfirmationViewReady():
return ready(_that.fields,_that.confirming,_that.confirmFailed,_that.typedEntry,_that.documentType,_that.documentTypeInvalid,_that.failureKind,_that.retryAfter);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( DocumentBlockReason reason)?  blocked,TResult? Function( List<FieldRowState> fields,  bool confirming,  bool confirmFailed,  bool typedEntry,  DocumentType? documentType,  bool documentTypeInvalid,  ConfirmFailureKind failureKind,  Duration? retryAfter)?  ready,}) {final _that = this;
switch (_that) {
case DocumentConfirmationViewLoading() when loading != null:
return loading();case DocumentConfirmationViewBlocked() when blocked != null:
return blocked(_that.reason);case DocumentConfirmationViewReady() when ready != null:
return ready(_that.fields,_that.confirming,_that.confirmFailed,_that.typedEntry,_that.documentType,_that.documentTypeInvalid,_that.failureKind,_that.retryAfter);case _:
  return null;

}
}

}

/// @nodoc


class DocumentConfirmationViewLoading implements DocumentConfirmationViewState {
  const DocumentConfirmationViewLoading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentConfirmationViewLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'DocumentConfirmationViewState.loading()';
}


}




/// @nodoc


class DocumentConfirmationViewBlocked implements DocumentConfirmationViewState {
  const DocumentConfirmationViewBlocked({required this.reason});
  

 final  DocumentBlockReason reason;

/// Create a copy of DocumentConfirmationViewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentConfirmationViewBlockedCopyWith<DocumentConfirmationViewBlocked> get copyWith => _$DocumentConfirmationViewBlockedCopyWithImpl<DocumentConfirmationViewBlocked>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentConfirmationViewBlocked&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode {
    return Object.hash(runtimeType,reason);
}

@override
String toString() {
    return 'DocumentConfirmationViewState.blocked(reason: $reason)';
}


}

/// @nodoc
abstract mixin class $DocumentConfirmationViewBlockedCopyWith<$Res> implements $DocumentConfirmationViewStateCopyWith<$Res> {
  factory $DocumentConfirmationViewBlockedCopyWith(DocumentConfirmationViewBlocked value, $Res Function(DocumentConfirmationViewBlocked) _then) = _$DocumentConfirmationViewBlockedCopyWithImpl;
@useResult
$Res call({
 DocumentBlockReason reason
});




}
/// @nodoc
class _$DocumentConfirmationViewBlockedCopyWithImpl<$Res>
    implements $DocumentConfirmationViewBlockedCopyWith<$Res> {
  _$DocumentConfirmationViewBlockedCopyWithImpl(this._self, this._then);

  final DocumentConfirmationViewBlocked _self;
  final $Res Function(DocumentConfirmationViewBlocked) _then;

/// Create a copy of DocumentConfirmationViewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reason = null,}) {
  return _then(DocumentConfirmationViewBlocked(
reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as DocumentBlockReason,
  ));
}


}

/// @nodoc


class DocumentConfirmationViewReady implements DocumentConfirmationViewState {
  const DocumentConfirmationViewReady({required  List<FieldRowState> fields, this.confirming = false, this.confirmFailed = false, this.typedEntry = false, this.documentType, this.documentTypeInvalid = false, this.failureKind = ConfirmFailureKind.generic, this.retryAfter}): _fields = fields;
  

 final  List<FieldRowState> _fields;
 List<FieldRowState> get fields {
  if (_fields is EqualUnmodifiableListView) return _fields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fields);
}

@JsonKey() final  bool confirming;
@JsonKey() final  bool confirmFailed;
/// 015 FR-002a: the passenger types every field, because the backend
/// reads nothing from the photo. True when the capture handed over
/// only empty fields, as the release capture does.
@JsonKey() final  bool typedEntry;
/// 015 FR-002: CC, CE or Pasaporte, chosen by the passenger. It is
/// required when [typedEntry] is true.
 final  DocumentType? documentType;
/// The backend refused the document type (`DATOS_INVALIDOS`).
@JsonKey() final  bool documentTypeInvalid;
/// Why the last confirm failed. It is read only when [confirmFailed].
@JsonKey() final  ConfirmFailureKind failureKind;
/// For [ConfirmFailureKind.serviceBusy]: the backend's Retry-After.
 final  Duration? retryAfter;

/// Create a copy of DocumentConfirmationViewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentConfirmationViewReadyCopyWith<DocumentConfirmationViewReady> get copyWith => _$DocumentConfirmationViewReadyCopyWithImpl<DocumentConfirmationViewReady>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentConfirmationViewReady&&const DeepCollectionEquality().equals(other.fields, _fields)&&(identical(other.confirming, confirming) || other.confirming == confirming)&&(identical(other.confirmFailed, confirmFailed) || other.confirmFailed == confirmFailed)&&(identical(other.typedEntry, typedEntry) || other.typedEntry == typedEntry)&&(identical(other.documentType, documentType) || other.documentType == documentType)&&(identical(other.documentTypeInvalid, documentTypeInvalid) || other.documentTypeInvalid == documentTypeInvalid)&&(identical(other.failureKind, failureKind) || other.failureKind == failureKind)&&(identical(other.retryAfter, retryAfter) || other.retryAfter == retryAfter));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_fields),confirming,confirmFailed,typedEntry,documentType,documentTypeInvalid,failureKind,retryAfter);
}

@override
String toString() {
    return 'DocumentConfirmationViewState.ready(fields: $fields, confirming: $confirming, confirmFailed: $confirmFailed, typedEntry: $typedEntry, documentType: $documentType, documentTypeInvalid: $documentTypeInvalid, failureKind: $failureKind, retryAfter: $retryAfter)';
}


}

/// @nodoc
abstract mixin class $DocumentConfirmationViewReadyCopyWith<$Res> implements $DocumentConfirmationViewStateCopyWith<$Res> {
  factory $DocumentConfirmationViewReadyCopyWith(DocumentConfirmationViewReady value, $Res Function(DocumentConfirmationViewReady) _then) = _$DocumentConfirmationViewReadyCopyWithImpl;
@useResult
$Res call({
 List<FieldRowState> fields, bool confirming, bool confirmFailed, bool typedEntry, DocumentType? documentType, bool documentTypeInvalid, ConfirmFailureKind failureKind, Duration? retryAfter
});




}
/// @nodoc
class _$DocumentConfirmationViewReadyCopyWithImpl<$Res>
    implements $DocumentConfirmationViewReadyCopyWith<$Res> {
  _$DocumentConfirmationViewReadyCopyWithImpl(this._self, this._then);

  final DocumentConfirmationViewReady _self;
  final $Res Function(DocumentConfirmationViewReady) _then;

/// Create a copy of DocumentConfirmationViewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? fields = null,Object? confirming = null,Object? confirmFailed = null,Object? typedEntry = null,Object? documentType = freezed,Object? documentTypeInvalid = null,Object? failureKind = null,Object? retryAfter = freezed,}) {
  return _then(DocumentConfirmationViewReady(
fields: null == fields ? _self._fields : fields // ignore: cast_nullable_to_non_nullable
as List<FieldRowState>,confirming: null == confirming ? _self.confirming : confirming // ignore: cast_nullable_to_non_nullable
as bool,confirmFailed: null == confirmFailed ? _self.confirmFailed : confirmFailed // ignore: cast_nullable_to_non_nullable
as bool,typedEntry: null == typedEntry ? _self.typedEntry : typedEntry // ignore: cast_nullable_to_non_nullable
as bool,documentType: freezed == documentType ? _self.documentType : documentType // ignore: cast_nullable_to_non_nullable
as DocumentType?,documentTypeInvalid: null == documentTypeInvalid ? _self.documentTypeInvalid : documentTypeInvalid // ignore: cast_nullable_to_non_nullable
as bool,failureKind: null == failureKind ? _self.failureKind : failureKind // ignore: cast_nullable_to_non_nullable
as ConfirmFailureKind,retryAfter: freezed == retryAfter ? _self.retryAfter : retryAfter // ignore: cast_nullable_to_non_nullable
as Duration?,
  ));
}


}

// dart format on
