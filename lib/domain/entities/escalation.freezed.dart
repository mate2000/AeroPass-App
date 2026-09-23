// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'escalation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WaitEstimate {

 int get minMinutes; int get maxMinutes;
/// Create a copy of WaitEstimate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WaitEstimateCopyWith<WaitEstimate> get copyWith => _$WaitEstimateCopyWithImpl<WaitEstimate>(this as WaitEstimate, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WaitEstimate;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WaitEstimate&&(identical(other.minMinutes, _this.minMinutes) || other.minMinutes == _this.minMinutes)&&(identical(other.maxMinutes, _this.maxMinutes) || other.maxMinutes == _this.maxMinutes));
}


@override
int get hashCode {
  final _this = this as WaitEstimate;
  return Object.hash(runtimeType,_this.minMinutes,_this.maxMinutes);
}

@override
String toString() {
  final _this = this as WaitEstimate;
  return 'WaitEstimate(minMinutes: ${_this.minMinutes}, maxMinutes: ${_this.maxMinutes})';
}


}

/// @nodoc
abstract mixin class $WaitEstimateCopyWith<$Res>  {
  factory $WaitEstimateCopyWith(WaitEstimate value, $Res Function(WaitEstimate) _then) = _$WaitEstimateCopyWithImpl;
@useResult
$Res call({
 int minMinutes, int maxMinutes
});




}
/// @nodoc
class _$WaitEstimateCopyWithImpl<$Res>
    implements $WaitEstimateCopyWith<$Res> {
  _$WaitEstimateCopyWithImpl(this._self, this._then);

  final WaitEstimate _self;
  final $Res Function(WaitEstimate) _then;

/// Create a copy of WaitEstimate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? minMinutes = null,Object? maxMinutes = null,}) {
  return _then(WaitEstimate(
minMinutes: null == minMinutes ? _self.minMinutes : minMinutes // ignore: cast_nullable_to_non_nullable
as int,maxMinutes: null == maxMinutes ? _self.maxMinutes : maxMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [WaitEstimate].
extension WaitEstimatePatterns on WaitEstimate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WaitEstimate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WaitEstimate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WaitEstimate value)  $default,){
final _that = this;
switch (_that) {
case _WaitEstimate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WaitEstimate value)?  $default,){
final _that = this;
switch (_that) {
case _WaitEstimate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int minMinutes,  int maxMinutes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WaitEstimate() when $default != null:
return $default(_that.minMinutes,_that.maxMinutes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int minMinutes,  int maxMinutes)  $default,) {final _that = this;
switch (_that) {
case _WaitEstimate():
return $default(_that.minMinutes,_that.maxMinutes);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int minMinutes,  int maxMinutes)?  $default,) {final _that = this;
switch (_that) {
case _WaitEstimate() when $default != null:
return $default(_that.minMinutes,_that.maxMinutes);case _:
  return null;

}
}

}

/// @nodoc


class _WaitEstimate implements WaitEstimate {
  const _WaitEstimate({required this.minMinutes, required this.maxMinutes});
  

@override final  int minMinutes;
@override final  int maxMinutes;

/// Create a copy of WaitEstimate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WaitEstimateCopyWith<_WaitEstimate> get copyWith => __$WaitEstimateCopyWithImpl<_WaitEstimate>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WaitEstimate&&(identical(other.minMinutes, minMinutes) || other.minMinutes == minMinutes)&&(identical(other.maxMinutes, maxMinutes) || other.maxMinutes == maxMinutes));
}


@override
int get hashCode {
    return Object.hash(runtimeType,minMinutes,maxMinutes);
}

@override
String toString() {
    return 'WaitEstimate(minMinutes: $minMinutes, maxMinutes: $maxMinutes)';
}


}

