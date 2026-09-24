// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'identity_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ConfirmedField {

 FieldKey get key; String get value; FieldSource get source;/// Present only when [source] is [FieldSource.passengerCorrected]: the
/// machine-extracted value before correction (SC-002's audit trail).
 String? get originalValue;/// True when [source] is [FieldSource.passengerCorrected] and an
/// automated re-check (not just a low-confidence pass-through)
/// confirmed it (FR-005).
 bool get reverified;
/// Create a copy of ConfirmedField
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConfirmedFieldCopyWith<ConfirmedField> get copyWith => _$ConfirmedFieldCopyWithImpl<ConfirmedField>(this as ConfirmedField, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ConfirmedField;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConfirmedField&&(identical(other.key, _this.key) || other.key == _this.key)&&(identical(other.value, _this.value) || other.value == _this.value)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.originalValue, _this.originalValue) || other.originalValue == _this.originalValue)&&(identical(other.reverified, _this.reverified) || other.reverified == _this.reverified));
}


@override
int get hashCode {
  final _this = this as ConfirmedField;
  return Object.hash(runtimeType,_this.key,_this.value,_this.source,_this.originalValue,_this.reverified);
}

@override
String toString() {
  final _this = this as ConfirmedField;
  return 'ConfirmedField(key: ${_this.key}, value: ${_this.value}, source: ${_this.source}, originalValue: ${_this.originalValue}, reverified: ${_this.reverified})';
}


}

/// @nodoc
abstract mixin class $ConfirmedFieldCopyWith<$Res>  {
  factory $ConfirmedFieldCopyWith(ConfirmedField value, $Res Function(ConfirmedField) _then) = _$ConfirmedFieldCopyWithImpl;
@useResult
$Res call({
 FieldKey key, String value, FieldSource source, String? originalValue, bool reverified
});




}
/// @nodoc
class _$ConfirmedFieldCopyWithImpl<$Res>
    implements $ConfirmedFieldCopyWith<$Res> {
  _$ConfirmedFieldCopyWithImpl(this._self, this._then);

  final ConfirmedField _self;
  final $Res Function(ConfirmedField) _then;

/// Create a copy of ConfirmedField
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? value = null,Object? source = null,Object? originalValue = freezed,Object? reverified = null,}) {
  return _then(ConfirmedField(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as FieldKey,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as FieldSource,originalValue: freezed == originalValue ? _self.originalValue : originalValue // ignore: cast_nullable_to_non_nullable
as String?,reverified: null == reverified ? _self.reverified : reverified // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ConfirmedField].
extension ConfirmedFieldPatterns on ConfirmedField {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConfirmedField value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConfirmedField() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConfirmedField value)  $default,){
final _that = this;
switch (_that) {
case _ConfirmedField():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConfirmedField value)?  $default,){
final _that = this;
switch (_that) {
case _ConfirmedField() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FieldKey key,  String value,  FieldSource source,  String? originalValue,  bool reverified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConfirmedField() when $default != null:
return $default(_that.key,_that.value,_that.source,_that.originalValue,_that.reverified);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FieldKey key,  String value,  FieldSource source,  String? originalValue,  bool reverified)  $default,) {final _that = this;
switch (_that) {
case _ConfirmedField():
return $default(_that.key,_that.value,_that.source,_that.originalValue,_that.reverified);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FieldKey key,  String value,  FieldSource source,  String? originalValue,  bool reverified)?  $default,) {final _that = this;
switch (_that) {
case _ConfirmedField() when $default != null:
return $default(_that.key,_that.value,_that.source,_that.originalValue,_that.reverified);case _:
  return null;

}
}

}

/// @nodoc


class _ConfirmedField implements ConfirmedField {
  const _ConfirmedField({required this.key, required this.value, required this.source, this.originalValue, this.reverified = false});
  

@override final  FieldKey key;
@override final  String value;
@override final  FieldSource source;
/// Present only when [source] is [FieldSource.passengerCorrected]: the
/// machine-extracted value before correction (SC-002's audit trail).
@override final  String? originalValue;
/// True when [source] is [FieldSource.passengerCorrected] and an
/// automated re-check (not just a low-confidence pass-through)
/// confirmed it (FR-005).
@override@JsonKey() final  bool reverified;

/// Create a copy of ConfirmedField
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConfirmedFieldCopyWith<_ConfirmedField> get copyWith => __$ConfirmedFieldCopyWithImpl<_ConfirmedField>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConfirmedField&&(identical(other.key, key) || other.key == key)&&(identical(other.value, value) || other.value == value)&&(identical(other.source, source) || other.source == source)&&(identical(other.originalValue, originalValue) || other.originalValue == originalValue)&&(identical(other.reverified, reverified) || other.reverified == reverified));
}


@override
int get hashCode {
    return Object.hash(runtimeType,key,value,source,originalValue,reverified);
}

@override
String toString() {
    return 'ConfirmedField(key: $key, value: $value, source: $source, originalValue: $originalValue, reverified: $reverified)';
}


}

