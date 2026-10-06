// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'download_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DownloadEntry {

 String get collectionId; DownloadKind get kind; String get title; List<String> get trackIds; int get completedTracks; double get sizeMb; DownloadStatus get status;
/// Create a copy of DownloadEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DownloadEntryCopyWith<DownloadEntry> get copyWith => _$DownloadEntryCopyWithImpl<DownloadEntry>(this as DownloadEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadEntry&&(identical(other.collectionId, collectionId) || other.collectionId == collectionId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.trackIds, trackIds)&&(identical(other.completedTracks, completedTracks) || other.completedTracks == completedTracks)&&(identical(other.sizeMb, sizeMb) || other.sizeMb == sizeMb)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,collectionId,kind,title,const DeepCollectionEquality().hash(trackIds),completedTracks,sizeMb,status);

@override
String toString() {
  return 'DownloadEntry(collectionId: $collectionId, kind: $kind, title: $title, trackIds: $trackIds, completedTracks: $completedTracks, sizeMb: $sizeMb, status: $status)';
}


}

/// @nodoc
abstract mixin class $DownloadEntryCopyWith<$Res>  {
  factory $DownloadEntryCopyWith(DownloadEntry value, $Res Function(DownloadEntry) _then) = _$DownloadEntryCopyWithImpl;
@useResult
$Res call({
 String collectionId, DownloadKind kind, String title, List<String> trackIds, int completedTracks, double sizeMb, DownloadStatus status
});




}
/// @nodoc
class _$DownloadEntryCopyWithImpl<$Res>
    implements $DownloadEntryCopyWith<$Res> {
  _$DownloadEntryCopyWithImpl(this._self, this._then);

  final DownloadEntry _self;
  final $Res Function(DownloadEntry) _then;

/// Create a copy of DownloadEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? collectionId = null,Object? kind = null,Object? title = null,Object? trackIds = null,Object? completedTracks = null,Object? sizeMb = null,Object? status = null,}) {
  return _then(_self.copyWith(
collectionId: null == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as DownloadKind,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,trackIds: null == trackIds ? _self.trackIds : trackIds // ignore: cast_nullable_to_non_nullable
as List<String>,completedTracks: null == completedTracks ? _self.completedTracks : completedTracks // ignore: cast_nullable_to_non_nullable
as int,sizeMb: null == sizeMb ? _self.sizeMb : sizeMb // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DownloadStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [DownloadEntry].
extension DownloadEntryPatterns on DownloadEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DownloadEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DownloadEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DownloadEntry value)  $default,){
final _that = this;
switch (_that) {
case _DownloadEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DownloadEntry value)?  $default,){
final _that = this;
switch (_that) {
case _DownloadEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String collectionId,  DownloadKind kind,  String title,  List<String> trackIds,  int completedTracks,  double sizeMb,  DownloadStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DownloadEntry() when $default != null:
return $default(_that.collectionId,_that.kind,_that.title,_that.trackIds,_that.completedTracks,_that.sizeMb,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String collectionId,  DownloadKind kind,  String title,  List<String> trackIds,  int completedTracks,  double sizeMb,  DownloadStatus status)  $default,) {final _that = this;
switch (_that) {
case _DownloadEntry():
return $default(_that.collectionId,_that.kind,_that.title,_that.trackIds,_that.completedTracks,_that.sizeMb,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String collectionId,  DownloadKind kind,  String title,  List<String> trackIds,  int completedTracks,  double sizeMb,  DownloadStatus status)?  $default,) {final _that = this;
switch (_that) {
case _DownloadEntry() when $default != null:
return $default(_that.collectionId,_that.kind,_that.title,_that.trackIds,_that.completedTracks,_that.sizeMb,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _DownloadEntry extends DownloadEntry {
  const _DownloadEntry({required this.collectionId, required this.kind, required this.title, required final  List<String> trackIds, this.completedTracks = 0, this.sizeMb = 0.0, this.status = DownloadStatus.downloading}): _trackIds = trackIds,super._();
  

@override final  String collectionId;
@override final  DownloadKind kind;
@override final  String title;
 final  List<String> _trackIds;
@override List<String> get trackIds {
  if (_trackIds is EqualUnmodifiableListView) return _trackIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_trackIds);
}

@override@JsonKey() final  int completedTracks;
@override@JsonKey() final  double sizeMb;
@override@JsonKey() final  DownloadStatus status;

/// Create a copy of DownloadEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DownloadEntryCopyWith<_DownloadEntry> get copyWith => __$DownloadEntryCopyWithImpl<_DownloadEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DownloadEntry&&(identical(other.collectionId, collectionId) || other.collectionId == collectionId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._trackIds, _trackIds)&&(identical(other.completedTracks, completedTracks) || other.completedTracks == completedTracks)&&(identical(other.sizeMb, sizeMb) || other.sizeMb == sizeMb)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,collectionId,kind,title,const DeepCollectionEquality().hash(_trackIds),completedTracks,sizeMb,status);

@override
String toString() {
  return 'DownloadEntry(collectionId: $collectionId, kind: $kind, title: $title, trackIds: $trackIds, completedTracks: $completedTracks, sizeMb: $sizeMb, status: $status)';
}


}

/// @nodoc
abstract mixin class _$DownloadEntryCopyWith<$Res> implements $DownloadEntryCopyWith<$Res> {
  factory _$DownloadEntryCopyWith(_DownloadEntry value, $Res Function(_DownloadEntry) _then) = __$DownloadEntryCopyWithImpl;
@override @useResult
$Res call({
 String collectionId, DownloadKind kind, String title, List<String> trackIds, int completedTracks, double sizeMb, DownloadStatus status
});




}
/// @nodoc
class __$DownloadEntryCopyWithImpl<$Res>
    implements _$DownloadEntryCopyWith<$Res> {
  __$DownloadEntryCopyWithImpl(this._self, this._then);

  final _DownloadEntry _self;
  final $Res Function(_DownloadEntry) _then;

/// Create a copy of DownloadEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? collectionId = null,Object? kind = null,Object? title = null,Object? trackIds = null,Object? completedTracks = null,Object? sizeMb = null,Object? status = null,}) {
  return _then(_DownloadEntry(
collectionId: null == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as DownloadKind,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,trackIds: null == trackIds ? _self._trackIds : trackIds // ignore: cast_nullable_to_non_nullable
as List<String>,completedTracks: null == completedTracks ? _self.completedTracks : completedTracks // ignore: cast_nullable_to_non_nullable
as int,sizeMb: null == sizeMb ? _self.sizeMb : sizeMb // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DownloadStatus,
  ));
}


}

// dart format on
