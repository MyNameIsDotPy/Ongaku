// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'track.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ArtistRef {

 String get id; String get name;
/// Create a copy of ArtistRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ArtistRefCopyWith<ArtistRef> get copyWith => _$ArtistRefCopyWithImpl<ArtistRef>(this as ArtistRef, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ArtistRef&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'ArtistRef(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $ArtistRefCopyWith<$Res>  {
  factory $ArtistRefCopyWith(ArtistRef value, $Res Function(ArtistRef) _then) = _$ArtistRefCopyWithImpl;
@useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class _$ArtistRefCopyWithImpl<$Res>
    implements $ArtistRefCopyWith<$Res> {
  _$ArtistRefCopyWithImpl(this._self, this._then);

  final ArtistRef _self;
  final $Res Function(ArtistRef) _then;

/// Create a copy of ArtistRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ArtistRef].
extension ArtistRefPatterns on ArtistRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ArtistRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ArtistRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ArtistRef value)  $default,){
final _that = this;
switch (_that) {
case _ArtistRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ArtistRef value)?  $default,){
final _that = this;
switch (_that) {
case _ArtistRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ArtistRef() when $default != null:
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name)  $default,) {final _that = this;
switch (_that) {
case _ArtistRef():
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name)?  $default,) {final _that = this;
switch (_that) {
case _ArtistRef() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc


class _ArtistRef implements ArtistRef {
  const _ArtistRef({required this.id, required this.name});
  

@override final  String id;
@override final  String name;

/// Create a copy of ArtistRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ArtistRefCopyWith<_ArtistRef> get copyWith => __$ArtistRefCopyWithImpl<_ArtistRef>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ArtistRef&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'ArtistRef(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$ArtistRefCopyWith<$Res> implements $ArtistRefCopyWith<$Res> {
  factory _$ArtistRefCopyWith(_ArtistRef value, $Res Function(_ArtistRef) _then) = __$ArtistRefCopyWithImpl;
@override @useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class __$ArtistRefCopyWithImpl<$Res>
    implements _$ArtistRefCopyWith<$Res> {
  __$ArtistRefCopyWithImpl(this._self, this._then);

  final _ArtistRef _self;
  final $Res Function(_ArtistRef) _then;

/// Create a copy of ArtistRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_ArtistRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$AlbumRef {

 String get id; String get name;
/// Create a copy of AlbumRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AlbumRefCopyWith<AlbumRef> get copyWith => _$AlbumRefCopyWithImpl<AlbumRef>(this as AlbumRef, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AlbumRef&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'AlbumRef(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $AlbumRefCopyWith<$Res>  {
  factory $AlbumRefCopyWith(AlbumRef value, $Res Function(AlbumRef) _then) = _$AlbumRefCopyWithImpl;
@useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class _$AlbumRefCopyWithImpl<$Res>
    implements $AlbumRefCopyWith<$Res> {
  _$AlbumRefCopyWithImpl(this._self, this._then);

  final AlbumRef _self;
  final $Res Function(AlbumRef) _then;

/// Create a copy of AlbumRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AlbumRef].
extension AlbumRefPatterns on AlbumRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AlbumRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AlbumRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AlbumRef value)  $default,){
final _that = this;
switch (_that) {
case _AlbumRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AlbumRef value)?  $default,){
final _that = this;
switch (_that) {
case _AlbumRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AlbumRef() when $default != null:
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name)  $default,) {final _that = this;
switch (_that) {
case _AlbumRef():
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name)?  $default,) {final _that = this;
switch (_that) {
case _AlbumRef() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc


class _AlbumRef implements AlbumRef {
  const _AlbumRef({required this.id, required this.name});
  

@override final  String id;
@override final  String name;

/// Create a copy of AlbumRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AlbumRefCopyWith<_AlbumRef> get copyWith => __$AlbumRefCopyWithImpl<_AlbumRef>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AlbumRef&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'AlbumRef(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$AlbumRefCopyWith<$Res> implements $AlbumRefCopyWith<$Res> {
  factory _$AlbumRefCopyWith(_AlbumRef value, $Res Function(_AlbumRef) _then) = __$AlbumRefCopyWithImpl;
@override @useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class __$AlbumRefCopyWithImpl<$Res>
    implements _$AlbumRefCopyWith<$Res> {
  __$AlbumRefCopyWithImpl(this._self, this._then);

  final _AlbumRef _self;
  final $Res Function(_AlbumRef) _then;

/// Create a copy of AlbumRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_AlbumRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$Track {

 String get videoId; String get title; List<ArtistRef> get artists; AlbumRef? get album; Duration get duration;/// Asset path (`assets/...`) or network URL.
 String get coverUrl; bool get explicit;/// The backend could not extract this one (`UNAVAILABLE`).
 bool get unavailable;/// Dominant cover colors (ARGB), used for tints and the player aura.
 List<int> get palette;
/// Create a copy of Track
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrackCopyWith<Track> get copyWith => _$TrackCopyWithImpl<Track>(this as Track, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Track&&(identical(other.videoId, videoId) || other.videoId == videoId)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.artists, artists)&&(identical(other.album, album) || other.album == album)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.explicit, explicit) || other.explicit == explicit)&&(identical(other.unavailable, unavailable) || other.unavailable == unavailable)&&const DeepCollectionEquality().equals(other.palette, palette));
}


@override
int get hashCode => Object.hash(runtimeType,videoId,title,const DeepCollectionEquality().hash(artists),album,duration,coverUrl,explicit,unavailable,const DeepCollectionEquality().hash(palette));

@override
String toString() {
  return 'Track(videoId: $videoId, title: $title, artists: $artists, album: $album, duration: $duration, coverUrl: $coverUrl, explicit: $explicit, unavailable: $unavailable, palette: $palette)';
}


}

/// @nodoc
abstract mixin class $TrackCopyWith<$Res>  {
  factory $TrackCopyWith(Track value, $Res Function(Track) _then) = _$TrackCopyWithImpl;
@useResult
$Res call({
 String videoId, String title, List<ArtistRef> artists, AlbumRef? album, Duration duration, String coverUrl, bool explicit, bool unavailable, List<int> palette
});


$AlbumRefCopyWith<$Res>? get album;

}
/// @nodoc
class _$TrackCopyWithImpl<$Res>
    implements $TrackCopyWith<$Res> {
  _$TrackCopyWithImpl(this._self, this._then);

  final Track _self;
  final $Res Function(Track) _then;

/// Create a copy of Track
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? videoId = null,Object? title = null,Object? artists = null,Object? album = freezed,Object? duration = null,Object? coverUrl = null,Object? explicit = null,Object? unavailable = null,Object? palette = null,}) {
  return _then(_self.copyWith(
videoId: null == videoId ? _self.videoId : videoId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artists: null == artists ? _self.artists : artists // ignore: cast_nullable_to_non_nullable
as List<ArtistRef>,album: freezed == album ? _self.album : album // ignore: cast_nullable_to_non_nullable
as AlbumRef?,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,explicit: null == explicit ? _self.explicit : explicit // ignore: cast_nullable_to_non_nullable
as bool,unavailable: null == unavailable ? _self.unavailable : unavailable // ignore: cast_nullable_to_non_nullable
as bool,palette: null == palette ? _self.palette : palette // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}
/// Create a copy of Track
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlbumRefCopyWith<$Res>? get album {
    if (_self.album == null) {
    return null;
  }

  return $AlbumRefCopyWith<$Res>(_self.album!, (value) {
    return _then(_self.copyWith(album: value));
  });
}
}


/// Adds pattern-matching-related methods to [Track].
extension TrackPatterns on Track {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Track value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Track() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Track value)  $default,){
final _that = this;
switch (_that) {
case _Track():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Track value)?  $default,){
final _that = this;
switch (_that) {
case _Track() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String videoId,  String title,  List<ArtistRef> artists,  AlbumRef? album,  Duration duration,  String coverUrl,  bool explicit,  bool unavailable,  List<int> palette)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Track() when $default != null:
return $default(_that.videoId,_that.title,_that.artists,_that.album,_that.duration,_that.coverUrl,_that.explicit,_that.unavailable,_that.palette);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String videoId,  String title,  List<ArtistRef> artists,  AlbumRef? album,  Duration duration,  String coverUrl,  bool explicit,  bool unavailable,  List<int> palette)  $default,) {final _that = this;
switch (_that) {
case _Track():
return $default(_that.videoId,_that.title,_that.artists,_that.album,_that.duration,_that.coverUrl,_that.explicit,_that.unavailable,_that.palette);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String videoId,  String title,  List<ArtistRef> artists,  AlbumRef? album,  Duration duration,  String coverUrl,  bool explicit,  bool unavailable,  List<int> palette)?  $default,) {final _that = this;
switch (_that) {
case _Track() when $default != null:
return $default(_that.videoId,_that.title,_that.artists,_that.album,_that.duration,_that.coverUrl,_that.explicit,_that.unavailable,_that.palette);case _:
  return null;

}
}

}

