// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_results.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SearchResults {

 List<Track> get tracks; List<Album> get albums; List<Artist> get artists; List<Playlist> get playlists;
/// Create a copy of SearchResults
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchResultsCopyWith<SearchResults> get copyWith => _$SearchResultsCopyWithImpl<SearchResults>(this as SearchResults, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchResults&&const DeepCollectionEquality().equals(other.tracks, tracks)&&const DeepCollectionEquality().equals(other.albums, albums)&&const DeepCollectionEquality().equals(other.artists, artists)&&const DeepCollectionEquality().equals(other.playlists, playlists));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(tracks),const DeepCollectionEquality().hash(albums),const DeepCollectionEquality().hash(artists),const DeepCollectionEquality().hash(playlists));

@override
String toString() {
  return 'SearchResults(tracks: $tracks, albums: $albums, artists: $artists, playlists: $playlists)';
}


}

/// @nodoc
abstract mixin class $SearchResultsCopyWith<$Res>  {
  factory $SearchResultsCopyWith(SearchResults value, $Res Function(SearchResults) _then) = _$SearchResultsCopyWithImpl;
@useResult
$Res call({
 List<Track> tracks, List<Album> albums, List<Artist> artists, List<Playlist> playlists
});




}
/// @nodoc
class _$SearchResultsCopyWithImpl<$Res>
    implements $SearchResultsCopyWith<$Res> {
  _$SearchResultsCopyWithImpl(this._self, this._then);

  final SearchResults _self;
  final $Res Function(SearchResults) _then;

/// Create a copy of SearchResults
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tracks = null,Object? albums = null,Object? artists = null,Object? playlists = null,}) {
  return _then(_self.copyWith(
tracks: null == tracks ? _self.tracks : tracks // ignore: cast_nullable_to_non_nullable
as List<Track>,albums: null == albums ? _self.albums : albums // ignore: cast_nullable_to_non_nullable
as List<Album>,artists: null == artists ? _self.artists : artists // ignore: cast_nullable_to_non_nullable
as List<Artist>,playlists: null == playlists ? _self.playlists : playlists // ignore: cast_nullable_to_non_nullable
as List<Playlist>,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchResults].
extension SearchResultsPatterns on SearchResults {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchResults value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchResults() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchResults value)  $default,){
final _that = this;
switch (_that) {
case _SearchResults():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchResults value)?  $default,){
final _that = this;
switch (_that) {
case _SearchResults() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Track> tracks,  List<Album> albums,  List<Artist> artists,  List<Playlist> playlists)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchResults() when $default != null:
return $default(_that.tracks,_that.albums,_that.artists,_that.playlists);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Track> tracks,  List<Album> albums,  List<Artist> artists,  List<Playlist> playlists)  $default,) {final _that = this;
switch (_that) {
case _SearchResults():
return $default(_that.tracks,_that.albums,_that.artists,_that.playlists);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Track> tracks,  List<Album> albums,  List<Artist> artists,  List<Playlist> playlists)?  $default,) {final _that = this;
switch (_that) {
case _SearchResults() when $default != null:
return $default(_that.tracks,_that.albums,_that.artists,_that.playlists);case _:
  return null;

}
}

}

/// @nodoc


class _SearchResults extends SearchResults {
  const _SearchResults({final  List<Track> tracks = const <Track>[], final  List<Album> albums = const <Album>[], final  List<Artist> artists = const <Artist>[], final  List<Playlist> playlists = const <Playlist>[]}): _tracks = tracks,_albums = albums,_artists = artists,_playlists = playlists,super._();
  

 final  List<Track> _tracks;
@override@JsonKey() List<Track> get tracks {
  if (_tracks is EqualUnmodifiableListView) return _tracks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tracks);
}

 final  List<Album> _albums;
@override@JsonKey() List<Album> get albums {
  if (_albums is EqualUnmodifiableListView) return _albums;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_albums);
}

 final  List<Artist> _artists;
@override@JsonKey() List<Artist> get artists {
  if (_artists is EqualUnmodifiableListView) return _artists;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_artists);
}

 final  List<Playlist> _playlists;
@override@JsonKey() List<Playlist> get playlists {
  if (_playlists is EqualUnmodifiableListView) return _playlists;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_playlists);
}


/// Create a copy of SearchResults
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchResultsCopyWith<_SearchResults> get copyWith => __$SearchResultsCopyWithImpl<_SearchResults>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchResults&&const DeepCollectionEquality().equals(other._tracks, _tracks)&&const DeepCollectionEquality().equals(other._albums, _albums)&&const DeepCollectionEquality().equals(other._artists, _artists)&&const DeepCollectionEquality().equals(other._playlists, _playlists));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_tracks),const DeepCollectionEquality().hash(_albums),const DeepCollectionEquality().hash(_artists),const DeepCollectionEquality().hash(_playlists));

@override
String toString() {
  return 'SearchResults(tracks: $tracks, albums: $albums, artists: $artists, playlists: $playlists)';
}


}

/// @nodoc
abstract mixin class _$SearchResultsCopyWith<$Res> implements $SearchResultsCopyWith<$Res> {
  factory _$SearchResultsCopyWith(_SearchResults value, $Res Function(_SearchResults) _then) = __$SearchResultsCopyWithImpl;
@override @useResult
$Res call({
 List<Track> tracks, List<Album> albums, List<Artist> artists, List<Playlist> playlists
});




}
/// @nodoc
class __$SearchResultsCopyWithImpl<$Res>
    implements _$SearchResultsCopyWith<$Res> {
  __$SearchResultsCopyWithImpl(this._self, this._then);

  final _SearchResults _self;
  final $Res Function(_SearchResults) _then;

/// Create a copy of SearchResults
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tracks = null,Object? albums = null,Object? artists = null,Object? playlists = null,}) {
  return _then(_SearchResults(
tracks: null == tracks ? _self._tracks : tracks // ignore: cast_nullable_to_non_nullable
as List<Track>,albums: null == albums ? _self._albums : albums // ignore: cast_nullable_to_non_nullable
as List<Album>,artists: null == artists ? _self._artists : artists // ignore: cast_nullable_to_non_nullable
as List<Artist>,playlists: null == playlists ? _self._playlists : playlists // ignore: cast_nullable_to_non_nullable
as List<Playlist>,
  ));
}


}

// dart format on
