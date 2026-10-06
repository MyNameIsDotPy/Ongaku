// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'artist.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Artist {

 String get id; String get name; String? get photoUrl; String? get photoCredit; List<Track> get popular; List<Album> get albums; List<Album> get singles;
/// Create a copy of Artist
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ArtistCopyWith<Artist> get copyWith => _$ArtistCopyWithImpl<Artist>(this as Artist, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Artist&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.photoCredit, photoCredit) || other.photoCredit == photoCredit)&&const DeepCollectionEquality().equals(other.popular, popular)&&const DeepCollectionEquality().equals(other.albums, albums)&&const DeepCollectionEquality().equals(other.singles, singles));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,photoUrl,photoCredit,const DeepCollectionEquality().hash(popular),const DeepCollectionEquality().hash(albums),const DeepCollectionEquality().hash(singles));

@override
String toString() {
  return 'Artist(id: $id, name: $name, photoUrl: $photoUrl, photoCredit: $photoCredit, popular: $popular, albums: $albums, singles: $singles)';
}


}

/// @nodoc
abstract mixin class $ArtistCopyWith<$Res>  {
  factory $ArtistCopyWith(Artist value, $Res Function(Artist) _then) = _$ArtistCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? photoUrl, String? photoCredit, List<Track> popular, List<Album> albums, List<Album> singles
});




}
/// @nodoc
class _$ArtistCopyWithImpl<$Res>
    implements $ArtistCopyWith<$Res> {
  _$ArtistCopyWithImpl(this._self, this._then);

  final Artist _self;
  final $Res Function(Artist) _then;

/// Create a copy of Artist
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? photoUrl = freezed,Object? photoCredit = freezed,Object? popular = null,Object? albums = null,Object? singles = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,photoCredit: freezed == photoCredit ? _self.photoCredit : photoCredit // ignore: cast_nullable_to_non_nullable
as String?,popular: null == popular ? _self.popular : popular // ignore: cast_nullable_to_non_nullable
as List<Track>,albums: null == albums ? _self.albums : albums // ignore: cast_nullable_to_non_nullable
as List<Album>,singles: null == singles ? _self.singles : singles // ignore: cast_nullable_to_non_nullable
as List<Album>,
  ));
}

}


/// Adds pattern-matching-related methods to [Artist].
extension ArtistPatterns on Artist {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Artist value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Artist() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Artist value)  $default,){
final _that = this;
switch (_that) {
case _Artist():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Artist value)?  $default,){
final _that = this;
switch (_that) {
case _Artist() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? photoUrl,  String? photoCredit,  List<Track> popular,  List<Album> albums,  List<Album> singles)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Artist() when $default != null:
return $default(_that.id,_that.name,_that.photoUrl,_that.photoCredit,_that.popular,_that.albums,_that.singles);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? photoUrl,  String? photoCredit,  List<Track> popular,  List<Album> albums,  List<Album> singles)  $default,) {final _that = this;
switch (_that) {
case _Artist():
return $default(_that.id,_that.name,_that.photoUrl,_that.photoCredit,_that.popular,_that.albums,_that.singles);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? photoUrl,  String? photoCredit,  List<Track> popular,  List<Album> albums,  List<Album> singles)?  $default,) {final _that = this;
switch (_that) {
case _Artist() when $default != null:
return $default(_that.id,_that.name,_that.photoUrl,_that.photoCredit,_that.popular,_that.albums,_that.singles);case _:
  return null;

}
}

}

/// @nodoc


class _Artist implements Artist {
  const _Artist({required this.id, required this.name, this.photoUrl, this.photoCredit, final  List<Track> popular = const <Track>[], final  List<Album> albums = const <Album>[], final  List<Album> singles = const <Album>[]}): _popular = popular,_albums = albums,_singles = singles;
  

@override final  String id;
@override final  String name;
@override final  String? photoUrl;
@override final  String? photoCredit;
 final  List<Track> _popular;
@override@JsonKey() List<Track> get popular {
  if (_popular is EqualUnmodifiableListView) return _popular;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_popular);
}

 final  List<Album> _albums;
@override@JsonKey() List<Album> get albums {
  if (_albums is EqualUnmodifiableListView) return _albums;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_albums);
}

 final  List<Album> _singles;
@override@JsonKey() List<Album> get singles {
  if (_singles is EqualUnmodifiableListView) return _singles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_singles);
}


/// Create a copy of Artist
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ArtistCopyWith<_Artist> get copyWith => __$ArtistCopyWithImpl<_Artist>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Artist&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.photoCredit, photoCredit) || other.photoCredit == photoCredit)&&const DeepCollectionEquality().equals(other._popular, _popular)&&const DeepCollectionEquality().equals(other._albums, _albums)&&const DeepCollectionEquality().equals(other._singles, _singles));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,photoUrl,photoCredit,const DeepCollectionEquality().hash(_popular),const DeepCollectionEquality().hash(_albums),const DeepCollectionEquality().hash(_singles));

@override
String toString() {
  return 'Artist(id: $id, name: $name, photoUrl: $photoUrl, photoCredit: $photoCredit, popular: $popular, albums: $albums, singles: $singles)';
}


}

/// @nodoc
abstract mixin class _$ArtistCopyWith<$Res> implements $ArtistCopyWith<$Res> {
  factory _$ArtistCopyWith(_Artist value, $Res Function(_Artist) _then) = __$ArtistCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? photoUrl, String? photoCredit, List<Track> popular, List<Album> albums, List<Album> singles
});




}
/// @nodoc
class __$ArtistCopyWithImpl<$Res>
    implements _$ArtistCopyWith<$Res> {
  __$ArtistCopyWithImpl(this._self, this._then);

  final _Artist _self;
  final $Res Function(_Artist) _then;

/// Create a copy of Artist
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? photoUrl = freezed,Object? photoCredit = freezed,Object? popular = null,Object? albums = null,Object? singles = null,}) {
  return _then(_Artist(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,photoCredit: freezed == photoCredit ? _self.photoCredit : photoCredit // ignore: cast_nullable_to_non_nullable
as String?,popular: null == popular ? _self._popular : popular // ignore: cast_nullable_to_non_nullable
as List<Track>,albums: null == albums ? _self._albums : albums // ignore: cast_nullable_to_non_nullable
as List<Album>,singles: null == singles ? _self._singles : singles // ignore: cast_nullable_to_non_nullable
as List<Album>,
  ));
}


}

// dart format on
