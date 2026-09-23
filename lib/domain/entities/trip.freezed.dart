// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trip.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Airport {

 String get code; String get city;
/// Create a copy of Airport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AirportCopyWith<Airport> get copyWith => _$AirportCopyWithImpl<Airport>(this as Airport, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Airport;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Airport&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.city, _this.city) || other.city == _this.city));
}


@override
int get hashCode {
  final _this = this as Airport;
  return Object.hash(runtimeType,_this.code,_this.city);
}

@override
String toString() {
  final _this = this as Airport;
  return 'Airport(code: ${_this.code}, city: ${_this.city})';
}


}

/// @nodoc
abstract mixin class $AirportCopyWith<$Res>  {
  factory $AirportCopyWith(Airport value, $Res Function(Airport) _then) = _$AirportCopyWithImpl;
@useResult
$Res call({
 String code, String city
});




}
/// @nodoc
class _$AirportCopyWithImpl<$Res>
    implements $AirportCopyWith<$Res> {
  _$AirportCopyWithImpl(this._self, this._then);

  final Airport _self;
  final $Res Function(Airport) _then;

/// Create a copy of Airport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? city = null,}) {
  return _then(Airport(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Airport].
extension AirportPatterns on Airport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Airport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Airport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Airport value)  $default,){
final _that = this;
switch (_that) {
case _Airport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Airport value)?  $default,){
final _that = this;
switch (_that) {
case _Airport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String city)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Airport() when $default != null:
return $default(_that.code,_that.city);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String city)  $default,) {final _that = this;
switch (_that) {
case _Airport():
return $default(_that.code,_that.city);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String city)?  $default,) {final _that = this;
switch (_that) {
case _Airport() when $default != null:
return $default(_that.code,_that.city);case _:
  return null;

}
}

}

/// @nodoc


class _Airport implements Airport {
  const _Airport({required this.code, required this.city});
  

@override final  String code;
@override final  String city;

/// Create a copy of Airport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AirportCopyWith<_Airport> get copyWith => __$AirportCopyWithImpl<_Airport>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Airport&&(identical(other.code, code) || other.code == code)&&(identical(other.city, city) || other.city == city));
}


@override
int get hashCode {
    return Object.hash(runtimeType,code,city);
}

@override
String toString() {
    return 'Airport(code: $code, city: $city)';
}


}

/// @nodoc
abstract mixin class _$AirportCopyWith<$Res> implements $AirportCopyWith<$Res> {
  factory _$AirportCopyWith(_Airport value, $Res Function(_Airport) _then) = __$AirportCopyWithImpl;
@override @useResult
$Res call({
 String code, String city
});




}
/// @nodoc
class __$AirportCopyWithImpl<$Res>
    implements _$AirportCopyWith<$Res> {
  __$AirportCopyWithImpl(this._self, this._then);

  final _Airport _self;
  final $Res Function(_Airport) _then;

/// Create a copy of Airport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? city = null,}) {
  return _then(_Airport(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$Trip {

/// Opaque. Never reaches an analytics event.
 String get id; Airport get origin; Airport get destination;/// For example "AV 9201". Display only, never an event.
 String get flightNumber; DateTime get departureUtc;/// The departure airport's UTC offset on that date (research.md §5).
 Duration get departureOffset; TripStatus get status;/// False when the airline has no live integration for this flight
/// (FR-006).
 bool get live; String? get gate; String? get seat;/// Set when this segment continues on a connection.
 Airport? get connectsTo;
/// Create a copy of Trip
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TripCopyWith<Trip> get copyWith => _$TripCopyWithImpl<Trip>(this as Trip, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Trip;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Trip&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.origin, _this.origin) || other.origin == _this.origin)&&(identical(other.destination, _this.destination) || other.destination == _this.destination)&&(identical(other.flightNumber, _this.flightNumber) || other.flightNumber == _this.flightNumber)&&(identical(other.departureUtc, _this.departureUtc) || other.departureUtc == _this.departureUtc)&&(identical(other.departureOffset, _this.departureOffset) || other.departureOffset == _this.departureOffset)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.live, _this.live) || other.live == _this.live)&&(identical(other.gate, _this.gate) || other.gate == _this.gate)&&(identical(other.seat, _this.seat) || other.seat == _this.seat)&&(identical(other.connectsTo, _this.connectsTo) || other.connectsTo == _this.connectsTo));
}


