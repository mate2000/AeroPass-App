// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'extraction_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExtractedField {

 FieldKey get key;
/// Create a copy of ExtractedField
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExtractedFieldCopyWith<ExtractedField> get copyWith => _$ExtractedFieldCopyWithImpl<ExtractedField>(this as ExtractedField, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ExtractedField;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExtractedField&&(identical(other.key, _this.key) || other.key == _this.key));
}


@override
int get hashCode {
  final _this = this as ExtractedField;
  return Object.hash(runtimeType,_this.key);
}

@override
String toString() {
  final _this = this as ExtractedField;
  return 'ExtractedField(key: ${_this.key})';
}


}

/// @nodoc
abstract mixin class $ExtractedFieldCopyWith<$Res>  {
  factory $ExtractedFieldCopyWith(ExtractedField value, $Res Function(ExtractedField) _then) = _$ExtractedFieldCopyWithImpl;
@useResult
$Res call({
 FieldKey key
});




}
/// @nodoc
class _$ExtractedFieldCopyWithImpl<$Res>
    implements $ExtractedFieldCopyWith<$Res> {
  _$ExtractedFieldCopyWithImpl(this._self, this._then);

  final ExtractedField _self;
  final $Res Function(ExtractedField) _then;

/// Create a copy of ExtractedField
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,}) {
  return _then(_self.copyWith(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as FieldKey,
  ));
}

}


/// Adds pattern-matching-related methods to [ExtractedField].
extension ExtractedFieldPatterns on ExtractedField {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ExtractedFieldPresent value)?  present,TResult Function( ExtractedFieldMissing value)?  missing,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ExtractedFieldPresent() when present != null:
return present(_that);case ExtractedFieldMissing() when missing != null:
return missing(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ExtractedFieldPresent value)  present,required TResult Function( ExtractedFieldMissing value)  missing,}){
final _that = this;
switch (_that) {
case ExtractedFieldPresent():
return present(_that);case ExtractedFieldMissing():
return missing(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ExtractedFieldPresent value)?  present,TResult? Function( ExtractedFieldMissing value)?  missing,}){
final _that = this;
switch (_that) {
case ExtractedFieldPresent() when present != null:
return present(_that);case ExtractedFieldMissing() when missing != null:
return missing(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( FieldKey key,  String value,  double confidence)?  present,TResult Function( FieldKey key)?  missing,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ExtractedFieldPresent() when present != null:
return present(_that.key,_that.value,_that.confidence);case ExtractedFieldMissing() when missing != null:
return missing(_that.key);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( FieldKey key,  String value,  double confidence)  present,required TResult Function( FieldKey key)  missing,}) {final _that = this;
switch (_that) {
case ExtractedFieldPresent():
return present(_that.key,_that.value,_that.confidence);case ExtractedFieldMissing():
return missing(_that.key);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( FieldKey key,  String value,  double confidence)?  present,TResult? Function( FieldKey key)?  missing,}) {final _that = this;
switch (_that) {
case ExtractedFieldPresent() when present != null:
return present(_that.key,_that.value,_that.confidence);case ExtractedFieldMissing() when missing != null:
return missing(_that.key);case _:
  return null;

}
}

}

/// @nodoc


class ExtractedFieldPresent implements ExtractedField {
  const ExtractedFieldPresent({required this.key, required this.value, required this.confidence});
  

@override final  FieldKey key;
 final  String value;
 final  double confidence;

/// Create a copy of ExtractedField
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExtractedFieldPresentCopyWith<ExtractedFieldPresent> get copyWith => _$ExtractedFieldPresentCopyWithImpl<ExtractedFieldPresent>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ExtractedFieldPresent&&(identical(other.key, key) || other.key == key)&&(identical(other.value, value) || other.value == value)&&(identical(other.confidence, confidence) || other.confidence == confidence));
}


@override
int get hashCode {
    return Object.hash(runtimeType,key,value,confidence);
}

@override
String toString() {
    return 'ExtractedField.present(key: $key, value: $value, confidence: $confidence)';
}


}