/// @nodoc


class _Track extends Track {
  const _Track({required this.videoId, required this.title, required final  List<ArtistRef> artists, this.album, required this.duration, required this.coverUrl, this.explicit = false, this.unavailable = false, final  List<int> palette = const <int>[]}): _artists = artists,_palette = palette,super._();
  

@override final  String videoId;
@override final  String title;
 final  List<ArtistRef> _artists;
@override List<ArtistRef> get artists {
  if (_artists is EqualUnmodifiableListView) return _artists;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_artists);
}

@override final  AlbumRef? album;
@override final  Duration duration;
/// Asset path (`assets/...`) or network URL.
@override final  String coverUrl;
@override@JsonKey() final  bool explicit;
/// The backend could not extract this one (`UNAVAILABLE`).
@override@JsonKey() final  bool unavailable;
/// Dominant cover colors (ARGB), used for tints and the player aura.
 final  List<int> _palette;
/// Dominant cover colors (ARGB), used for tints and the player aura.
@override@JsonKey() List<int> get palette {
  if (_palette is EqualUnmodifiableListView) return _palette;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_palette);
}


/// Create a copy of Track
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrackCopyWith<_Track> get copyWith => __$TrackCopyWithImpl<_Track>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Track&&(identical(other.videoId, videoId) || other.videoId == videoId)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._artists, _artists)&&(identical(other.album, album) || other.album == album)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.explicit, explicit) || other.explicit == explicit)&&(identical(other.unavailable, unavailable) || other.unavailable == unavailable)&&const DeepCollectionEquality().equals(other._palette, _palette));
}