@override
int get hashCode {
  final _this = this as Trip;
  return Object.hash(runtimeType,_this.id,_this.origin,_this.destination,_this.flightNumber,_this.departureUtc,_this.departureOffset,_this.status,_this.live,_this.gate,_this.seat,_this.connectsTo);
}

@override
String toString() {
  final _this = this as Trip;
  return 'Trip(id: ${_this.id}, origin: ${_this.origin}, destination: ${_this.destination}, flightNumber: ${_this.flightNumber}, departureUtc: ${_this.departureUtc}, departureOffset: ${_this.departureOffset}, status: ${_this.status}, live: ${_this.live}, gate: ${_this.gate}, seat: ${_this.seat}, connectsTo: ${_this.connectsTo})';
}


}

/// @nodoc
abstract mixin class $TripCopyWith<$Res>  {
  factory $TripCopyWith(Trip value, $Res Function(Trip) _then) = _$TripCopyWithImpl;
@useResult
$Res call({
 String id, Airport origin, Airport destination, String flightNumber, DateTime departureUtc, Duration departureOffset, TripStatus status, bool live, String? gate, String? seat, Airport? connectsTo
});


$AirportCopyWith<$Res> get origin;$AirportCopyWith<$Res> get destination;$AirportCopyWith<$Res>? get connectsTo;

}
/// @nodoc
class _$TripCopyWithImpl<$Res>
    implements $TripCopyWith<$Res> {
  _$TripCopyWithImpl(this._self, this._then);

  final Trip _self;
  final $Res Function(Trip) _then;

/// Create a copy of Trip
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? origin = null,Object? destination = null,Object? flightNumber = null,Object? departureUtc = null,Object? departureOffset = null,Object? status = null,Object? live = null,Object? gate = freezed,Object? seat = freezed,Object? connectsTo = freezed,}) {
  return _then(Trip(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as Airport,destination: null == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as Airport,flightNumber: null == flightNumber ? _self.flightNumber : flightNumber // ignore: cast_nullable_to_non_nullable
as String,departureUtc: null == departureUtc ? _self.departureUtc : departureUtc // ignore: cast_nullable_to_non_nullable
as DateTime,departureOffset: null == departureOffset ? _self.departureOffset : departureOffset // ignore: cast_nullable_to_non_nullable
as Duration,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TripStatus,live: null == live ? _self.live : live // ignore: cast_nullable_to_non_nullable
as bool,gate: freezed == gate ? _self.gate : gate // ignore: cast_nullable_to_non_nullable
as String?,seat: freezed == seat ? _self.seat : seat // ignore: cast_nullable_to_non_nullable
as String?,connectsTo: freezed == connectsTo ? _self.connectsTo : connectsTo // ignore: cast_nullable_to_non_nullable
as Airport?,
  ));
}
/// Create a copy of Trip
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AirportCopyWith<$Res> get origin {
  
  return $AirportCopyWith<$Res>(_self.origin, (value) {
    return _then(_self.copyWith(origin: value));
  });
}/// Create a copy of Trip
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AirportCopyWith<$Res> get destination {
  
  return $AirportCopyWith<$Res>(_self.destination, (value) {
    return _then(_self.copyWith(destination: value));
  });
}/// Create a copy of Trip
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AirportCopyWith<$Res>? get connectsTo {
    if (_self.connectsTo == null) {
    return null;
  }

  return $AirportCopyWith<$Res>(_self.connectsTo!, (value) {
    return _then(_self.copyWith(connectsTo: value));
  });
}
}


