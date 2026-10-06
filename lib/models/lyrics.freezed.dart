// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lyrics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LyricLine {

 Duration get start; Duration get end; String get text;/// A gap between sung lines; rendered as three dots that pulse.
 bool get instrumental;
/// Create a copy of LyricLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LyricLineCopyWith<LyricLine> get copyWith => _$LyricLineCopyWithImpl<LyricLine>(this as LyricLine, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LyricLine&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.text, text) || other.text == text)&&(identical(other.instrumental, instrumental) || other.instrumental == instrumental));
}


@override
int get hashCode => Object.hash(runtimeType,start,end,text,instrumental);

@override
String toString() {
  return 'LyricLine(start: $start, end: $end, text: $text, instrumental: $instrumental)';
}


}

/// @nodoc
abstract mixin class $LyricLineCopyWith<$Res>  {
  factory $LyricLineCopyWith(LyricLine value, $Res Function(LyricLine) _then) = _$LyricLineCopyWithImpl;
@useResult
$Res call({
 Duration start, Duration end, String text, bool instrumental
});




}
/// @nodoc
class _$LyricLineCopyWithImpl<$Res>
    implements $LyricLineCopyWith<$Res> {
  _$LyricLineCopyWithImpl(this._self, this._then);

  final LyricLine _self;
  final $Res Function(LyricLine) _then;

/// Create a copy of LyricLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? start = null,Object? end = null,Object? text = null,Object? instrumental = null,}) {
  return _then(_self.copyWith(
start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as Duration,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as Duration,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,instrumental: null == instrumental ? _self.instrumental : instrumental // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LyricLine].
extension LyricLinePatterns on LyricLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LyricLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LyricLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LyricLine value)  $default,){
final _that = this;
switch (_that) {
case _LyricLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LyricLine value)?  $default,){
final _that = this;
switch (_that) {
case _LyricLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Duration start,  Duration end,  String text,  bool instrumental)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LyricLine() when $default != null:
return $default(_that.start,_that.end,_that.text,_that.instrumental);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Duration start,  Duration end,  String text,  bool instrumental)  $default,) {final _that = this;
switch (_that) {
case _LyricLine():
return $default(_that.start,_that.end,_that.text,_that.instrumental);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Duration start,  Duration end,  String text,  bool instrumental)?  $default,) {final _that = this;
switch (_that) {
case _LyricLine() when $default != null:
return $default(_that.start,_that.end,_that.text,_that.instrumental);case _:
  return null;

}
}

}

/// @nodoc


class _LyricLine implements LyricLine {
  const _LyricLine({required this.start, required this.end, this.text = '', this.instrumental = false});
  

@override final  Duration start;
@override final  Duration end;
@override@JsonKey() final  String text;
/// A gap between sung lines; rendered as three dots that pulse.
@override@JsonKey() final  bool instrumental;

/// Create a copy of LyricLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LyricLineCopyWith<_LyricLine> get copyWith => __$LyricLineCopyWithImpl<_LyricLine>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LyricLine&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.text, text) || other.text == text)&&(identical(other.instrumental, instrumental) || other.instrumental == instrumental));
}


@override
int get hashCode => Object.hash(runtimeType,start,end,text,instrumental);

@override
String toString() {
  return 'LyricLine(start: $start, end: $end, text: $text, instrumental: $instrumental)';
}


}

