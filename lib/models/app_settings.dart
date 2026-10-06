import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';

enum AudioQuality { high, low }

/// Where music comes from: extracted from YouTube on this device, or the
/// built-in sample catalog (demo and tests).
enum MusicSource { youtube, sample }

enum ThemePreference { light, dark, system }

enum MotionLevel { full, reduced }

@freezed
abstract class AppSettings with _$AppSettings {
  const AppSettings._();

  const factory AppSettings({
    @Default('http://homelab.tail3c2e1.ts.net:8080') String backendUrl,
    @Default('') String token,
    @Default(AudioQuality.high) AudioQuality wifiQuality,
    @Default(AudioQuality.low) AudioQuality mobileQuality,
    @Default(true) bool downloadOnWifiOnly,
    @Default(8) int downloadLimitGb,
    @Default(ThemePreference.light) ThemePreference theme,
    @Default(MotionLevel.full) MotionLevel motion,

    /// Cover and aura react to the beat.
    @Default(true) bool reactiveVisuals,
    @Default(false) bool onboardingComplete,
    @Default(MusicSource.youtube) MusicSource source,

    /// Optional yt-dlp executable (PC fallback); empty = look in PATH.
    @Default('') String ytDlpPath,
  }) = _AppSettings;

  Map<String, Object> toPrefs() => {
    'backendUrl': backendUrl,
    'token': token,
    'wifiQuality': wifiQuality.name,
    'mobileQuality': mobileQuality.name,
    'downloadOnWifiOnly': downloadOnWifiOnly,
    'downloadLimitGb': downloadLimitGb,
    'theme': theme.name,
    'motion': motion.name,
    'reactiveVisuals': reactiveVisuals,
    'onboardingComplete': onboardingComplete,
  };

  static AppSettings fromPrefs(Map<String, Object?> m) {
    const d = AppSettings();
    T pick<T extends Enum>(List<T> values, Object? v, T fallback) =>
        values.firstWhere((e) => e.name == v, orElse: () => fallback);
    return AppSettings(
      backendUrl: m['backendUrl'] as String? ?? d.backendUrl,
      token: m['token'] as String? ?? d.token,
      wifiQuality: pick(AudioQuality.values, m['wifiQuality'], d.wifiQuality),
      mobileQuality: pick(
        AudioQuality.values,
        m['mobileQuality'],
        d.mobileQuality,
      ),
      downloadOnWifiOnly:
          m['downloadOnWifiOnly'] as bool? ?? d.downloadOnWifiOnly,
      downloadLimitGb: m['downloadLimitGb'] as int? ?? d.downloadLimitGb,
      theme: pick(ThemePreference.values, m['theme'], d.theme),
      motion: pick(MotionLevel.values, m['motion'], d.motion),
      reactiveVisuals: m['reactiveVisuals'] as bool? ?? d.reactiveVisuals,
      onboardingComplete:
          m['onboardingComplete'] as bool? ?? d.onboardingComplete,
      source: pick(MusicSource.values, m['source'], d.source),
      ytDlpPath: m['ytDlpPath'] as String? ?? d.ytDlpPath,
    );
  }
}