/// @nodoc
abstract mixin class _$WaitEstimateCopyWith<$Res> implements $WaitEstimateCopyWith<$Res> {
  factory _$WaitEstimateCopyWith(_WaitEstimate value, $Res Function(_WaitEstimate) _then) = __$WaitEstimateCopyWithImpl;
@override @useResult
$Res call({
 int minMinutes, int maxMinutes
});




}
/// @nodoc
class __$WaitEstimateCopyWithImpl<$Res>
    implements _$WaitEstimateCopyWith<$Res> {
  __$WaitEstimateCopyWithImpl(this._self, this._then);

  final _WaitEstimate _self;
  final $Res Function(_WaitEstimate) _then;

/// Create a copy of WaitEstimate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? minMinutes = null,Object? maxMinutes = null,}) {
  return _then(_WaitEstimate(
minMinutes: null == minMinutes ? _self.minMinutes : minMinutes // ignore: cast_nullable_to_non_nullable
as int,maxMinutes: null == maxMinutes ? _self.maxMinutes : maxMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$AgentChannel {

 AgentChannelKind get kind; bool get available;/// Required when [available] is false (FR-005).
 DateTime? get nextOpensAt;/// Chat only, and only when supplied (FR-006).
 WaitEstimate? get estimatedWait;/// Operational data, e.g. "Lun–Vie 6:00am–10:00pm".
 String get hours;/// Module only: the airport (FR-007).
 String? get locationName;/// Module only: where the module is inside the airport (FR-007).
 String? get locationDetail;
/// Create a copy of AgentChannel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AgentChannelCopyWith<AgentChannel> get copyWith => _$AgentChannelCopyWithImpl<AgentChannel>(this as AgentChannel, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AgentChannel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AgentChannel&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.available, _this.available) || other.available == _this.available)&&(identical(other.nextOpensAt, _this.nextOpensAt) || other.nextOpensAt == _this.nextOpensAt)&&(identical(other.estimatedWait, _this.estimatedWait) || other.estimatedWait == _this.estimatedWait)&&(identical(other.hours, _this.hours) || other.hours == _this.hours)&&(identical(other.locationName, _this.locationName) || other.locationName == _this.locationName)&&(identical(other.locationDetail, _this.locationDetail) || other.locationDetail == _this.locationDetail));
}


@override
int get hashCode {
  final _this = this as AgentChannel;
  return Object.hash(runtimeType,_this.kind,_this.available,_this.nextOpensAt,_this.estimatedWait,_this.hours,_this.locationName,_this.locationDetail);
}

@override
String toString() {
  final _this = this as AgentChannel;
  return 'AgentChannel(kind: ${_this.kind}, available: ${_this.available}, nextOpensAt: ${_this.nextOpensAt}, estimatedWait: ${_this.estimatedWait}, hours: ${_this.hours}, locationName: ${_this.locationName}, locationDetail: ${_this.locationDetail})';
}


}

/// @nodoc
abstract mixin class $AgentChannelCopyWith<$Res>  {
  factory $AgentChannelCopyWith(AgentChannel value, $Res Function(AgentChannel) _then) = _$AgentChannelCopyWithImpl;
@useResult
$Res call({
 AgentChannelKind kind, bool available, DateTime? nextOpensAt, WaitEstimate? estimatedWait, String hours, String? locationName, String? locationDetail
});


$WaitEstimateCopyWith<$Res>? get estimatedWait;

}
/// @nodoc
class _$AgentChannelCopyWithImpl<$Res>
    implements $AgentChannelCopyWith<$Res> {
  _$AgentChannelCopyWithImpl(this._self, this._then);

  final AgentChannel _self;
  final $Res Function(AgentChannel) _then;

/// Create a copy of AgentChannel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? available = null,Object? nextOpensAt = freezed,Object? estimatedWait = freezed,Object? hours = null,Object? locationName = freezed,Object? locationDetail = freezed,}) {
  return _then(AgentChannel(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as AgentChannelKind,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,nextOpensAt: freezed == nextOpensAt ? _self.nextOpensAt : nextOpensAt // ignore: cast_nullable_to_non_nullable
as DateTime?,estimatedWait: freezed == estimatedWait ? _self.estimatedWait : estimatedWait // ignore: cast_nullable_to_non_nullable
as WaitEstimate?,hours: null == hours ? _self.hours : hours // ignore: cast_nullable_to_non_nullable
as String,locationName: freezed == locationName ? _self.locationName : locationName // ignore: cast_nullable_to_non_nullable
as String?,locationDetail: freezed == locationDetail ? _self.locationDetail : locationDetail // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of AgentChannel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WaitEstimateCopyWith<$Res>? get estimatedWait {
    if (_self.estimatedWait == null) {
    return null;
  }

  return $WaitEstimateCopyWith<$Res>(_self.estimatedWait!, (value) {
    return _then(_self.copyWith(estimatedWait: value));
  });
}
}


/// Adds pattern-matching-related methods to [AgentChannel].
extension AgentChannelPatterns on AgentChannel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AgentChannel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AgentChannel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AgentChannel value)  $default,){
final _that = this;
switch (_that) {
case _AgentChannel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AgentChannel value)?  $default,){
final _that = this;
switch (_that) {
case _AgentChannel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AgentChannelKind kind,  bool available,  DateTime? nextOpensAt,  WaitEstimate? estimatedWait,  String hours,  String? locationName,  String? locationDetail)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AgentChannel() when $default != null:
return $default(_that.kind,_that.available,_that.nextOpensAt,_that.estimatedWait,_that.hours,_that.locationName,_that.locationDetail);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AgentChannelKind kind,  bool available,  DateTime? nextOpensAt,  WaitEstimate? estimatedWait,  String hours,  String? locationName,  String? locationDetail)  $default,) {final _that = this;
switch (_that) {
case _AgentChannel():
return $default(_that.kind,_that.available,_that.nextOpensAt,_that.estimatedWait,_that.hours,_that.locationName,_that.locationDetail);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AgentChannelKind kind,  bool available,  DateTime? nextOpensAt,  WaitEstimate? estimatedWait,  String hours,  String? locationName,  String? locationDetail)?  $default,) {final _that = this;
switch (_that) {
case _AgentChannel() when $default != null:
return $default(_that.kind,_that.available,_that.nextOpensAt,_that.estimatedWait,_that.hours,_that.locationName,_that.locationDetail);case _:
  return null;

}
}

}