/// @nodoc
abstract mixin class _$LyricLineCopyWith<$Res> implements $LyricLineCopyWith<$Res> {
  factory _$LyricLineCopyWith(_LyricLine value, $Res Function(_LyricLine) _then) = __$LyricLineCopyWithImpl;
@override @useResult
$Res call({
 Duration start, Duration end, String text, bool instrumental
});




}
/// @nodoc
class __$LyricLineCopyWithImpl<$Res>
    implements _$LyricLineCopyWith<$Res> {
  __$LyricLineCopyWithImpl(this._self, this._then);

  final _LyricLine _self;
  final $Res Function(_LyricLine) _then;

/// Create a copy of LyricLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? start = null,Object? end = null,Object? text = null,Object? instrumental = null,}) {
  return _then(_LyricLine(
start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as Duration,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as Duration,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,instrumental: null == instrumental ? _self.instrumental : instrumental // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$Lyrics {

 bool get synced; List<LyricLine> get lines;
/// Create a copy of Lyrics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LyricsCopyWith<Lyrics> get copyWith => _$LyricsCopyWithImpl<Lyrics>(this as Lyrics, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Lyrics&&(identical(other.synced, synced) || other.synced == synced)&&const DeepCollectionEquality().equals(other.lines, lines));
}


@override
int get hashCode => Object.hash(runtimeType,synced,const DeepCollectionEquality().hash(lines));

@override
String toString() {
  return 'Lyrics(synced: $synced, lines: $lines)';
}


}

/// @nodoc
abstract mixin class $LyricsCopyWith<$Res>  {
  factory $LyricsCopyWith(Lyrics value, $Res Function(Lyrics) _then) = _$LyricsCopyWithImpl;
@useResult
$Res call({
 bool synced, List<LyricLine> lines
});




}
/// @nodoc
class _$LyricsCopyWithImpl<$Res>
    implements $LyricsCopyWith<$Res> {
  _$LyricsCopyWithImpl(this._self, this._then);

  final Lyrics _self;
  final $Res Function(Lyrics) _then;

/// Create a copy of Lyrics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? synced = null,Object? lines = null,}) {
  return _then(_self.copyWith(
synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<LyricLine>,
  ));
}

}


/// Adds pattern-matching-related methods to [Lyrics].
extension LyricsPatterns on Lyrics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Lyrics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Lyrics() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Lyrics value)  $default,){
final _that = this;
switch (_that) {
case _Lyrics():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Lyrics value)?  $default,){
final _that = this;
switch (_that) {
case _Lyrics() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool synced,  List<LyricLine> lines)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Lyrics() when $default != null:
return $default(_that.synced,_that.lines);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool synced,  List<LyricLine> lines)  $default,) {final _that = this;
switch (_that) {
case _Lyrics():
return $default(_that.synced,_that.lines);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool synced,  List<LyricLine> lines)?  $default,) {final _that = this;
switch (_that) {
case _Lyrics() when $default != null:
return $default(_that.synced,_that.lines);case _:
  return null;

}
}

}

/// @nodoc


class _Lyrics implements Lyrics {
  const _Lyrics({required this.synced, required final  List<LyricLine> lines}): _lines = lines;
  

@override final  bool synced;
 final  List<LyricLine> _lines;
@override List<LyricLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}


/// Create a copy of Lyrics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LyricsCopyWith<_Lyrics> get copyWith => __$LyricsCopyWithImpl<_Lyrics>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Lyrics&&(identical(other.synced, synced) || other.synced == synced)&&const DeepCollectionEquality().equals(other._lines, _lines));
}


@override
int get hashCode => Object.hash(runtimeType,synced,const DeepCollectionEquality().hash(_lines));

@override
String toString() {
  return 'Lyrics(synced: $synced, lines: $lines)';
}


}

/// @nodoc
abstract mixin class _$LyricsCopyWith<$Res> implements $LyricsCopyWith<$Res> {
  factory _$LyricsCopyWith(_Lyrics value, $Res Function(_Lyrics) _then) = __$LyricsCopyWithImpl;
@override @useResult
$Res call({
 bool synced, List<LyricLine> lines
});




}
/// @nodoc
class __$LyricsCopyWithImpl<$Res>
    implements _$LyricsCopyWith<$Res> {
  __$LyricsCopyWithImpl(this._self, this._then);

  final _Lyrics _self;
  final $Res Function(_Lyrics) _then;

/// Create a copy of Lyrics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? synced = null,Object? lines = null,}) {
  return _then(_Lyrics(
synced: null == synced ? _self.synced : synced // ignore: cast_nullable_to_non_nullable
as bool,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<LyricLine>,
  ));
}


}

// dart format on