/// Adds pattern-matching-related methods to [Trip].
extension TripPatterns on Trip {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Trip value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Trip() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Trip value)  $default,){
final _that = this;
switch (_that) {
case _Trip():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Trip value)?  $default,){
final _that = this;
switch (_that) {
case _Trip() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  Airport origin,  Airport destination,  String flightNumber,  DateTime departureUtc,  Duration departureOffset,  TripStatus status,  bool live,  String? gate,  String? seat,  Airport? connectsTo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Trip() when $default != null:
return $default(_that.id,_that.origin,_that.destination,_that.flightNumber,_that.departureUtc,_that.departureOffset,_that.status,_that.live,_that.gate,_that.seat,_that.connectsTo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  Airport origin,  Airport destination,  String flightNumber,  DateTime departureUtc,  Duration departureOffset,  TripStatus status,  bool live,  String? gate,  String? seat,  Airport? connectsTo)  $default,) {final _that = this;
switch (_that) {
case _Trip():
return $default(_that.id,_that.origin,_that.destination,_that.flightNumber,_that.departureUtc,_that.departureOffset,_that.status,_that.live,_that.gate,_that.seat,_that.connectsTo);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  Airport origin,  Airport destination,  String flightNumber,  DateTime departureUtc,  Duration departureOffset,  TripStatus status,  bool live,  String? gate,  String? seat,  Airport? connectsTo)?  $default,) {final _that = this;
switch (_that) {
case _Trip() when $default != null:
return $default(_that.id,_that.origin,_that.destination,_that.flightNumber,_that.departureUtc,_that.departureOffset,_that.status,_that.live,_that.gate,_that.seat,_that.connectsTo);case _:
  return null;

}
}

}

/// @nodoc


class _Trip extends Trip {
  const _Trip({required this.id, required this.origin, required this.destination, required this.flightNumber, required this.departureUtc, required this.departureOffset, required this.status, required this.live, this.gate, this.seat, this.connectsTo}): super._();
  

/// Opaque. Never reaches an analytics event.
@override final  String id;
@override final  Airport origin;
@override final  Airport destination;
/// For example "AV 9201". Display only, never an event.
@override final  String flightNumber;
@override final  DateTime departureUtc;
/// The departure airport's UTC offset on that date (research.md §5).
@override final  Duration departureOffset;
@override final  TripStatus status;
/// False when the airline has no live integration for this flight
/// (FR-006).
@override final  bool live;
@override final  String? gate;
@override final  String? seat;
/// Set when this segment continues on a connection.
@override final  Airport? connectsTo;

/// Create a copy of Trip
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TripCopyWith<_Trip> get copyWith => __$TripCopyWithImpl<_Trip>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Trip&&(identical(other.id, id) || other.id == id)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.flightNumber, flightNumber) || other.flightNumber == flightNumber)&&(identical(other.departureUtc, departureUtc) || other.departureUtc == departureUtc)&&(identical(other.departureOffset, departureOffset) || other.departureOffset == departureOffset)&&(identical(other.status, status) || other.status == status)&&(identical(other.live, live) || other.live == live)&&(identical(other.gate, gate) || other.gate == gate)&&(identical(other.seat, seat) || other.seat == seat)&&(identical(other.connectsTo, connectsTo) || other.connectsTo == connectsTo));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,origin,destination,flightNumber,departureUtc,departureOffset,status,live,gate,seat,connectsTo);
}

@override
String toString() {
    return 'Trip(id: $id, origin: $origin, destination: $destination, flightNumber: $flightNumber, departureUtc: $departureUtc, departureOffset: $departureOffset, status: $status, live: $live, gate: $gate, seat: $seat, connectsTo: $connectsTo)';
}


}