/// @nodoc


class _AgentChannel implements AgentChannel {
  const _AgentChannel({required this.kind, required this.available, this.nextOpensAt, this.estimatedWait, required this.hours, this.locationName, this.locationDetail});
  

@override final  AgentChannelKind kind;
@override final  bool available;
/// Required when [available] is false (FR-005).
@override final  DateTime? nextOpensAt;
/// Chat only, and only when supplied (FR-006).
@override final  WaitEstimate? estimatedWait;
/// Operational data, e.g. "Lun–Vie 6:00am–10:00pm".
@override final  String hours;
/// Module only: the airport (FR-007).
@override final  String? locationName;
/// Module only: where the module is inside the airport (FR-007).
@override final  String? locationDetail;

/// Create a copy of AgentChannel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AgentChannelCopyWith<_AgentChannel> get copyWith => __$AgentChannelCopyWithImpl<_AgentChannel>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AgentChannel&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.available, available) || other.available == available)&&(identical(other.nextOpensAt, nextOpensAt) || other.nextOpensAt == nextOpensAt)&&(identical(other.estimatedWait, estimatedWait) || other.estimatedWait == estimatedWait)&&(identical(other.hours, hours) || other.hours == hours)&&(identical(other.locationName, locationName) || other.locationName == locationName)&&(identical(other.locationDetail, locationDetail) || other.locationDetail == locationDetail));
}


@override
int get hashCode {
    return Object.hash(runtimeType,kind,available,nextOpensAt,estimatedWait,hours,locationName,locationDetail);
}

@override
String toString() {
    return 'AgentChannel(kind: $kind, available: $available, nextOpensAt: $nextOpensAt, estimatedWait: $estimatedWait, hours: $hours, locationName: $locationName, locationDetail: $locationDetail)';
}


}

