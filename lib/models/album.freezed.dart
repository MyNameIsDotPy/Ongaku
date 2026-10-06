// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'album.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Album {

 String get id; String get title; ArtistRef get artist;/// Unknown for some YouTube albums.
 int? get year; String get genre; String get coverUrl; List<int> get palette; List<Track> get tracks;
/// Create a copy of Album
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AlbumCopyWith<Album> get copyWith => _$AlbumCopyWithImpl<Album>(this as Album, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Album&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.year, year) || other.year == year)&&(identical(other.genre, genre) || other.genre == genre)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&const DeepCollectionEquality().equals(other.palette, palette)&&const DeepCollectionEquality().equals(other.tracks, tracks));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,artist,year,genre,coverUrl,const DeepCollectionEquality().hash(palette),const DeepCollectionEquality().hash(tracks));

@override
String toString() {
  return 'Album(id: $id, title: $title, artist: $artist, year: $year, genre: $genre, coverUrl: $coverUrl, palette: $palette, tracks: $tracks)';
}


}

/// @nodoc
abstract mixin class $AlbumCopyWith<$Res>  {
  factory $AlbumCopyWith(Album value, $Res Function(Album) _then) = _$AlbumCopyWithImpl;
@useResult
$Res call({
 String id, String title, ArtistRef artist, int? year, String genre, String coverUrl, List<int> palette, List<Track> tracks
});


$ArtistRefCopyWith<$Res> get artist;

}
/// @nodoc
class _$AlbumCopyWithImpl<$Res>
    implements $AlbumCopyWith<$Res> {
  _$AlbumCopyWithImpl(this._self, this._then);

  final Album _self;
  final $Res Function(Album) _then;

/// Create a copy of Album
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? artist = null,Object? year = freezed,Object? genre = null,Object? coverUrl = null,Object? palette = null,Object? tracks = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as ArtistRef,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,genre: null == genre ? _self.genre : genre // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,palette: null == palette ? _self.palette : palette // ignore: cast_nullable_to_non_nullable
as List<int>,tracks: null == tracks ? _self.tracks : tracks // ignore: cast_nullable_to_non_nullable
as List<Track>,
  ));
}
/// Create a copy of Album
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ArtistRefCopyWith<$Res> get artist {
  
  return $ArtistRefCopyWith<$Res>(_self.artist, (value) {
    return _then(_self.copyWith(artist: value));
  });
}
}


/// Adds pattern-matching-related methods to [Album].
extension AlbumPatterns on Album {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Album value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Album() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Album value)  $default,){
final _that = this;
switch (_that) {
case _Album():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Album value)?  $default,){
final _that = this;
switch (_that) {
case _Album() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  ArtistRef artist,  int? year,  String genre,  String coverUrl,  List<int> palette,  List<Track> tracks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Album() when $default != null:
return $default(_that.id,_that.title,_that.artist,_that.year,_that.genre,_that.coverUrl,_that.palette,_that.tracks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  ArtistRef artist,  int? year,  String genre,  String coverUrl,  List<int> palette,  List<Track> tracks)  $default,) {final _that = this;
switch (_that) {
case _Album():
return $default(_that.id,_that.title,_that.artist,_that.year,_that.genre,_that.coverUrl,_that.palette,_that.tracks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  ArtistRef artist,  int? year,  String genre,  String coverUrl,  List<int> palette,  List<Track> tracks)?  $default,) {final _that = this;
switch (_that) {
case _Album() when $default != null:
return $default(_that.id,_that.title,_that.artist,_that.year,_that.genre,_that.coverUrl,_that.palette,_that.tracks);case _:
  return null;

}
}

}

/// @nodoc


class _Album extends Album {
  const _Album({required this.id, required this.title, required this.artist, this.year, required this.genre, required this.coverUrl, final  List<int> palette = const <int>[], final  List<Track> tracks = const <Track>[]}): _palette = palette,_tracks = tracks,super._();
  

@override final  String id;
@override final  String title;
@override final  ArtistRef artist;
/// Unknown for some YouTube albums.
@override final  int? year;
@override final  String genre;
@override final  String coverUrl;
 final  List<int> _palette;
@override@JsonKey() List<int> get palette {
  if (_palette is EqualUnmodifiableListView) return _palette;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_palette);
}

 final  List<Track> _tracks;
@override@JsonKey() List<Track> get tracks {
  if (_tracks is EqualUnmodifiableListView) return _tracks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tracks);
}


/// Create a copy of Album
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AlbumCopyWith<_Album> get copyWith => __$AlbumCopyWithImpl<_Album>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Album&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.year, year) || other.year == year)&&(identical(other.genre, genre) || other.genre == genre)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&const DeepCollectionEquality().equals(other._palette, _palette)&&const DeepCollectionEquality().equals(other._tracks, _tracks));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,artist,year,genre,coverUrl,const DeepCollectionEquality().hash(_palette),const DeepCollectionEquality().hash(_tracks));

@override
String toString() {
  return 'Album(id: $id, title: $title, artist: $artist, year: $year, genre: $genre, coverUrl: $coverUrl, palette: $palette, tracks: $tracks)';
}


}

/// @nodoc
abstract mixin class _$AlbumCopyWith<$Res> implements $AlbumCopyWith<$Res> {
  factory _$AlbumCopyWith(_Album value, $Res Function(_Album) _then) = __$AlbumCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, ArtistRef artist, int? year, String genre, String coverUrl, List<int> palette, List<Track> tracks
});


@override $ArtistRefCopyWith<$Res> get artist;

}
/// @nodoc
class __$AlbumCopyWithImpl<$Res>
    implements _$AlbumCopyWith<$Res> {
  __$AlbumCopyWithImpl(this._self, this._then);

  final _Album _self;
  final $Res Function(_Album) _then;

/// Create a copy of Album
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? artist = null,Object? year = freezed,Object? genre = null,Object? coverUrl = null,Object? palette = null,Object? tracks = null,}) {
  return _then(_Album(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as ArtistRef,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,genre: null == genre ? _self.genre : genre // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,palette: null == palette ? _self._palette : palette // ignore: cast_nullable_to_non_nullable
as List<int>,tracks: null == tracks ? _self._tracks : tracks // ignore: cast_nullable_to_non_nullable
as List<Track>,
  ));
}

/// Create a copy of Album
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ArtistRefCopyWith<$Res> get artist {
  
  return $ArtistRefCopyWith<$Res>(_self.artist, (value) {
    return _then(_self.copyWith(artist: value));
  });
}
}

// dart format on
