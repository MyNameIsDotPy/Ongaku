import 'package:freezed_annotation/freezed_annotation.dart';

import 'api_error.dart';

part 'connection_test.freezed.dart';

@freezed
sealed class ConnectionTestResult with _$ConnectionTestResult {
  const factory ConnectionTestResult.success({required int latencyMs}) =
      ConnectionTestSuccess;
  const factory ConnectionTestResult.failure({required ApiErrorCode code}) =
      ConnectionTestFailure;
}