/// @nodoc
abstract mixin class _$AgentChannelCopyWith<$Res> implements $AgentChannelCopyWith<$Res> {
  factory _$AgentChannelCopyWith(_AgentChannel value, $Res Function(_AgentChannel) _then) = __$AgentChannelCopyWithImpl;
@override @useResult
$Res call({
 AgentChannelKind kind, bool available, DateTime? nextOpensAt, WaitEstimate? estimatedWait, String hours, String? locationName, String? locationDetail
});


@override $WaitEstimateCopyWith<$Res>? get estimatedWait;

}
/// @nodoc
class __$AgentChannelCopyWithImpl<$Res>
    implements _$AgentChannelCopyWith<$Res> {
  __$AgentChannelCopyWithImpl(this._self, this._then);

  final _AgentChannel _self;
  final $Res Function(_AgentChannel) _then;

/// Create a copy of AgentChannel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? available = null,Object? nextOpensAt = freezed,Object? estimatedWait = freezed,Object? hours = null,Object? locationName = freezed,Object? locationDetail = freezed,}) {
  return _then(_AgentChannel(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as AgentChannelKind,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,nextOpensAt: freezed == nextOpensAt ? _self.nextOpensAt : nextOpensAt // ignore: cast_nullable_to_non_nullable
as DateTime?,estimatedWait: freezed == estimatedWait ? _self.estimatedWait : estimatedWait // ignore: cast_nullable_to_non_nullable
as WaitEstimate?,hours: null == hours ? _self.hours : hours // ignore: cast_nullable_to_non_nullable
as String,locationName: freezed == locationName ? _self.locationName : locationName // ignore: cast_nullable_to_non_nullable
as String?,locationDetail: freezed == locationDetail ? _self.locationDetail : locationDetail // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of AgentChannel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WaitEstimateCopyWith<$Res>? get estimatedWait {
    if (_self.estimatedWait == null) {
    return null;
  }

  return $WaitEstimateCopyWith<$Res>(_self.estimatedWait!, (value) {
    return _then(_self.copyWith(estimatedWait: value));
  });
}
}

/// @nodoc
mixin _$EscalationCase {

 DateTime get openedAt; EscalationArrival get arrival;
/// Create a copy of EscalationCase
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EscalationCaseCopyWith<EscalationCase> get copyWith => _$EscalationCaseCopyWithImpl<EscalationCase>(this as EscalationCase, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as EscalationCase;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EscalationCase&&(identical(other.openedAt, _this.openedAt) || other.openedAt == _this.openedAt)&&(identical(other.arrival, _this.arrival) || other.arrival == _this.arrival));
}


@override
int get hashCode {
  final _this = this as EscalationCase;
  return Object.hash(runtimeType,_this.openedAt,_this.arrival);
}

@override
String toString() {
  final _this = this as EscalationCase;
  return 'EscalationCase(openedAt: ${_this.openedAt}, arrival: ${_this.arrival})';
}


}

/// @nodoc
abstract mixin class $EscalationCaseCopyWith<$Res>  {
  factory $EscalationCaseCopyWith(EscalationCase value, $Res Function(EscalationCase) _then) = _$EscalationCaseCopyWithImpl;
@useResult
$Res call({
 DateTime openedAt, EscalationArrival arrival
});




}
/// @nodoc
class _$EscalationCaseCopyWithImpl<$Res>
    implements $EscalationCaseCopyWith<$Res> {
  _$EscalationCaseCopyWithImpl(this._self, this._then);

  final EscalationCase _self;
  final $Res Function(EscalationCase) _then;

/// Create a copy of EscalationCase
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? openedAt = null,Object? arrival = null,}) {
  return _then(EscalationCase(
openedAt: null == openedAt ? _self.openedAt : openedAt // ignore: cast_nullable_to_non_nullable
as DateTime,arrival: null == arrival ? _self.arrival : arrival // ignore: cast_nullable_to_non_nullable
as EscalationArrival,
  ));
}

}


/// Adds pattern-matching-related methods to [EscalationCase].
extension EscalationCasePatterns on EscalationCase {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EscalationCase value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EscalationCase() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EscalationCase value)  $default,){
final _that = this;
switch (_that) {
case _EscalationCase():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EscalationCase value)?  $default,){
final _that = this;
switch (_that) {
case _EscalationCase() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime openedAt,  EscalationArrival arrival)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EscalationCase() when $default != null:
return $default(_that.openedAt,_that.arrival);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime openedAt,  EscalationArrival arrival)  $default,) {final _that = this;
switch (_that) {
case _EscalationCase():
return $default(_that.openedAt,_that.arrival);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime openedAt,  EscalationArrival arrival)?  $default,) {final _that = this;
switch (_that) {
case _EscalationCase() when $default != null:
return $default(_that.openedAt,_that.arrival);case _:
  return null;

}
}

}

/// @nodoc


class _EscalationCase implements EscalationCase {
  const _EscalationCase({required this.openedAt, required this.arrival});
  

@override final  DateTime openedAt;
@override final  EscalationArrival arrival;

/// Create a copy of EscalationCase
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EscalationCaseCopyWith<_EscalationCase> get copyWith => __$EscalationCaseCopyWithImpl<_EscalationCase>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EscalationCase&&(identical(other.openedAt, openedAt) || other.openedAt == openedAt)&&(identical(other.arrival, arrival) || other.arrival == arrival));
}


@override
int get hashCode {
    return Object.hash(runtimeType,openedAt,arrival);
}

