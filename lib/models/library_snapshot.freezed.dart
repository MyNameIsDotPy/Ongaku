// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'library_snapshot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LibrarySnapshot {

 List<Playlist> get playlists; List<Track> get favorites; List<PlayEvent> get history;
/// Create a copy of LibrarySnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LibrarySnapshotCopyWith<LibrarySnapshot> get copyWith => _$LibrarySnapshotCopyWithImpl<LibrarySnapshot>(this as LibrarySnapshot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LibrarySnapshot&&const DeepCollectionEquality().equals(other.playlists, playlists)&&const DeepCollectionEquality().equals(other.favorites, favorites)&&const DeepCollectionEquality().equals(other.history, history));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(playlists),const DeepCollectionEquality().hash(favorites),const DeepCollectionEquality().hash(history));

@override
String toString() {
  return 'LibrarySnapshot(playlists: $playlists, favorites: $favorites, history: $history)';
}


}

/// @nodoc
abstract mixin class $LibrarySnapshotCopyWith<$Res>  {
  factory $LibrarySnapshotCopyWith(LibrarySnapshot value, $Res Function(LibrarySnapshot) _then) = _$LibrarySnapshotCopyWithImpl;
@useResult
$Res call({
 List<Playlist> playlists, List<Track> favorites, List<PlayEvent> history
});




}
/// @nodoc
class _$LibrarySnapshotCopyWithImpl<$Res>
    implements $LibrarySnapshotCopyWith<$Res> {
  _$LibrarySnapshotCopyWithImpl(this._self, this._then);

  final LibrarySnapshot _self;
  final $Res Function(LibrarySnapshot) _then;

/// Create a copy of LibrarySnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? playlists = null,Object? favorites = null,Object? history = null,}) {
  return _then(_self.copyWith(
playlists: null == playlists ? _self.playlists : playlists // ignore: cast_nullable_to_non_nullable
as List<Playlist>,favorites: null == favorites ? _self.favorites : favorites // ignore: cast_nullable_to_non_nullable
as List<Track>,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as List<PlayEvent>,
  ));
}

}


/// Adds pattern-matching-related methods to [LibrarySnapshot].
extension LibrarySnapshotPatterns on LibrarySnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LibrarySnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LibrarySnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LibrarySnapshot value)  $default,){
final _that = this;
switch (_that) {
case _LibrarySnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LibrarySnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _LibrarySnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Playlist> playlists,  List<Track> favorites,  List<PlayEvent> history)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LibrarySnapshot() when $default != null:
return $default(_that.playlists,_that.favorites,_that.history);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Playlist> playlists,  List<Track> favorites,  List<PlayEvent> history)  $default,) {final _that = this;
switch (_that) {
case _LibrarySnapshot():
return $default(_that.playlists,_that.favorites,_that.history);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Playlist> playlists,  List<Track> favorites,  List<PlayEvent> history)?  $default,) {final _that = this;
switch (_that) {
case _LibrarySnapshot() when $default != null:
return $default(_that.playlists,_that.favorites,_that.history);case _:
  return null;

}
}

}

/// @nodoc


class _LibrarySnapshot extends LibrarySnapshot {
  const _LibrarySnapshot({final  List<Playlist> playlists = const <Playlist>[], final  List<Track> favorites = const <Track>[], final  List<PlayEvent> history = const <PlayEvent>[]}): _playlists = playlists,_favorites = favorites,_history = history,super._();
  

 final  List<Playlist> _playlists;
@override@JsonKey() List<Playlist> get playlists {
  if (_playlists is EqualUnmodifiableListView) return _playlists;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_playlists);
}

 final  List<Track> _favorites;
@override@JsonKey() List<Track> get favorites {
  if (_favorites is EqualUnmodifiableListView) return _favorites;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_favorites);
}

 final  List<PlayEvent> _history;
@override@JsonKey() List<PlayEvent> get history {
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_history);
}


/// Create a copy of LibrarySnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LibrarySnapshotCopyWith<_LibrarySnapshot> get copyWith => __$LibrarySnapshotCopyWithImpl<_LibrarySnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LibrarySnapshot&&const DeepCollectionEquality().equals(other._playlists, _playlists)&&const DeepCollectionEquality().equals(other._favorites, _favorites)&&const DeepCollectionEquality().equals(other._history, _history));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_playlists),const DeepCollectionEquality().hash(_favorites),const DeepCollectionEquality().hash(_history));

@override
String toString() {
  return 'LibrarySnapshot(playlists: $playlists, favorites: $favorites, history: $history)';
}


}

/// @nodoc
abstract mixin class _$LibrarySnapshotCopyWith<$Res> implements $LibrarySnapshotCopyWith<$Res> {
  factory _$LibrarySnapshotCopyWith(_LibrarySnapshot value, $Res Function(_LibrarySnapshot) _then) = __$LibrarySnapshotCopyWithImpl;
@override @useResult
$Res call({
 List<Playlist> playlists, List<Track> favorites, List<PlayEvent> history
});




}
/// @nodoc
class __$LibrarySnapshotCopyWithImpl<$Res>
    implements _$LibrarySnapshotCopyWith<$Res> {
  __$LibrarySnapshotCopyWithImpl(this._self, this._then);

  final _LibrarySnapshot _self;
  final $Res Function(_LibrarySnapshot) _then;

/// Create a copy of LibrarySnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? playlists = null,Object? favorites = null,Object? history = null,}) {
  return _then(_LibrarySnapshot(
playlists: null == playlists ? _self._playlists : playlists // ignore: cast_nullable_to_non_nullable
as List<Playlist>,favorites: null == favorites ? _self._favorites : favorites // ignore: cast_nullable_to_non_nullable
as List<Track>,history: null == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<PlayEvent>,
  ));
}


}

// dart format on