/// @nodoc
abstract mixin class _$ConfirmedFieldCopyWith<$Res> implements $ConfirmedFieldCopyWith<$Res> {
  factory _$ConfirmedFieldCopyWith(_ConfirmedField value, $Res Function(_ConfirmedField) _then) = __$ConfirmedFieldCopyWithImpl;
@override @useResult
$Res call({
 FieldKey key, String value, FieldSource source, String? originalValue, bool reverified
});




}
/// @nodoc
class __$ConfirmedFieldCopyWithImpl<$Res>
    implements _$ConfirmedFieldCopyWith<$Res> {
  __$ConfirmedFieldCopyWithImpl(this._self, this._then);

  final _ConfirmedField _self;
  final $Res Function(_ConfirmedField) _then;

/// Create a copy of ConfirmedField
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? value = null,Object? source = null,Object? originalValue = freezed,Object? reverified = null,}) {
  return _then(_ConfirmedField(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as FieldKey,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as FieldSource,originalValue: freezed == originalValue ? _self.originalValue : originalValue // ignore: cast_nullable_to_non_nullable
as String?,reverified: null == reverified ? _self.reverified : reverified // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$IdentityRecord {

 List<ConfirmedField> get fields;/// The passenger's choice of CC, CE or Pasaporte (015 FR-002). The
/// backend requires it, and no extraction supplies it. Null only on the
/// dev-offline path, whose fake backend does not ask.
 DocumentType? get documentType;
/// Create a copy of IdentityRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IdentityRecordCopyWith<IdentityRecord> get copyWith => _$IdentityRecordCopyWithImpl<IdentityRecord>(this as IdentityRecord, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as IdentityRecord;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IdentityRecord&&const DeepCollectionEquality().equals(other.fields, _this.fields)&&(identical(other.documentType, _this.documentType) || other.documentType == _this.documentType));
}


@override
int get hashCode {
  final _this = this as IdentityRecord;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.fields),_this.documentType);
}

@override
String toString() {
  final _this = this as IdentityRecord;
  return 'IdentityRecord(fields: ${_this.fields}, documentType: ${_this.documentType})';
}


}

/// @nodoc
abstract mixin class $IdentityRecordCopyWith<$Res>  {
  factory $IdentityRecordCopyWith(IdentityRecord value, $Res Function(IdentityRecord) _then) = _$IdentityRecordCopyWithImpl;
@useResult
$Res call({
 List<ConfirmedField> fields, DocumentType? documentType
});




}
/// @nodoc
class _$IdentityRecordCopyWithImpl<$Res>
    implements $IdentityRecordCopyWith<$Res> {
  _$IdentityRecordCopyWithImpl(this._self, this._then);

  final IdentityRecord _self;
  final $Res Function(IdentityRecord) _then;

/// Create a copy of IdentityRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fields = null,Object? documentType = freezed,}) {
  return _then(IdentityRecord(
fields: null == fields ? _self.fields : fields // ignore: cast_nullable_to_non_nullable
as List<ConfirmedField>,documentType: freezed == documentType ? _self.documentType : documentType // ignore: cast_nullable_to_non_nullable
as DocumentType?,
  ));
}

}


/// Adds pattern-matching-related methods to [IdentityRecord].
extension IdentityRecordPatterns on IdentityRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IdentityRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IdentityRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IdentityRecord value)  $default,){
final _that = this;
switch (_that) {
case _IdentityRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IdentityRecord value)?  $default,){
final _that = this;
switch (_that) {
case _IdentityRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ConfirmedField> fields,  DocumentType? documentType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IdentityRecord() when $default != null:
return $default(_that.fields,_that.documentType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ConfirmedField> fields,  DocumentType? documentType)  $default,) {final _that = this;
switch (_that) {
case _IdentityRecord():
return $default(_that.fields,_that.documentType);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ConfirmedField> fields,  DocumentType? documentType)?  $default,) {final _that = this;
switch (_that) {
case _IdentityRecord() when $default != null:
return $default(_that.fields,_that.documentType);case _:
  return null;

}
}

}

/// @nodoc


class _IdentityRecord implements IdentityRecord {
  const _IdentityRecord({required  List<ConfirmedField> fields, this.documentType}): _fields = fields;
  

 final  List<ConfirmedField> _fields;
@override List<ConfirmedField> get fields {
  if (_fields is EqualUnmodifiableListView) return _fields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fields);
}

/// The passenger's choice of CC, CE or Pasaporte (015 FR-002). The
/// backend requires it, and no extraction supplies it. Null only on the
/// dev-offline path, whose fake backend does not ask.
@override final  DocumentType? documentType;

/// Create a copy of IdentityRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IdentityRecordCopyWith<_IdentityRecord> get copyWith => __$IdentityRecordCopyWithImpl<_IdentityRecord>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _IdentityRecord&&const DeepCollectionEquality().equals(other.fields, _fields)&&(identical(other.documentType, documentType) || other.documentType == documentType));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_fields),documentType);
}

@override
String toString() {
    return 'IdentityRecord(fields: $fields, documentType: $documentType)';
}


}

/// @nodoc
abstract mixin class _$IdentityRecordCopyWith<$Res> implements $IdentityRecordCopyWith<$Res> {
  factory _$IdentityRecordCopyWith(_IdentityRecord value, $Res Function(_IdentityRecord) _then) = __$IdentityRecordCopyWithImpl;
@override @useResult
$Res call({
 List<ConfirmedField> fields, DocumentType? documentType
});




}
/// @nodoc
class __$IdentityRecordCopyWithImpl<$Res>
    implements _$IdentityRecordCopyWith<$Res> {
  __$IdentityRecordCopyWithImpl(this._self, this._then);

  final _IdentityRecord _self;
  final $Res Function(_IdentityRecord) _then;

/// Create a copy of IdentityRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fields = null,Object? documentType = freezed,}) {
  return _then(_IdentityRecord(
fields: null == fields ? _self._fields : fields // ignore: cast_nullable_to_non_nullable
as List<ConfirmedField>,documentType: freezed == documentType ? _self.documentType : documentType // ignore: cast_nullable_to_non_nullable
as DocumentType?,
  ));
}


}

// dart format on