@override
String toString() {
    return 'EscalationCase(openedAt: $openedAt, arrival: $arrival)';
}


}

/// @nodoc
abstract mixin class _$EscalationCaseCopyWith<$Res> implements $EscalationCaseCopyWith<$Res> {
  factory _$EscalationCaseCopyWith(_EscalationCase value, $Res Function(_EscalationCase) _then) = __$EscalationCaseCopyWithImpl;
@override @useResult
$Res call({
 DateTime openedAt, EscalationArrival arrival
});




}
/// @nodoc
class __$EscalationCaseCopyWithImpl<$Res>
    implements _$EscalationCaseCopyWith<$Res> {
  __$EscalationCaseCopyWithImpl(this._self, this._then);

  final _EscalationCase _self;
  final $Res Function(_EscalationCase) _then;

/// Create a copy of EscalationCase
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? openedAt = null,Object? arrival = null,}) {
  return _then(_EscalationCase(
openedAt: null == openedAt ? _self.openedAt : openedAt // ignore: cast_nullable_to_non_nullable
as DateTime,arrival: null == arrival ? _self.arrival : arrival // ignore: cast_nullable_to_non_nullable
as EscalationArrival,
  ));
}


}

/// @nodoc
mixin _$EscalationOutcome {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EscalationOutcome);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'EscalationOutcome()';
}


}

/// @nodoc
class $EscalationOutcomeCopyWith<$Res>  {
$EscalationOutcomeCopyWith(EscalationOutcome _, $Res Function(EscalationOutcome) __);
}


/// Adds pattern-matching-related methods to [EscalationOutcome].
extension EscalationOutcomePatterns on EscalationOutcome {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( EscalationCredentialIssued value)?  credentialIssued,TResult Function( EscalationDeclined value)?  declined,TResult Function( EscalationAttemptsReset value)?  attemptsReset,required TResult orElse(),}){
final _that = this;
switch (_that) {
case EscalationCredentialIssued() when credentialIssued != null:
return credentialIssued(_that);case EscalationDeclined() when declined != null:
return declined(_that);case EscalationAttemptsReset() when attemptsReset != null:
return attemptsReset(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( EscalationCredentialIssued value)  credentialIssued,required TResult Function( EscalationDeclined value)  declined,required TResult Function( EscalationAttemptsReset value)  attemptsReset,}){
final _that = this;
switch (_that) {
case EscalationCredentialIssued():
return credentialIssued(_that);case EscalationDeclined():
return declined(_that);case EscalationAttemptsReset():
return attemptsReset(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( EscalationCredentialIssued value)?  credentialIssued,TResult? Function( EscalationDeclined value)?  declined,TResult? Function( EscalationAttemptsReset value)?  attemptsReset,}){
final _that = this;
switch (_that) {
case EscalationCredentialIssued() when credentialIssued != null:
return credentialIssued(_that);case EscalationDeclined() when declined != null:
return declined(_that);case EscalationAttemptsReset() when attemptsReset != null:
return attemptsReset(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  credentialIssued,TResult Function()?  declined,TResult Function( AttemptCounterScope scope)?  attemptsReset,required TResult orElse(),}) {final _that = this;
switch (_that) {
case EscalationCredentialIssued() when credentialIssued != null:
return credentialIssued();case EscalationDeclined() when declined != null:
return declined();case EscalationAttemptsReset() when attemptsReset != null:
return attemptsReset(_that.scope);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  credentialIssued,required TResult Function()  declined,required TResult Function( AttemptCounterScope scope)  attemptsReset,}) {final _that = this;
switch (_that) {
case EscalationCredentialIssued():
return credentialIssued();case EscalationDeclined():
return declined();case EscalationAttemptsReset():
return attemptsReset(_that.scope);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  credentialIssued,TResult? Function()?  declined,TResult? Function( AttemptCounterScope scope)?  attemptsReset,}) {final _that = this;
switch (_that) {
case EscalationCredentialIssued() when credentialIssued != null:
return credentialIssued();case EscalationDeclined() when declined != null:
return declined();case EscalationAttemptsReset() when attemptsReset != null:
return attemptsReset(_that.scope);case _:
  return null;

}
}

}

/// @nodoc


class EscalationCredentialIssued implements EscalationOutcome {
  const EscalationCredentialIssued();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EscalationCredentialIssued);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'EscalationOutcome.credentialIssued()';
}


}




