// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppSettings {

 String get backendUrl; String get token; AudioQuality get wifiQuality; AudioQuality get mobileQuality; bool get downloadOnWifiOnly; int get downloadLimitGb; ThemePreference get theme; MotionLevel get motion;/// Cover and aura react to the beat.
 bool get reactiveVisuals; bool get onboardingComplete;
/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppSettingsCopyWith<AppSettings> get copyWith => _$AppSettingsCopyWithImpl<AppSettings>(this as AppSettings, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppSettings&&(identical(other.backendUrl, backendUrl) || other.backendUrl == backendUrl)&&(identical(other.token, token) || other.token == token)&&(identical(other.wifiQuality, wifiQuality) || other.wifiQuality == wifiQuality)&&(identical(other.mobileQuality, mobileQuality) || other.mobileQuality == mobileQuality)&&(identical(other.downloadOnWifiOnly, downloadOnWifiOnly) || other.downloadOnWifiOnly == downloadOnWifiOnly)&&(identical(other.downloadLimitGb, downloadLimitGb) || other.downloadLimitGb == downloadLimitGb)&&(identical(other.theme, theme) || other.theme == theme)&&(identical(other.motion, motion) || other.motion == motion)&&(identical(other.reactiveVisuals, reactiveVisuals) || other.reactiveVisuals == reactiveVisuals)&&(identical(other.onboardingComplete, onboardingComplete) || other.onboardingComplete == onboardingComplete));
}


@override
int get hashCode => Object.hash(runtimeType,backendUrl,token,wifiQuality,mobileQuality,downloadOnWifiOnly,downloadLimitGb,theme,motion,reactiveVisuals,onboardingComplete);

@override
String toString() {
  return 'AppSettings(backendUrl: $backendUrl, token: $token, wifiQuality: $wifiQuality, mobileQuality: $mobileQuality, downloadOnWifiOnly: $downloadOnWifiOnly, downloadLimitGb: $downloadLimitGb, theme: $theme, motion: $motion, reactiveVisuals: $reactiveVisuals, onboardingComplete: $onboardingComplete)';
}


}

/// @nodoc
abstract mixin class $AppSettingsCopyWith<$Res>  {
  factory $AppSettingsCopyWith(AppSettings value, $Res Function(AppSettings) _then) = _$AppSettingsCopyWithImpl;
@useResult
$Res call({
 String backendUrl, String token, AudioQuality wifiQuality, AudioQuality mobileQuality, bool downloadOnWifiOnly, int downloadLimitGb, ThemePreference theme, MotionLevel motion, bool reactiveVisuals, bool onboardingComplete
});




}
/// @nodoc
class _$AppSettingsCopyWithImpl<$Res>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._self, this._then);

  final AppSettings _self;
  final $Res Function(AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? backendUrl = null,Object? token = null,Object? wifiQuality = null,Object? mobileQuality = null,Object? downloadOnWifiOnly = null,Object? downloadLimitGb = null,Object? theme = null,Object? motion = null,Object? reactiveVisuals = null,Object? onboardingComplete = null,}) {
  return _then(_self.copyWith(
backendUrl: null == backendUrl ? _self.backendUrl : backendUrl // ignore: cast_nullable_to_non_nullable
as String,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,wifiQuality: null == wifiQuality ? _self.wifiQuality : wifiQuality // ignore: cast_nullable_to_non_nullable
as AudioQuality,mobileQuality: null == mobileQuality ? _self.mobileQuality : mobileQuality // ignore: cast_nullable_to_non_nullable
as AudioQuality,downloadOnWifiOnly: null == downloadOnWifiOnly ? _self.downloadOnWifiOnly : downloadOnWifiOnly // ignore: cast_nullable_to_non_nullable
as bool,downloadLimitGb: null == downloadLimitGb ? _self.downloadLimitGb : downloadLimitGb // ignore: cast_nullable_to_non_nullable
as int,theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as ThemePreference,motion: null == motion ? _self.motion : motion // ignore: cast_nullable_to_non_nullable
as MotionLevel,reactiveVisuals: null == reactiveVisuals ? _self.reactiveVisuals : reactiveVisuals // ignore: cast_nullable_to_non_nullable
as bool,onboardingComplete: null == onboardingComplete ? _self.onboardingComplete : onboardingComplete // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AppSettings].
extension AppSettingsPatterns on AppSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppSettings value)  $default,){
final _that = this;
switch (_that) {
case _AppSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppSettings value)?  $default,){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String backendUrl,  String token,  AudioQuality wifiQuality,  AudioQuality mobileQuality,  bool downloadOnWifiOnly,  int downloadLimitGb,  ThemePreference theme,  MotionLevel motion,  bool reactiveVisuals,  bool onboardingComplete)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.backendUrl,_that.token,_that.wifiQuality,_that.mobileQuality,_that.downloadOnWifiOnly,_that.downloadLimitGb,_that.theme,_that.motion,_that.reactiveVisuals,_that.onboardingComplete);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String backendUrl,  String token,  AudioQuality wifiQuality,  AudioQuality mobileQuality,  bool downloadOnWifiOnly,  int downloadLimitGb,  ThemePreference theme,  MotionLevel motion,  bool reactiveVisuals,  bool onboardingComplete)  $default,) {final _that = this;
switch (_that) {
case _AppSettings():
return $default(_that.backendUrl,_that.token,_that.wifiQuality,_that.mobileQuality,_that.downloadOnWifiOnly,_that.downloadLimitGb,_that.theme,_that.motion,_that.reactiveVisuals,_that.onboardingComplete);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String backendUrl,  String token,  AudioQuality wifiQuality,  AudioQuality mobileQuality,  bool downloadOnWifiOnly,  int downloadLimitGb,  ThemePreference theme,  MotionLevel motion,  bool reactiveVisuals,  bool onboardingComplete)?  $default,) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.backendUrl,_that.token,_that.wifiQuality,_that.mobileQuality,_that.downloadOnWifiOnly,_that.downloadLimitGb,_that.theme,_that.motion,_that.reactiveVisuals,_that.onboardingComplete);case _:
  return null;

}
}

}

