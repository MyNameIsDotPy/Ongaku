# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Ongaku is an ad-free music player built with Flutter (Android, macOS, Linux, Windows). It pulls music from YouTube / YouTube Music **on the device**; there is no server. User-facing strings are in Spanish. Code comments tag features with requirement IDs (`RF-11`, `RF-29`, …) from `assets/docs/Requerimientos — App de música sin anuncios.md`. The HTML/JS prototype the UI is built from lives in `assets/design/`.

## Commands

```bash
flutter pub get
flutter run -d linux                         # or macos / windows / <android device id>
flutter analyze                              # lints: package:flutter_lints/flutter.yaml
flutter test                                 # all tests
flutter test test/core/stream_resolver_test.dart          # one file
flutter test --plain-name 'first run lands on the connection screen'  # one test by name
dart run build_runner build --delete-conflicting-outputs  # regenerate *.freezed.dart after editing lib/models
flutter run -d <android device> -t tool/android_stream_probe.dart  # on-device stream/playback probe (doesn't touch app data)
```

`lib/models/*.freezed.dart` files are generated and committed. Regenerate them, don't edit them.

## Architecture

**Layers:** `lib/models` (freezed data) → `lib/core` (abstract contracts plus implementations) → `lib/providers` (Riverpod wiring) → `lib/presentation` (screens) and `lib/shared/design_system` (tokens/atoms/molecules/organisms; import via `design_system.dart`). Routing is GoRouter in `lib/app/router.dart`, with a redirect to the connection/onboarding screen until `settings.onboardingComplete` is set.

**Two interchangeable backends behind the same contracts.** `CatalogRepository`, `LibraryRepository`, `DownloadManager`, `BackendClient` and `PlayerController` each have:
- `lib/core/fakes/`: sample catalog plus `FakeBackend`, which simulates conditions (offline, errors…) through `DemoScenario`. Used for demos and tests.
- `lib/core/local/`: the real on-device implementation.

`lib/providers/repository_providers.dart` chooses between them through `musicSourceProvider`. That provider is the user's setting (`MusicSource.youtube` / `.sample`), but it is forced to `sample` when `localServicesProvider` is null, as it is in tests. `main()` opens `LocalServices` (JSON-file library/downloads under the app support dir plus a single `YoutubeGateway`) and the `audio_service` handler, then injects both through `ProviderScope` overrides. `ProviderScope.retry` is disabled on purpose: errors show a "Reintentar" button instead of retrying silently.

**YouTube access:**
- `YoutubeGateway` is the single `youtube_explode_dart` client. Every call goes through `gateway((yt) => ...)`, which maps failures to `ApiException(ApiErrorCode…)` and reports reachability (`onNetwork` → `youtubeReachableProvider`). On desktop it uses Deno as a JS challenge solver when Deno is on PATH.
- `YoutubeMusicClient` (InnerTube) provides catalog search, albums and artists, falling back to plain YouTube search. `youtube_mapping.dart` and `playlist_reader.dart` turn responses into models.
- `StreamResolver` tries sources in this order: downloaded file → fresh audio-only manifest URL (45 s timeout) → `yt-dlp` (desktop only; path configurable in Settings). Android stream URLs can be single-use, so resolve a fresh one for each load instead of caching it.
- `YoutubeAudioSource` streams to just_audio in bounded 256 KB range requests, because YouTube rejects open-ended or whole-file ranges.
- Lyrics come from lrclib.net (`lrclib_lyrics.dart`).

**Playback:** `QueuePlayerController` owns the queue and the state machine and exposes `PlayerSnapshot`s. It drives a `PlaybackEngine` (`lib/core/player/playback_engine.dart`), which only loads, plays and reports progress/buffering/completion/errors. The engines are `JustAudioEngine` (real; media_kit/libmpv on Linux/Windows) and `SimulatedEngine` (sample mode). `OngakuAudioHandler` attaches the controller to the OS media session on Android and macOS. `player_persistence.dart` saves the queue, index and position and restores them at startup.

**Platform notes:** The macOS sandbox is disabled so yt-dlp and Deno can run. Android uses a foreground media service (see `AndroidManifest.xml`).