/// @nodoc


class EscalationDeclined implements EscalationOutcome {
  const EscalationDeclined();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EscalationDeclined);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'EscalationOutcome.declined()';
}


}




/// @nodoc


class EscalationAttemptsReset implements EscalationOutcome {
  const EscalationAttemptsReset({required this.scope});
  

 final  AttemptCounterScope scope;

/// Create a copy of EscalationOutcome
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EscalationAttemptsResetCopyWith<EscalationAttemptsReset> get copyWith => _$EscalationAttemptsResetCopyWithImpl<EscalationAttemptsReset>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EscalationAttemptsReset&&(identical(other.scope, scope) || other.scope == scope));
}


@override
int get hashCode {
    return Object.hash(runtimeType,scope);
}

@override
String toString() {
    return 'EscalationOutcome.attemptsReset(scope: $scope)';
}


}

/// @nodoc
abstract mixin class $EscalationAttemptsResetCopyWith<$Res> implements $EscalationOutcomeCopyWith<$Res> {
  factory $EscalationAttemptsResetCopyWith(EscalationAttemptsReset value, $Res Function(EscalationAttemptsReset) _then) = _$EscalationAttemptsResetCopyWithImpl;
@useResult
$Res call({
 AttemptCounterScope scope
});




}
/// @nodoc
class _$EscalationAttemptsResetCopyWithImpl<$Res>
    implements $EscalationAttemptsResetCopyWith<$Res> {
  _$EscalationAttemptsResetCopyWithImpl(this._self, this._then);

  final EscalationAttemptsReset _self;
  final $Res Function(EscalationAttemptsReset) _then;

/// Create a copy of EscalationOutcome
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? scope = null,}) {
  return _then(EscalationAttemptsReset(
scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as AttemptCounterScope,
  ));
}


}

/// @nodoc
mixin _$EscalationStatus {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EscalationStatus);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'EscalationStatus()';
}


}

/// @nodoc
class $EscalationStatusCopyWith<$Res>  {
$EscalationStatusCopyWith(EscalationStatus _, $Res Function(EscalationStatus) __);
}


/// Adds pattern-matching-related methods to [EscalationStatus].
extension EscalationStatusPatterns on EscalationStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( EscalationOpen value)?  open,TResult Function( EscalationResolved value)?  resolved,TResult Function( EscalationExpired value)?  expired,required TResult orElse(),}){
final _that = this;
switch (_that) {
case EscalationOpen() when open != null:
return open(_that);case EscalationResolved() when resolved != null:
return resolved(_that);case EscalationExpired() when expired != null:
return expired(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( EscalationOpen value)  open,required TResult Function( EscalationResolved value)  resolved,required TResult Function( EscalationExpired value)  expired,}){
final _that = this;
switch (_that) {
case EscalationOpen():
return open(_that);case EscalationResolved():
return resolved(_that);case EscalationExpired():
return expired(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( EscalationOpen value)?  open,TResult? Function( EscalationResolved value)?  resolved,TResult? Function( EscalationExpired value)?  expired,}){
final _that = this;
switch (_that) {
case EscalationOpen() when open != null:
return open(_that);case EscalationResolved() when resolved != null:
return resolved(_that);case EscalationExpired() when expired != null:
return expired(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( EscalationCase escalation,  List<AgentChannel> channels)?  open,TResult Function( EscalationOutcome outcome)?  resolved,TResult Function()?  expired,required TResult orElse(),}) {final _that = this;
switch (_that) {
case EscalationOpen() when open != null:
return open(_that.escalation,_that.channels);case EscalationResolved() when resolved != null:
return resolved(_that.outcome);case EscalationExpired() when expired != null:
return expired();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( EscalationCase escalation,  List<AgentChannel> channels)  open,required TResult Function( EscalationOutcome outcome)  resolved,required TResult Function()  expired,}) {final _that = this;
switch (_that) {
case EscalationOpen():
return open(_that.escalation,_that.channels);case EscalationResolved():
return resolved(_that.outcome);case EscalationExpired():
return expired();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( EscalationCase escalation,  List<AgentChannel> channels)?  open,TResult? Function( EscalationOutcome outcome)?  resolved,TResult? Function()?  expired,}) {final _that = this;
switch (_that) {
case EscalationOpen() when open != null:
return open(_that.escalation,_that.channels);case EscalationResolved() when resolved != null:
return resolved(_that.outcome);case EscalationExpired() when expired != null:
return expired();case _:
  return null;

}
}

}

/// @nodoc


class EscalationOpen implements EscalationStatus {
  const EscalationOpen({required this.escalation, required  List<AgentChannel> channels}): _channels = channels;
  

 final  EscalationCase escalation;
 final  List<AgentChannel> _channels;
 List<AgentChannel> get channels {
  if (_channels is EqualUnmodifiableListView) return _channels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_channels);
}


/// Create a copy of EscalationStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EscalationOpenCopyWith<EscalationOpen> get copyWith => _$EscalationOpenCopyWithImpl<EscalationOpen>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EscalationOpen&&(identical(other.escalation, escalation) || other.escalation == escalation)&&const DeepCollectionEquality().equals(other.channels, _channels));
}


@override
int get hashCode {
    return Object.hash(runtimeType,escalation,const DeepCollectionEquality().hash(_channels));
}

@override
String toString() {
    return 'EscalationStatus.open(escalation: $escalation, channels: $channels)';
}


}