/// @nodoc
abstract mixin class _$TripCopyWith<$Res> implements $TripCopyWith<$Res> {
  factory _$TripCopyWith(_Trip value, $Res Function(_Trip) _then) = __$TripCopyWithImpl;
@override @useResult
$Res call({
 String id, Airport origin, Airport destination, String flightNumber, DateTime departureUtc, Duration departureOffset, TripStatus status, bool live, String? gate, String? seat, Airport? connectsTo
});


@override $AirportCopyWith<$Res> get origin;@override $AirportCopyWith<$Res> get destination;@override $AirportCopyWith<$Res>? get connectsTo;

}
/// @nodoc
class __$TripCopyWithImpl<$Res>
    implements _$TripCopyWith<$Res> {
  __$TripCopyWithImpl(this._self, this._then);

  final _Trip _self;
  final $Res Function(_Trip) _then;

/// Create a copy of Trip
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? origin = null,Object? destination = null,Object? flightNumber = null,Object? departureUtc = null,Object? departureOffset = null,Object? status = null,Object? live = null,Object? gate = freezed,Object? seat = freezed,Object? connectsTo = freezed,}) {
  return _then(_Trip(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as Airport,destination: null == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as Airport,flightNumber: null == flightNumber ? _self.flightNumber : flightNumber // ignore: cast_nullable_to_non_nullable
as String,departureUtc: null == departureUtc ? _self.departureUtc : departureUtc // ignore: cast_nullable_to_non_nullable
as DateTime,departureOffset: null == departureOffset ? _self.departureOffset : departureOffset // ignore: cast_nullable_to_non_nullable
as Duration,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TripStatus,live: null == live ? _self.live : live // ignore: cast_nullable_to_non_nullable
as bool,gate: freezed == gate ? _self.gate : gate // ignore: cast_nullable_to_non_nullable
as String?,seat: freezed == seat ? _self.seat : seat // ignore: cast_nullable_to_non_nullable
as String?,connectsTo: freezed == connectsTo ? _self.connectsTo : connectsTo // ignore: cast_nullable_to_non_nullable
as Airport?,
  ));
}

/// Create a copy of Trip
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AirportCopyWith<$Res> get origin {
  
  return $AirportCopyWith<$Res>(_self.origin, (value) {
    return _then(_self.copyWith(origin: value));
  });
}/// Create a copy of Trip
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AirportCopyWith<$Res> get destination {
  
  return $AirportCopyWith<$Res>(_self.destination, (value) {
    return _then(_self.copyWith(destination: value));
  });
}/// Create a copy of Trip
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AirportCopyWith<$Res>? get connectsTo {
    if (_self.connectsTo == null) {
    return null;
  }

  return $AirportCopyWith<$Res>(_self.connectsTo!, (value) {
    return _then(_self.copyWith(connectsTo: value));
  });
}
}

/// @nodoc
mixin _$TripsSnapshot {

 Trip? get next;/// Newest first, domestic only, at most 90 days old.
 List<Trip> get history; DateTime get fetchedAt;
/// Create a copy of TripsSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TripsSnapshotCopyWith<TripsSnapshot> get copyWith => _$TripsSnapshotCopyWithImpl<TripsSnapshot>(this as TripsSnapshot, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TripsSnapshot;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TripsSnapshot&&(identical(other.next, _this.next) || other.next == _this.next)&&const DeepCollectionEquality().equals(other.history, _this.history)&&(identical(other.fetchedAt, _this.fetchedAt) || other.fetchedAt == _this.fetchedAt));
}


@override
int get hashCode {
  final _this = this as TripsSnapshot;
  return Object.hash(runtimeType,_this.next,const DeepCollectionEquality().hash(_this.history),_this.fetchedAt);
}

@override
String toString() {
  final _this = this as TripsSnapshot;
  return 'TripsSnapshot(next: ${_this.next}, history: ${_this.history}, fetchedAt: ${_this.fetchedAt})';
}


}