@override
int get hashCode => Object.hash(runtimeType,videoId,title,const DeepCollectionEquality().hash(_artists),album,duration,coverUrl,explicit,unavailable,const DeepCollectionEquality().hash(_palette));

@override
String toString() {
  return 'Track(videoId: $videoId, title: $title, artists: $artists, album: $album, duration: $duration, coverUrl: $coverUrl, explicit: $explicit, unavailable: $unavailable, palette: $palette)';
}


}

/// @nodoc
abstract mixin class _$TrackCopyWith<$Res> implements $TrackCopyWith<$Res> {
  factory _$TrackCopyWith(_Track value, $Res Function(_Track) _then) = __$TrackCopyWithImpl;
@override @useResult
$Res call({
 String videoId, String title, List<ArtistRef> artists, AlbumRef? album, Duration duration, String coverUrl, bool explicit, bool unavailable, List<int> palette
});


@override $AlbumRefCopyWith<$Res>? get album;

}
/// @nodoc
class __$TrackCopyWithImpl<$Res>
    implements _$TrackCopyWith<$Res> {
  __$TrackCopyWithImpl(this._self, this._then);

  final _Track _self;
  final $Res Function(_Track) _then;

/// Create a copy of Track
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? videoId = null,Object? title = null,Object? artists = null,Object? album = freezed,Object? duration = null,Object? coverUrl = null,Object? explicit = null,Object? unavailable = null,Object? palette = null,}) {
  return _then(_Track(
videoId: null == videoId ? _self.videoId : videoId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artists: null == artists ? _self._artists : artists // ignore: cast_nullable_to_non_nullable
as List<ArtistRef>,album: freezed == album ? _self.album : album // ignore: cast_nullable_to_non_nullable
as AlbumRef?,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,explicit: null == explicit ? _self.explicit : explicit // ignore: cast_nullable_to_non_nullable
as bool,unavailable: null == unavailable ? _self.unavailable : unavailable // ignore: cast_nullable_to_non_nullable
as bool,palette: null == palette ? _self._palette : palette // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

/// Create a copy of Track
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AlbumRefCopyWith<$Res>? get album {
    if (_self.album == null) {
    return null;
  }

  return $AlbumRefCopyWith<$Res>(_self.album!, (value) {
    return _then(_self.copyWith(album: value));
  });
}
}

// dart format on