/// @nodoc
abstract mixin class $ExtractedFieldPresentCopyWith<$Res> implements $ExtractedFieldCopyWith<$Res> {
  factory $ExtractedFieldPresentCopyWith(ExtractedFieldPresent value, $Res Function(ExtractedFieldPresent) _then) = _$ExtractedFieldPresentCopyWithImpl;
@override @useResult
$Res call({
 FieldKey key, String value, double confidence
});




}
/// @nodoc
class _$ExtractedFieldPresentCopyWithImpl<$Res>
    implements $ExtractedFieldPresentCopyWith<$Res> {
  _$ExtractedFieldPresentCopyWithImpl(this._self, this._then);

  final ExtractedFieldPresent _self;
  final $Res Function(ExtractedFieldPresent) _then;

/// Create a copy of ExtractedField
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? value = null,Object? confidence = null,}) {
  return _then(ExtractedFieldPresent(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as FieldKey,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc


class ExtractedFieldMissing implements ExtractedField {
  const ExtractedFieldMissing({required this.key});
  

@override final  FieldKey key;

/// Create a copy of ExtractedField
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExtractedFieldMissingCopyWith<ExtractedFieldMissing> get copyWith => _$ExtractedFieldMissingCopyWithImpl<ExtractedFieldMissing>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ExtractedFieldMissing&&(identical(other.key, key) || other.key == key));
}


@override
int get hashCode {
    return Object.hash(runtimeType,key);
}

@override
String toString() {
    return 'ExtractedField.missing(key: $key)';
}


}

/// @nodoc
abstract mixin class $ExtractedFieldMissingCopyWith<$Res> implements $ExtractedFieldCopyWith<$Res> {
  factory $ExtractedFieldMissingCopyWith(ExtractedFieldMissing value, $Res Function(ExtractedFieldMissing) _then) = _$ExtractedFieldMissingCopyWithImpl;
@override @useResult
$Res call({
 FieldKey key
});




}
/// @nodoc
class _$ExtractedFieldMissingCopyWithImpl<$Res>
    implements $ExtractedFieldMissingCopyWith<$Res> {
  _$ExtractedFieldMissingCopyWithImpl(this._self, this._then);

  final ExtractedFieldMissing _self;
  final $Res Function(ExtractedFieldMissing) _then;

/// Create a copy of ExtractedField
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,}) {
  return _then(ExtractedFieldMissing(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as FieldKey,
  ));
}


}

/// @nodoc
mixin _$ExtractionResult {

 List<ExtractedField> get fields;
/// Create a copy of ExtractionResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExtractionResultCopyWith<ExtractionResult> get copyWith => _$ExtractionResultCopyWithImpl<ExtractionResult>(this as ExtractionResult, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ExtractionResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExtractionResult&&const DeepCollectionEquality().equals(other.fields, _this.fields));
}


@override
int get hashCode {
  final _this = this as ExtractionResult;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.fields));
}

@override
String toString() {
  final _this = this as ExtractionResult;
  return 'ExtractionResult(fields: ${_this.fields})';
}


}

/// @nodoc
abstract mixin class $ExtractionResultCopyWith<$Res>  {
  factory $ExtractionResultCopyWith(ExtractionResult value, $Res Function(ExtractionResult) _then) = _$ExtractionResultCopyWithImpl;
@useResult
$Res call({
 List<ExtractedField> fields
});




}
/// @nodoc
class _$ExtractionResultCopyWithImpl<$Res>
    implements $ExtractionResultCopyWith<$Res> {
  _$ExtractionResultCopyWithImpl(this._self, this._then);

  final ExtractionResult _self;
  final $Res Function(ExtractionResult) _then;

/// Create a copy of ExtractionResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fields = null,}) {
  return _then(ExtractionResult(
fields: null == fields ? _self.fields : fields // ignore: cast_nullable_to_non_nullable
as List<ExtractedField>,
  ));
}

}


/// Adds pattern-matching-related methods to [ExtractionResult].
extension ExtractionResultPatterns on ExtractionResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExtractionResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExtractionResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExtractionResult value)  $default,){
final _that = this;
switch (_that) {
case _ExtractionResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExtractionResult value)?  $default,){
final _that = this;
switch (_that) {
case _ExtractionResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ExtractedField> fields)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExtractionResult() when $default != null:
return $default(_that.fields);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ExtractedField> fields)  $default,) {final _that = this;
switch (_that) {
case _ExtractionResult():
return $default(_that.fields);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ExtractedField> fields)?  $default,) {final _that = this;
switch (_that) {
case _ExtractionResult() when $default != null:
return $default(_that.fields);case _:
  return null;

}
}

}

/// @nodoc


class _ExtractionResult extends ExtractionResult {
  const _ExtractionResult({required  List<ExtractedField> fields}): _fields = fields,super._();
  

 final  List<ExtractedField> _fields;
@override List<ExtractedField> get fields {
  if (_fields is EqualUnmodifiableListView) return _fields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fields);
}


/// Create a copy of ExtractionResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExtractionResultCopyWith<_ExtractionResult> get copyWith => __$ExtractionResultCopyWithImpl<_ExtractionResult>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExtractionResult&&const DeepCollectionEquality().equals(other.fields, _fields));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_fields));
}

@override
String toString() {
    return 'ExtractionResult(fields: $fields)';
}


}

/// @nodoc
abstract mixin class _$ExtractionResultCopyWith<$Res> implements $ExtractionResultCopyWith<$Res> {
  factory _$ExtractionResultCopyWith(_ExtractionResult value, $Res Function(_ExtractionResult) _then) = __$ExtractionResultCopyWithImpl;
@override @useResult
$Res call({
 List<ExtractedField> fields
});




}
/// @nodoc
class __$ExtractionResultCopyWithImpl<$Res>
    implements _$ExtractionResultCopyWith<$Res> {
  __$ExtractionResultCopyWithImpl(this._self, this._then);

  final _ExtractionResult _self;
  final $Res Function(_ExtractionResult) _then;

/// Create a copy of ExtractionResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fields = null,}) {
  return _then(_ExtractionResult(
fields: null == fields ? _self._fields : fields // ignore: cast_nullable_to_non_nullable
as List<ExtractedField>,
  ));
}


}

// dart format on
