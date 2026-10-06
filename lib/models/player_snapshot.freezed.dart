// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player_snapshot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SleepTimer {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SleepTimer);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SleepTimer()';
}


}

/// @nodoc
class $SleepTimerCopyWith<$Res>  {
$SleepTimerCopyWith(SleepTimer _, $Res Function(SleepTimer) __);
}


/// Adds pattern-matching-related methods to [SleepTimer].
extension SleepTimerPatterns on SleepTimer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SleepAfterMinutes value)?  minutes,TResult Function( SleepAtEndOfTrack value)?  endOfTrack,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SleepAfterMinutes() when minutes != null:
return minutes(_that);case SleepAtEndOfTrack() when endOfTrack != null:
return endOfTrack(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SleepAfterMinutes value)  minutes,required TResult Function( SleepAtEndOfTrack value)  endOfTrack,}){
final _that = this;
switch (_that) {
case SleepAfterMinutes():
return minutes(_that);case SleepAtEndOfTrack():
return endOfTrack(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SleepAfterMinutes value)?  minutes,TResult? Function( SleepAtEndOfTrack value)?  endOfTrack,}){
final _that = this;
switch (_that) {
case SleepAfterMinutes() when minutes != null:
return minutes(_that);case SleepAtEndOfTrack() when endOfTrack != null:
return endOfTrack(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int minutes)?  minutes,TResult Function()?  endOfTrack,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SleepAfterMinutes() when minutes != null:
return minutes(_that.minutes);case SleepAtEndOfTrack() when endOfTrack != null:
return endOfTrack();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int minutes)  minutes,required TResult Function()  endOfTrack,}) {final _that = this;
switch (_that) {
case SleepAfterMinutes():
return minutes(_that.minutes);case SleepAtEndOfTrack():
return endOfTrack();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int minutes)?  minutes,TResult? Function()?  endOfTrack,}) {final _that = this;
switch (_that) {
case SleepAfterMinutes() when minutes != null:
return minutes(_that.minutes);case SleepAtEndOfTrack() when endOfTrack != null:
return endOfTrack();case _:
  return null;

}
}

}

/// @nodoc


class SleepAfterMinutes implements SleepTimer {
  const SleepAfterMinutes(this.minutes);
  

 final  int minutes;

/// Create a copy of SleepTimer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SleepAfterMinutesCopyWith<SleepAfterMinutes> get copyWith => _$SleepAfterMinutesCopyWithImpl<SleepAfterMinutes>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SleepAfterMinutes&&(identical(other.minutes, minutes) || other.minutes == minutes));
}


@override
int get hashCode => Object.hash(runtimeType,minutes);

@override
String toString() {
  return 'SleepTimer.minutes(minutes: $minutes)';
}


}

