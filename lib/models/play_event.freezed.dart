// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'play_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlayEvent {

 Track get track; DateTime get playedAt; DeviceKind get device;
/// Create a copy of PlayEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayEventCopyWith<PlayEvent> get copyWith => _$PlayEventCopyWithImpl<PlayEvent>(this as PlayEvent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayEvent&&(identical(other.track, track) || other.track == track)&&(identical(other.playedAt, playedAt) || other.playedAt == playedAt)&&(identical(other.device, device) || other.device == device));
}


@override
int get hashCode => Object.hash(runtimeType,track,playedAt,device);

@override
String toString() {
  return 'PlayEvent(track: $track, playedAt: $playedAt, device: $device)';
}


}

/// @nodoc
abstract mixin class $PlayEventCopyWith<$Res>  {
  factory $PlayEventCopyWith(PlayEvent value, $Res Function(PlayEvent) _then) = _$PlayEventCopyWithImpl;
@useResult
$Res call({
 Track track, DateTime playedAt, DeviceKind device
});


$TrackCopyWith<$Res> get track;

}
/// @nodoc
class _$PlayEventCopyWithImpl<$Res>
    implements $PlayEventCopyWith<$Res> {
  _$PlayEventCopyWithImpl(this._self, this._then);

  final PlayEvent _self;
  final $Res Function(PlayEvent) _then;

/// Create a copy of PlayEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? track = null,Object? playedAt = null,Object? device = null,}) {
  return _then(_self.copyWith(
track: null == track ? _self.track : track // ignore: cast_nullable_to_non_nullable
as Track,playedAt: null == playedAt ? _self.playedAt : playedAt // ignore: cast_nullable_to_non_nullable
as DateTime,device: null == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as DeviceKind,
  ));
}
/// Create a copy of PlayEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrackCopyWith<$Res> get track {
  
  return $TrackCopyWith<$Res>(_self.track, (value) {
    return _then(_self.copyWith(track: value));
  });
}
}


/// Adds pattern-matching-related methods to [PlayEvent].
extension PlayEventPatterns on PlayEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayEvent value)  $default,){
final _that = this;
switch (_that) {
case _PlayEvent():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayEvent value)?  $default,){
final _that = this;
switch (_that) {
case _PlayEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Track track,  DateTime playedAt,  DeviceKind device)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayEvent() when $default != null:
return $default(_that.track,_that.playedAt,_that.device);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Track track,  DateTime playedAt,  DeviceKind device)  $default,) {final _that = this;
switch (_that) {
case _PlayEvent():
return $default(_that.track,_that.playedAt,_that.device);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Track track,  DateTime playedAt,  DeviceKind device)?  $default,) {final _that = this;
switch (_that) {
case _PlayEvent() when $default != null:
return $default(_that.track,_that.playedAt,_that.device);case _:
  return null;

}
}

}

/// @nodoc


class _PlayEvent implements PlayEvent {
  const _PlayEvent({required this.track, required this.playedAt, required this.device});
  

@override final  Track track;
@override final  DateTime playedAt;
@override final  DeviceKind device;

/// Create a copy of PlayEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayEventCopyWith<_PlayEvent> get copyWith => __$PlayEventCopyWithImpl<_PlayEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayEvent&&(identical(other.track, track) || other.track == track)&&(identical(other.playedAt, playedAt) || other.playedAt == playedAt)&&(identical(other.device, device) || other.device == device));
}


@override
int get hashCode => Object.hash(runtimeType,track,playedAt,device);

@override
String toString() {
  return 'PlayEvent(track: $track, playedAt: $playedAt, device: $device)';
}


}

/// @nodoc
abstract mixin class _$PlayEventCopyWith<$Res> implements $PlayEventCopyWith<$Res> {
  factory _$PlayEventCopyWith(_PlayEvent value, $Res Function(_PlayEvent) _then) = __$PlayEventCopyWithImpl;
@override @useResult
$Res call({
 Track track, DateTime playedAt, DeviceKind device
});


@override $TrackCopyWith<$Res> get track;

}
/// @nodoc
class __$PlayEventCopyWithImpl<$Res>
    implements _$PlayEventCopyWith<$Res> {
  __$PlayEventCopyWithImpl(this._self, this._then);

  final _PlayEvent _self;
  final $Res Function(_PlayEvent) _then;

/// Create a copy of PlayEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? track = null,Object? playedAt = null,Object? device = null,}) {
  return _then(_PlayEvent(
track: null == track ? _self.track : track // ignore: cast_nullable_to_non_nullable
as Track,playedAt: null == playedAt ? _self.playedAt : playedAt // ignore: cast_nullable_to_non_nullable
as DateTime,device: null == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as DeviceKind,
  ));
}

/// Create a copy of PlayEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrackCopyWith<$Res> get track {
  
  return $TrackCopyWith<$Res>(_self.track, (value) {
    return _then(_self.copyWith(track: value));
  });
}
}

// dart format on
