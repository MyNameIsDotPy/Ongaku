// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'connection_test.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ConnectionTestResult {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConnectionTestResult);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ConnectionTestResult()';
}


}

/// @nodoc
class $ConnectionTestResultCopyWith<$Res>  {
$ConnectionTestResultCopyWith(ConnectionTestResult _, $Res Function(ConnectionTestResult) __);
}


/// Adds pattern-matching-related methods to [ConnectionTestResult].
extension ConnectionTestResultPatterns on ConnectionTestResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ConnectionTestSuccess value)?  success,TResult Function( ConnectionTestFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ConnectionTestSuccess() when success != null:
return success(_that);case ConnectionTestFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ConnectionTestSuccess value)  success,required TResult Function( ConnectionTestFailure value)  failure,}){
final _that = this;
switch (_that) {
case ConnectionTestSuccess():
return success(_that);case ConnectionTestFailure():
return failure(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ConnectionTestSuccess value)?  success,TResult? Function( ConnectionTestFailure value)?  failure,}){
final _that = this;
switch (_that) {
case ConnectionTestSuccess() when success != null:
return success(_that);case ConnectionTestFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int latencyMs)?  success,TResult Function( ApiErrorCode code)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ConnectionTestSuccess() when success != null:
return success(_that.latencyMs);case ConnectionTestFailure() when failure != null:
return failure(_that.code);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int latencyMs)  success,required TResult Function( ApiErrorCode code)  failure,}) {final _that = this;
switch (_that) {
case ConnectionTestSuccess():
return success(_that.latencyMs);case ConnectionTestFailure():
return failure(_that.code);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int latencyMs)?  success,TResult? Function( ApiErrorCode code)?  failure,}) {final _that = this;
switch (_that) {
case ConnectionTestSuccess() when success != null:
return success(_that.latencyMs);case ConnectionTestFailure() when failure != null:
return failure(_that.code);case _:
  return null;

}
}

}

/// @nodoc


class ConnectionTestSuccess implements ConnectionTestResult {
  const ConnectionTestSuccess({required this.latencyMs});
  

 final  int latencyMs;

/// Create a copy of ConnectionTestResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConnectionTestSuccessCopyWith<ConnectionTestSuccess> get copyWith => _$ConnectionTestSuccessCopyWithImpl<ConnectionTestSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConnectionTestSuccess&&(identical(other.latencyMs, latencyMs) || other.latencyMs == latencyMs));
}


@override
int get hashCode => Object.hash(runtimeType,latencyMs);

@override
String toString() {
  return 'ConnectionTestResult.success(latencyMs: $latencyMs)';
}


}

/// @nodoc
abstract mixin class $ConnectionTestSuccessCopyWith<$Res> implements $ConnectionTestResultCopyWith<$Res> {
  factory $ConnectionTestSuccessCopyWith(ConnectionTestSuccess value, $Res Function(ConnectionTestSuccess) _then) = _$ConnectionTestSuccessCopyWithImpl;
@useResult
$Res call({
 int latencyMs
});




}
/// @nodoc
class _$ConnectionTestSuccessCopyWithImpl<$Res>
    implements $ConnectionTestSuccessCopyWith<$Res> {
  _$ConnectionTestSuccessCopyWithImpl(this._self, this._then);

  final ConnectionTestSuccess _self;
  final $Res Function(ConnectionTestSuccess) _then;

/// Create a copy of ConnectionTestResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? latencyMs = null,}) {
  return _then(ConnectionTestSuccess(
latencyMs: null == latencyMs ? _self.latencyMs : latencyMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class ConnectionTestFailure implements ConnectionTestResult {
  const ConnectionTestFailure({required this.code});
  

 final  ApiErrorCode code;

/// Create a copy of ConnectionTestResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConnectionTestFailureCopyWith<ConnectionTestFailure> get copyWith => _$ConnectionTestFailureCopyWithImpl<ConnectionTestFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConnectionTestFailure&&(identical(other.code, code) || other.code == code));
}


@override
int get hashCode => Object.hash(runtimeType,code);

@override
String toString() {
  return 'ConnectionTestResult.failure(code: $code)';
}


}

/// @nodoc
abstract mixin class $ConnectionTestFailureCopyWith<$Res> implements $ConnectionTestResultCopyWith<$Res> {
  factory $ConnectionTestFailureCopyWith(ConnectionTestFailure value, $Res Function(ConnectionTestFailure) _then) = _$ConnectionTestFailureCopyWithImpl;
@useResult
$Res call({
 ApiErrorCode code
});




}
/// @nodoc
class _$ConnectionTestFailureCopyWithImpl<$Res>
    implements $ConnectionTestFailureCopyWith<$Res> {
  _$ConnectionTestFailureCopyWithImpl(this._self, this._then);

  final ConnectionTestFailure _self;
  final $Res Function(ConnectionTestFailure) _then;

/// Create a copy of ConnectionTestResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? code = null,}) {
  return _then(ConnectionTestFailure(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as ApiErrorCode,
  ));
}


}

// dart format on