/// @nodoc
abstract mixin class $EscalationOpenCopyWith<$Res> implements $EscalationStatusCopyWith<$Res> {
  factory $EscalationOpenCopyWith(EscalationOpen value, $Res Function(EscalationOpen) _then) = _$EscalationOpenCopyWithImpl;
@useResult
$Res call({
 EscalationCase escalation, List<AgentChannel> channels
});


$EscalationCaseCopyWith<$Res> get escalation;

}
/// @nodoc
class _$EscalationOpenCopyWithImpl<$Res>
    implements $EscalationOpenCopyWith<$Res> {
  _$EscalationOpenCopyWithImpl(this._self, this._then);

  final EscalationOpen _self;
  final $Res Function(EscalationOpen) _then;

/// Create a copy of EscalationStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? escalation = null,Object? channels = null,}) {
  return _then(EscalationOpen(
escalation: null == escalation ? _self.escalation : escalation // ignore: cast_nullable_to_non_nullable
as EscalationCase,channels: null == channels ? _self._channels : channels // ignore: cast_nullable_to_non_nullable
as List<AgentChannel>,
  ));
}

/// Create a copy of EscalationStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EscalationCaseCopyWith<$Res> get escalation {
  
  return $EscalationCaseCopyWith<$Res>(_self.escalation, (value) {
    return _then(_self.copyWith(escalation: value));
  });
}
}

/// @nodoc


class EscalationResolved implements EscalationStatus {
  const EscalationResolved({required this.outcome});
  

 final  EscalationOutcome outcome;

/// Create a copy of EscalationStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EscalationResolvedCopyWith<EscalationResolved> get copyWith => _$EscalationResolvedCopyWithImpl<EscalationResolved>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EscalationResolved&&(identical(other.outcome, outcome) || other.outcome == outcome));
}


@override
int get hashCode {
    return Object.hash(runtimeType,outcome);
}

@override
String toString() {
    return 'EscalationStatus.resolved(outcome: $outcome)';
}


}

/// @nodoc
abstract mixin class $EscalationResolvedCopyWith<$Res> implements $EscalationStatusCopyWith<$Res> {
  factory $EscalationResolvedCopyWith(EscalationResolved value, $Res Function(EscalationResolved) _then) = _$EscalationResolvedCopyWithImpl;
@useResult
$Res call({
 EscalationOutcome outcome
});


$EscalationOutcomeCopyWith<$Res> get outcome;

}
/// @nodoc
class _$EscalationResolvedCopyWithImpl<$Res>
    implements $EscalationResolvedCopyWith<$Res> {
  _$EscalationResolvedCopyWithImpl(this._self, this._then);

  final EscalationResolved _self;
  final $Res Function(EscalationResolved) _then;

/// Create a copy of EscalationStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? outcome = null,}) {
  return _then(EscalationResolved(
outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as EscalationOutcome,
  ));
}

/// Create a copy of EscalationStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EscalationOutcomeCopyWith<$Res> get outcome {
  
  return $EscalationOutcomeCopyWith<$Res>(_self.outcome, (value) {
    return _then(_self.copyWith(outcome: value));
  });
}
}

/// @nodoc


class EscalationExpired implements EscalationStatus {
  const EscalationExpired();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EscalationExpired);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'EscalationStatus.expired()';
}


}




// dart format on
