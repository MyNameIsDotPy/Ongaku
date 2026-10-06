import 'package:freezed_annotation/freezed_annotation.dart';

import 'track.dart';

part 'play_event.freezed.dart';

enum DeviceKind { phone, pc }

extension DeviceKindLabel on DeviceKind {
  String get label => switch (this) {
    DeviceKind.phone => 'Celular',
    DeviceKind.pc => 'PC',
  };
}

@freezed
abstract class PlayEvent with _$PlayEvent {
  const factory PlayEvent({
    required Track track,
    required DateTime playedAt,
    required DeviceKind device,
  }) = _PlayEvent;
}
