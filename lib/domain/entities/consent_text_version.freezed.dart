// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'consent_text_version.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ConsentPoint {

 ConsentPointIcon get icon; String get heading; String get body;
/// Create a copy of ConsentPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConsentPointCopyWith<ConsentPoint> get copyWith => _$ConsentPointCopyWithImpl<ConsentPoint>(this as ConsentPoint, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ConsentPoint;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConsentPoint&&(identical(other.icon, _this.icon) || other.icon == _this.icon)&&(identical(other.heading, _this.heading) || other.heading == _this.heading)&&(identical(other.body, _this.body) || other.body == _this.body));
}


@override
int get hashCode {
  final _this = this as ConsentPoint;
  return Object.hash(runtimeType,_this.icon,_this.heading,_this.body);
}

@override
String toString() {
  final _this = this as ConsentPoint;
  return 'ConsentPoint(icon: ${_this.icon}, heading: ${_this.heading}, body: ${_this.body})';
}


}

/// @nodoc
abstract mixin class $ConsentPointCopyWith<$Res>  {
  factory $ConsentPointCopyWith(ConsentPoint value, $Res Function(ConsentPoint) _then) = _$ConsentPointCopyWithImpl;
@useResult
$Res call({
 ConsentPointIcon icon, String heading, String body
});




}
/// @nodoc
class _$ConsentPointCopyWithImpl<$Res>
    implements $ConsentPointCopyWith<$Res> {
  _$ConsentPointCopyWithImpl(this._self, this._then);

  final ConsentPoint _self;
  final $Res Function(ConsentPoint) _then;

/// Create a copy of ConsentPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? icon = null,Object? heading = null,Object? body = null,}) {
  return _then(ConsentPoint(
icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as ConsentPointIcon,heading: null == heading ? _self.heading : heading // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ConsentPoint].
extension ConsentPointPatterns on ConsentPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConsentPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConsentPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConsentPoint value)  $default,){
final _that = this;
switch (_that) {
case _ConsentPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConsentPoint value)?  $default,){
final _that = this;
switch (_that) {
case _ConsentPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ConsentPointIcon icon,  String heading,  String body)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConsentPoint() when $default != null:
return $default(_that.icon,_that.heading,_that.body);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ConsentPointIcon icon,  String heading,  String body)  $default,) {final _that = this;
switch (_that) {
case _ConsentPoint():
return $default(_that.icon,_that.heading,_that.body);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ConsentPointIcon icon,  String heading,  String body)?  $default,) {final _that = this;
switch (_that) {
case _ConsentPoint() when $default != null:
return $default(_that.icon,_that.heading,_that.body);case _:
  return null;

}
}

}

/// @nodoc


class _ConsentPoint implements ConsentPoint {
  const _ConsentPoint({required this.icon, required this.heading, required this.body});
  

@override final  ConsentPointIcon icon;
@override final  String heading;
@override final  String body;

/// Create a copy of ConsentPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConsentPointCopyWith<_ConsentPoint> get copyWith => __$ConsentPointCopyWithImpl<_ConsentPoint>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConsentPoint&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.heading, heading) || other.heading == heading)&&(identical(other.body, body) || other.body == body));
}


@override
int get hashCode {
    return Object.hash(runtimeType,icon,heading,body);
}

@override
String toString() {
    return 'ConsentPoint(icon: $icon, heading: $heading, body: $body)';
}


}