/// @nodoc


class _AppSettings extends AppSettings {
  const _AppSettings({this.backendUrl = 'http://homelab.tail3c2e1.ts.net:8080', this.token = '', this.wifiQuality = AudioQuality.high, this.mobileQuality = AudioQuality.low, this.downloadOnWifiOnly = true, this.downloadLimitGb = 8, this.theme = ThemePreference.light, this.motion = MotionLevel.full, this.reactiveVisuals = true, this.onboardingComplete = false}): super._();
  

@override@JsonKey() final  String backendUrl;
@override@JsonKey() final  String token;
@override@JsonKey() final  AudioQuality wifiQuality;
@override@JsonKey() final  AudioQuality mobileQuality;
@override@JsonKey() final  bool downloadOnWifiOnly;
@override@JsonKey() final  int downloadLimitGb;
@override@JsonKey() final  ThemePreference theme;
@override@JsonKey() final  MotionLevel motion;
/// Cover and aura react to the beat.
@override@JsonKey() final  bool reactiveVisuals;
@override@JsonKey() final  bool onboardingComplete;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppSettingsCopyWith<_AppSettings> get copyWith => __$AppSettingsCopyWithImpl<_AppSettings>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppSettings&&(identical(other.backendUrl, backendUrl) || other.backendUrl == backendUrl)&&(identical(other.token, token) || other.token == token)&&(identical(other.wifiQuality, wifiQuality) || other.wifiQuality == wifiQuality)&&(identical(other.mobileQuality, mobileQuality) || other.mobileQuality == mobileQuality)&&(identical(other.downloadOnWifiOnly, downloadOnWifiOnly) || other.downloadOnWifiOnly == downloadOnWifiOnly)&&(identical(other.downloadLimitGb, downloadLimitGb) || other.downloadLimitGb == downloadLimitGb)&&(identical(other.theme, theme) || other.theme == theme)&&(identical(other.motion, motion) || other.motion == motion)&&(identical(other.reactiveVisuals, reactiveVisuals) || other.reactiveVisuals == reactiveVisuals)&&(identical(other.onboardingComplete, onboardingComplete) || other.onboardingComplete == onboardingComplete));
}


@override
int get hashCode => Object.hash(runtimeType,backendUrl,token,wifiQuality,mobileQuality,downloadOnWifiOnly,downloadLimitGb,theme,motion,reactiveVisuals,onboardingComplete);

@override
String toString() {
  return 'AppSettings(backendUrl: $backendUrl, token: $token, wifiQuality: $wifiQuality, mobileQuality: $mobileQuality, downloadOnWifiOnly: $downloadOnWifiOnly, downloadLimitGb: $downloadLimitGb, theme: $theme, motion: $motion, reactiveVisuals: $reactiveVisuals, onboardingComplete: $onboardingComplete)';
}


}

/// @nodoc
abstract mixin class _$AppSettingsCopyWith<$Res> implements $AppSettingsCopyWith<$Res> {
  factory _$AppSettingsCopyWith(_AppSettings value, $Res Function(_AppSettings) _then) = __$AppSettingsCopyWithImpl;
@override @useResult
$Res call({
 String backendUrl, String token, AudioQuality wifiQuality, AudioQuality mobileQuality, bool downloadOnWifiOnly, int downloadLimitGb, ThemePreference theme, MotionLevel motion, bool reactiveVisuals, bool onboardingComplete
});




}
/// @nodoc
class __$AppSettingsCopyWithImpl<$Res>
    implements _$AppSettingsCopyWith<$Res> {
  __$AppSettingsCopyWithImpl(this._self, this._then);

  final _AppSettings _self;
  final $Res Function(_AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? backendUrl = null,Object? token = null,Object? wifiQuality = null,Object? mobileQuality = null,Object? downloadOnWifiOnly = null,Object? downloadLimitGb = null,Object? theme = null,Object? motion = null,Object? reactiveVisuals = null,Object? onboardingComplete = null,}) {
  return _then(_AppSettings(
backendUrl: null == backendUrl ? _self.backendUrl : backendUrl // ignore: cast_nullable_to_non_nullable
as String,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,wifiQuality: null == wifiQuality ? _self.wifiQuality : wifiQuality // ignore: cast_nullable_to_non_nullable
as AudioQuality,mobileQuality: null == mobileQuality ? _self.mobileQuality : mobileQuality // ignore: cast_nullable_to_non_nullable
as AudioQuality,downloadOnWifiOnly: null == downloadOnWifiOnly ? _self.downloadOnWifiOnly : downloadOnWifiOnly // ignore: cast_nullable_to_non_nullable
as bool,downloadLimitGb: null == downloadLimitGb ? _self.downloadLimitGb : downloadLimitGb // ignore: cast_nullable_to_non_nullable
as int,theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as ThemePreference,motion: null == motion ? _self.motion : motion // ignore: cast_nullable_to_non_nullable
as MotionLevel,reactiveVisuals: null == reactiveVisuals ? _self.reactiveVisuals : reactiveVisuals // ignore: cast_nullable_to_non_nullable
as bool,onboardingComplete: null == onboardingComplete ? _self.onboardingComplete : onboardingComplete // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
