import 'package:flutter/material.dart';

import '../../models/api_error.dart';
import '../../shared/design_system/design_system.dart';

/// Error state for any failure, showing the API code when there is one.
class ApiErrorView extends StatelessWidget {
  const ApiErrorView({super.key, required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final api = error is ApiException ? error as ApiException : null;
    if (api?.code == ApiErrorCode.notFound) {
      return EmptyState(
        icon: OngakuIcons.album,
        title: 'No lo encontramos',
        message: '${api!.code.wire} · ${api.code.description}',
        mono: true,
      );
    }
    return ErrorState(
      code: api?.code.wire ?? 'ERROR',
      message: api?.message ?? api?.code.description ?? '$error',
      onRetry: onRetry,
    );
  }
}