/// @nodoc
abstract mixin class _$ConsentPointCopyWith<$Res> implements $ConsentPointCopyWith<$Res> {
  factory _$ConsentPointCopyWith(_ConsentPoint value, $Res Function(_ConsentPoint) _then) = __$ConsentPointCopyWithImpl;
@override @useResult
$Res call({
 ConsentPointIcon icon, String heading, String body
});




}
/// @nodoc
class __$ConsentPointCopyWithImpl<$Res>
    implements _$ConsentPointCopyWith<$Res> {
  __$ConsentPointCopyWithImpl(this._self, this._then);

  final _ConsentPoint _self;
  final $Res Function(_ConsentPoint) _then;

/// Create a copy of ConsentPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? icon = null,Object? heading = null,Object? body = null,}) {
  return _then(_ConsentPoint(
icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as ConsentPointIcon,heading: null == heading ? _self.heading : heading // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$ConsentTextVersion {

/// The identifier a `ConsentRecord.textVersionId` references.
 String get id;/// Rendered in order (FR-002/FR-014).
 List<ConsentPoint> get points;/// FR-002: the passenger's rights over their data.
 String get rightsStatement;/// FR-003: that providing sensitive data is optional.
 String get optionalityStatement;/// FR-002: names the external processor performing verification
/// (resolves the UI reference's undisclosed-processor gap).
 String get processorDisclosure;/// FR-012.
 String get privacyPolicyUrl;/// FR-012.
 String get termsUrl;/// Displayed if useful for FR-014's "what changed" framing; not
/// otherwise used by app logic.
 DateTime get publishedAt;
/// Create a copy of ConsentTextVersion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConsentTextVersionCopyWith<ConsentTextVersion> get copyWith => _$ConsentTextVersionCopyWithImpl<ConsentTextVersion>(this as ConsentTextVersion, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ConsentTextVersion;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConsentTextVersion&&(identical(other.id, _this.id) || other.id == _this.id)&&const DeepCollectionEquality().equals(other.points, _this.points)&&(identical(other.rightsStatement, _this.rightsStatement) || other.rightsStatement == _this.rightsStatement)&&(identical(other.optionalityStatement, _this.optionalityStatement) || other.optionalityStatement == _this.optionalityStatement)&&(identical(other.processorDisclosure, _this.processorDisclosure) || other.processorDisclosure == _this.processorDisclosure)&&(identical(other.privacyPolicyUrl, _this.privacyPolicyUrl) || other.privacyPolicyUrl == _this.privacyPolicyUrl)&&(identical(other.termsUrl, _this.termsUrl) || other.termsUrl == _this.termsUrl)&&(identical(other.publishedAt, _this.publishedAt) || other.publishedAt == _this.publishedAt));
}


@override
int get hashCode {
  final _this = this as ConsentTextVersion;
  return Object.hash(runtimeType,_this.id,const DeepCollectionEquality().hash(_this.points),_this.rightsStatement,_this.optionalityStatement,_this.processorDisclosure,_this.privacyPolicyUrl,_this.termsUrl,_this.publishedAt);
}

@override
String toString() {
  final _this = this as ConsentTextVersion;
  return 'ConsentTextVersion(id: ${_this.id}, points: ${_this.points}, rightsStatement: ${_this.rightsStatement}, optionalityStatement: ${_this.optionalityStatement}, processorDisclosure: ${_this.processorDisclosure}, privacyPolicyUrl: ${_this.privacyPolicyUrl}, termsUrl: ${_this.termsUrl}, publishedAt: ${_this.publishedAt})';
}


}

/// @nodoc
abstract mixin class $ConsentTextVersionCopyWith<$Res>  {
  factory $ConsentTextVersionCopyWith(ConsentTextVersion value, $Res Function(ConsentTextVersion) _then) = _$ConsentTextVersionCopyWithImpl;
@useResult
$Res call({
 String id, List<ConsentPoint> points, String rightsStatement, String optionalityStatement, String processorDisclosure, String privacyPolicyUrl, String termsUrl, DateTime publishedAt
});




}
/// @nodoc
class _$ConsentTextVersionCopyWithImpl<$Res>
    implements $ConsentTextVersionCopyWith<$Res> {
  _$ConsentTextVersionCopyWithImpl(this._self, this._then);

  final ConsentTextVersion _self;
  final $Res Function(ConsentTextVersion) _then;

/// Create a copy of ConsentTextVersion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? points = null,Object? rightsStatement = null,Object? optionalityStatement = null,Object? processorDisclosure = null,Object? privacyPolicyUrl = null,Object? termsUrl = null,Object? publishedAt = null,}) {
  return _then(ConsentTextVersion(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as List<ConsentPoint>,rightsStatement: null == rightsStatement ? _self.rightsStatement : rightsStatement // ignore: cast_nullable_to_non_nullable
as String,optionalityStatement: null == optionalityStatement ? _self.optionalityStatement : optionalityStatement // ignore: cast_nullable_to_non_nullable
as String,processorDisclosure: null == processorDisclosure ? _self.processorDisclosure : processorDisclosure // ignore: cast_nullable_to_non_nullable
as String,privacyPolicyUrl: null == privacyPolicyUrl ? _self.privacyPolicyUrl : privacyPolicyUrl // ignore: cast_nullable_to_non_nullable
as String,termsUrl: null == termsUrl ? _self.termsUrl : termsUrl // ignore: cast_nullable_to_non_nullable
as String,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ConsentTextVersion].
extension ConsentTextVersionPatterns on ConsentTextVersion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConsentTextVersion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConsentTextVersion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConsentTextVersion value)  $default,){
final _that = this;
switch (_that) {
case _ConsentTextVersion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConsentTextVersion value)?  $default,){
final _that = this;
switch (_that) {
case _ConsentTextVersion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  List<ConsentPoint> points,  String rightsStatement,  String optionalityStatement,  String processorDisclosure,  String privacyPolicyUrl,  String termsUrl,  DateTime publishedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConsentTextVersion() when $default != null:
return $default(_that.id,_that.points,_that.rightsStatement,_that.optionalityStatement,_that.processorDisclosure,_that.privacyPolicyUrl,_that.termsUrl,_that.publishedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  List<ConsentPoint> points,  String rightsStatement,  String optionalityStatement,  String processorDisclosure,  String privacyPolicyUrl,  String termsUrl,  DateTime publishedAt)  $default,) {final _that = this;
switch (_that) {
case _ConsentTextVersion():
return $default(_that.id,_that.points,_that.rightsStatement,_that.optionalityStatement,_that.processorDisclosure,_that.privacyPolicyUrl,_that.termsUrl,_that.publishedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  List<ConsentPoint> points,  String rightsStatement,  String optionalityStatement,  String processorDisclosure,  String privacyPolicyUrl,  String termsUrl,  DateTime publishedAt)?  $default,) {final _that = this;
switch (_that) {
case _ConsentTextVersion() when $default != null:
return $default(_that.id,_that.points,_that.rightsStatement,_that.optionalityStatement,_that.processorDisclosure,_that.privacyPolicyUrl,_that.termsUrl,_that.publishedAt);case _:
  return null;

}
}

}

/// @nodoc


class _ConsentTextVersion implements ConsentTextVersion {
  const _ConsentTextVersion({required this.id, required  List<ConsentPoint> points, required this.rightsStatement, required this.optionalityStatement, required this.processorDisclosure, required this.privacyPolicyUrl, required this.termsUrl, required this.publishedAt}): _points = points;
  

/// The identifier a `ConsentRecord.textVersionId` references.
@override final  String id;
/// Rendered in order (FR-002/FR-014).
 final  List<ConsentPoint> _points;
/// Rendered in order (FR-002/FR-014).
@override List<ConsentPoint> get points {
  if (_points is EqualUnmodifiableListView) return _points;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_points);
}

/// FR-002: the passenger's rights over their data.
@override final  String rightsStatement;
/// FR-003: that providing sensitive data is optional.
@override final  String optionalityStatement;
/// FR-002: names the external processor performing verification
/// (resolves the UI reference's undisclosed-processor gap).
@override final  String processorDisclosure;
/// FR-012.
@override final  String privacyPolicyUrl;
/// FR-012.
@override final  String termsUrl;
/// Displayed if useful for FR-014's "what changed" framing; not
/// otherwise used by app logic.
@override final  DateTime publishedAt;

/// Create a copy of ConsentTextVersion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConsentTextVersionCopyWith<_ConsentTextVersion> get copyWith => __$ConsentTextVersionCopyWithImpl<_ConsentTextVersion>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConsentTextVersion&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.points, _points)&&(identical(other.rightsStatement, rightsStatement) || other.rightsStatement == rightsStatement)&&(identical(other.optionalityStatement, optionalityStatement) || other.optionalityStatement == optionalityStatement)&&(identical(other.processorDisclosure, processorDisclosure) || other.processorDisclosure == processorDisclosure)&&(identical(other.privacyPolicyUrl, privacyPolicyUrl) || other.privacyPolicyUrl == privacyPolicyUrl)&&(identical(other.termsUrl, termsUrl) || other.termsUrl == termsUrl)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_points),rightsStatement,optionalityStatement,processorDisclosure,privacyPolicyUrl,termsUrl,publishedAt);
}

@override
String toString() {
    return 'ConsentTextVersion(id: $id, points: $points, rightsStatement: $rightsStatement, optionalityStatement: $optionalityStatement, processorDisclosure: $processorDisclosure, privacyPolicyUrl: $privacyPolicyUrl, termsUrl: $termsUrl, publishedAt: $publishedAt)';
}


}