/// @nodoc
abstract mixin class $SleepAfterMinutesCopyWith<$Res> implements $SleepTimerCopyWith<$Res> {
  factory $SleepAfterMinutesCopyWith(SleepAfterMinutes value, $Res Function(SleepAfterMinutes) _then) = _$SleepAfterMinutesCopyWithImpl;
@useResult
$Res call({
 int minutes
});




}
/// @nodoc
class _$SleepAfterMinutesCopyWithImpl<$Res>
    implements $SleepAfterMinutesCopyWith<$Res> {
  _$SleepAfterMinutesCopyWithImpl(this._self, this._then);

  final SleepAfterMinutes _self;
  final $Res Function(SleepAfterMinutes) _then;

/// Create a copy of SleepTimer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? minutes = null,}) {
  return _then(SleepAfterMinutes(
null == minutes ? _self.minutes : minutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class SleepAtEndOfTrack implements SleepTimer {
  const SleepAtEndOfTrack();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SleepAtEndOfTrack);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SleepTimer.endOfTrack()';
}


}




/// @nodoc
mixin _$PlayerSnapshot {

 List<Track> get queue; int get index;/// How many tracks after [index] were added with "play next".
 int get upNext; PlaybackStatus get status; bool get shuffle; QueueRepeat get repeat; SleepTimer? get sleep; String get sourceLabel; ApiException? get error;
/// Create a copy of PlayerSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerSnapshotCopyWith<PlayerSnapshot> get copyWith => _$PlayerSnapshotCopyWithImpl<PlayerSnapshot>(this as PlayerSnapshot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerSnapshot&&const DeepCollectionEquality().equals(other.queue, queue)&&(identical(other.index, index) || other.index == index)&&(identical(other.upNext, upNext) || other.upNext == upNext)&&(identical(other.status, status) || other.status == status)&&(identical(other.shuffle, shuffle) || other.shuffle == shuffle)&&(identical(other.repeat, repeat) || other.repeat == repeat)&&(identical(other.sleep, sleep) || other.sleep == sleep)&&(identical(other.sourceLabel, sourceLabel) || other.sourceLabel == sourceLabel)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(queue),index,upNext,status,shuffle,repeat,sleep,sourceLabel,error);

@override
String toString() {
  return 'PlayerSnapshot(queue: $queue, index: $index, upNext: $upNext, status: $status, shuffle: $shuffle, repeat: $repeat, sleep: $sleep, sourceLabel: $sourceLabel, error: $error)';
}


}

/// @nodoc
abstract mixin class $PlayerSnapshotCopyWith<$Res>  {
  factory $PlayerSnapshotCopyWith(PlayerSnapshot value, $Res Function(PlayerSnapshot) _then) = _$PlayerSnapshotCopyWithImpl;
@useResult
$Res call({
 List<Track> queue, int index, int upNext, PlaybackStatus status, bool shuffle, QueueRepeat repeat, SleepTimer? sleep, String sourceLabel, ApiException? error
});


$SleepTimerCopyWith<$Res>? get sleep;

}
/// @nodoc
class _$PlayerSnapshotCopyWithImpl<$Res>
    implements $PlayerSnapshotCopyWith<$Res> {
  _$PlayerSnapshotCopyWithImpl(this._self, this._then);

  final PlayerSnapshot _self;
  final $Res Function(PlayerSnapshot) _then;

/// Create a copy of PlayerSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? queue = null,Object? index = null,Object? upNext = null,Object? status = null,Object? shuffle = null,Object? repeat = null,Object? sleep = freezed,Object? sourceLabel = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
queue: null == queue ? _self.queue : queue // ignore: cast_nullable_to_non_nullable
as List<Track>,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,upNext: null == upNext ? _self.upNext : upNext // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PlaybackStatus,shuffle: null == shuffle ? _self.shuffle : shuffle // ignore: cast_nullable_to_non_nullable
as bool,repeat: null == repeat ? _self.repeat : repeat // ignore: cast_nullable_to_non_nullable
as QueueRepeat,sleep: freezed == sleep ? _self.sleep : sleep // ignore: cast_nullable_to_non_nullable
as SleepTimer?,sourceLabel: null == sourceLabel ? _self.sourceLabel : sourceLabel // ignore: cast_nullable_to_non_nullable
as String,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as ApiException?,
  ));
}
/// Create a copy of PlayerSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SleepTimerCopyWith<$Res>? get sleep {
    if (_self.sleep == null) {
    return null;
  }

  return $SleepTimerCopyWith<$Res>(_self.sleep!, (value) {
    return _then(_self.copyWith(sleep: value));
  });
}
}