/// @nodoc
abstract mixin class $TripsSnapshotCopyWith<$Res>  {
  factory $TripsSnapshotCopyWith(TripsSnapshot value, $Res Function(TripsSnapshot) _then) = _$TripsSnapshotCopyWithImpl;
@useResult
$Res call({
 Trip? next, List<Trip> history, DateTime fetchedAt
});


$TripCopyWith<$Res>? get next;

}
/// @nodoc
class _$TripsSnapshotCopyWithImpl<$Res>
    implements $TripsSnapshotCopyWith<$Res> {
  _$TripsSnapshotCopyWithImpl(this._self, this._then);

  final TripsSnapshot _self;
  final $Res Function(TripsSnapshot) _then;

/// Create a copy of TripsSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? next = freezed,Object? history = null,Object? fetchedAt = null,}) {
  return _then(TripsSnapshot(
next: freezed == next ? _self.next : next // ignore: cast_nullable_to_non_nullable
as Trip?,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as List<Trip>,fetchedAt: null == fetchedAt ? _self.fetchedAt : fetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of TripsSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TripCopyWith<$Res>? get next {
    if (_self.next == null) {
    return null;
  }

  return $TripCopyWith<$Res>(_self.next!, (value) {
    return _then(_self.copyWith(next: value));
  });
}
}


/// Adds pattern-matching-related methods to [TripsSnapshot].
extension TripsSnapshotPatterns on TripsSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TripsSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TripsSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TripsSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _TripsSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TripsSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _TripsSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Trip? next,  List<Trip> history,  DateTime fetchedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TripsSnapshot() when $default != null:
return $default(_that.next,_that.history,_that.fetchedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Trip? next,  List<Trip> history,  DateTime fetchedAt)  $default,) {final _that = this;
switch (_that) {
case _TripsSnapshot():
return $default(_that.next,_that.history,_that.fetchedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Trip? next,  List<Trip> history,  DateTime fetchedAt)?  $default,) {final _that = this;
switch (_that) {
case _TripsSnapshot() when $default != null:
return $default(_that.next,_that.history,_that.fetchedAt);case _:
  return null;

}
}

}

/// @nodoc


class _TripsSnapshot implements TripsSnapshot {
  const _TripsSnapshot({this.next, required  List<Trip> history, required this.fetchedAt}): _history = history;
  

@override final  Trip? next;
/// Newest first, domestic only, at most 90 days old.
 final  List<Trip> _history;
/// Newest first, domestic only, at most 90 days old.
@override List<Trip> get history {
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_history);
}

@override final  DateTime fetchedAt;

/// Create a copy of TripsSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TripsSnapshotCopyWith<_TripsSnapshot> get copyWith => __$TripsSnapshotCopyWithImpl<_TripsSnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TripsSnapshot&&(identical(other.next, next) || other.next == next)&&const DeepCollectionEquality().equals(other.history, _history)&&(identical(other.fetchedAt, fetchedAt) || other.fetchedAt == fetchedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,next,const DeepCollectionEquality().hash(_history),fetchedAt);
}

@override
String toString() {
    return 'TripsSnapshot(next: $next, history: $history, fetchedAt: $fetchedAt)';
}


}

/// @nodoc
abstract mixin class _$TripsSnapshotCopyWith<$Res> implements $TripsSnapshotCopyWith<$Res> {
  factory _$TripsSnapshotCopyWith(_TripsSnapshot value, $Res Function(_TripsSnapshot) _then) = __$TripsSnapshotCopyWithImpl;
@override @useResult
$Res call({
 Trip? next, List<Trip> history, DateTime fetchedAt
});


@override $TripCopyWith<$Res>? get next;

}
/// @nodoc
class __$TripsSnapshotCopyWithImpl<$Res>
    implements _$TripsSnapshotCopyWith<$Res> {
  __$TripsSnapshotCopyWithImpl(this._self, this._then);

  final _TripsSnapshot _self;
  final $Res Function(_TripsSnapshot) _then;

/// Create a copy of TripsSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? next = freezed,Object? history = null,Object? fetchedAt = null,}) {
  return _then(_TripsSnapshot(
next: freezed == next ? _self.next : next // ignore: cast_nullable_to_non_nullable
as Trip?,history: null == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<Trip>,fetchedAt: null == fetchedAt ? _self.fetchedAt : fetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of TripsSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TripCopyWith<$Res>? get next {
    if (_self.next == null) {
    return null;
  }

  return $TripCopyWith<$Res>(_self.next!, (value) {
    return _then(_self.copyWith(next: value));
  });
}
}

// dart format on