/// @nodoc
abstract mixin class _$ConsentTextVersionCopyWith<$Res> implements $ConsentTextVersionCopyWith<$Res> {
  factory _$ConsentTextVersionCopyWith(_ConsentTextVersion value, $Res Function(_ConsentTextVersion) _then) = __$ConsentTextVersionCopyWithImpl;
@override @useResult
$Res call({
 String id, List<ConsentPoint> points, String rightsStatement, String optionalityStatement, String processorDisclosure, String privacyPolicyUrl, String termsUrl, DateTime publishedAt
});




}
/// @nodoc
class __$ConsentTextVersionCopyWithImpl<$Res>
    implements _$ConsentTextVersionCopyWith<$Res> {
  __$ConsentTextVersionCopyWithImpl(this._self, this._then);

  final _ConsentTextVersion _self;
  final $Res Function(_ConsentTextVersion) _then;

/// Create a copy of ConsentTextVersion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? points = null,Object? rightsStatement = null,Object? optionalityStatement = null,Object? processorDisclosure = null,Object? privacyPolicyUrl = null,Object? termsUrl = null,Object? publishedAt = null,}) {
  return _then(_ConsentTextVersion(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self._points : points // ignore: cast_nullable_to_non_nullable
as List<ConsentPoint>,rightsStatement: null == rightsStatement ? _self.rightsStatement : rightsStatement // ignore: cast_nullable_to_non_nullable
as String,optionalityStatement: null == optionalityStatement ? _self.optionalityStatement : optionalityStatement // ignore: cast_nullable_to_non_nullable
as String,processorDisclosure: null == processorDisclosure ? _self.processorDisclosure : processorDisclosure // ignore: cast_nullable_to_non_nullable
as String,privacyPolicyUrl: null == privacyPolicyUrl ? _self.privacyPolicyUrl : privacyPolicyUrl // ignore: cast_nullable_to_non_nullable
as String,termsUrl: null == termsUrl ? _self.termsUrl : termsUrl // ignore: cast_nullable_to_non_nullable
as String,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