/// Adds pattern-matching-related methods to [PlayerSnapshot].
extension PlayerSnapshotPatterns on PlayerSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayerSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayerSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayerSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _PlayerSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayerSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _PlayerSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Track> queue,  int index,  int upNext,  PlaybackStatus status,  bool shuffle,  QueueRepeat repeat,  SleepTimer? sleep,  String sourceLabel,  ApiException? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayerSnapshot() when $default != null:
return $default(_that.queue,_that.index,_that.upNext,_that.status,_that.shuffle,_that.repeat,_that.sleep,_that.sourceLabel,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Track> queue,  int index,  int upNext,  PlaybackStatus status,  bool shuffle,  QueueRepeat repeat,  SleepTimer? sleep,  String sourceLabel,  ApiException? error)  $default,) {final _that = this;
switch (_that) {
case _PlayerSnapshot():
return $default(_that.queue,_that.index,_that.upNext,_that.status,_that.shuffle,_that.repeat,_that.sleep,_that.sourceLabel,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Track> queue,  int index,  int upNext,  PlaybackStatus status,  bool shuffle,  QueueRepeat repeat,  SleepTimer? sleep,  String sourceLabel,  ApiException? error)?  $default,) {final _that = this;
switch (_that) {
case _PlayerSnapshot() when $default != null:
return $default(_that.queue,_that.index,_that.upNext,_that.status,_that.shuffle,_that.repeat,_that.sleep,_that.sourceLabel,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _PlayerSnapshot extends PlayerSnapshot {
  const _PlayerSnapshot({final  List<Track> queue = const <Track>[], this.index = 0, this.upNext = 0, this.status = PlaybackStatus.idle, this.shuffle = false, this.repeat = QueueRepeat.off, this.sleep, this.sourceLabel = 'Cola', this.error}): _queue = queue,super._();
  

 final  List<Track> _queue;
@override@JsonKey() List<Track> get queue {
  if (_queue is EqualUnmodifiableListView) return _queue;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_queue);
}

@override@JsonKey() final  int index;
/// How many tracks after [index] were added with "play next".
@override@JsonKey() final  int upNext;
@override@JsonKey() final  PlaybackStatus status;
@override@JsonKey() final  bool shuffle;
@override@JsonKey() final  QueueRepeat repeat;
@override final  SleepTimer? sleep;
@override@JsonKey() final  String sourceLabel;
@override final  ApiException? error;

/// Create a copy of PlayerSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayerSnapshotCopyWith<_PlayerSnapshot> get copyWith => __$PlayerSnapshotCopyWithImpl<_PlayerSnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayerSnapshot&&const DeepCollectionEquality().equals(other._queue, _queue)&&(identical(other.index, index) || other.index == index)&&(identical(other.upNext, upNext) || other.upNext == upNext)&&(identical(other.status, status) || other.status == status)&&(identical(other.shuffle, shuffle) || other.shuffle == shuffle)&&(identical(other.repeat, repeat) || other.repeat == repeat)&&(identical(other.sleep, sleep) || other.sleep == sleep)&&(identical(other.sourceLabel, sourceLabel) || other.sourceLabel == sourceLabel)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_queue),index,upNext,status,shuffle,repeat,sleep,sourceLabel,error);

@override
String toString() {
  return 'PlayerSnapshot(queue: $queue, index: $index, upNext: $upNext, status: $status, shuffle: $shuffle, repeat: $repeat, sleep: $sleep, sourceLabel: $sourceLabel, error: $error)';
}


}

/// @nodoc
abstract mixin class _$PlayerSnapshotCopyWith<$Res> implements $PlayerSnapshotCopyWith<$Res> {
  factory _$PlayerSnapshotCopyWith(_PlayerSnapshot value, $Res Function(_PlayerSnapshot) _then) = __$PlayerSnapshotCopyWithImpl;
@override @useResult
$Res call({
 List<Track> queue, int index, int upNext, PlaybackStatus status, bool shuffle, QueueRepeat repeat, SleepTimer? sleep, String sourceLabel, ApiException? error
});


@override $SleepTimerCopyWith<$Res>? get sleep;

}
/// @nodoc
class __$PlayerSnapshotCopyWithImpl<$Res>
    implements _$PlayerSnapshotCopyWith<$Res> {
  __$PlayerSnapshotCopyWithImpl(this._self, this._then);

  final _PlayerSnapshot _self;
  final $Res Function(_PlayerSnapshot) _then;

/// Create a copy of PlayerSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? queue = null,Object? index = null,Object? upNext = null,Object? status = null,Object? shuffle = null,Object? repeat = null,Object? sleep = freezed,Object? sourceLabel = null,Object? error = freezed,}) {
  return _then(_PlayerSnapshot(
queue: null == queue ? _self._queue : queue // ignore: cast_nullable_to_non_nullable
as List<Track>,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,upNext: null == upNext ? _self.upNext : upNext // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PlaybackStatus,shuffle: null == shuffle ? _self.shuffle : shuffle // ignore: cast_nullable_to_non_nullable
as bool,repeat: null == repeat ? _self.repeat : repeat // ignore: cast_nullable_to_non_nullable
as QueueRepeat,sleep: freezed == sleep ? _self.sleep : sleep // ignore: cast_nullable_to_non_nullable
as SleepTimer?,sourceLabel: null == sourceLabel ? _self.sourceLabel : sourceLabel // ignore: cast_nullable_to_non_nullable
as String,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as ApiException?,
  ));
}

/// Create a copy of PlayerSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SleepTimerCopyWith<$Res>? get sleep {
    if (_self.sleep == null) {
    return null;
  }

  return $SleepTimerCopyWith<$Res>(_self.sleep!, (value) {
    return _then(_self.copyWith(sleep: value));
  });
}
}

// dart format on
