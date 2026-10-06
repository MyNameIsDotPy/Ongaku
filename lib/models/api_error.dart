/// Error codes the UI must know how to show (requirements doc, API section).
enum ApiErrorCode {
  unauthorized('UNAUTHORIZED'),
  notFound('NOT_FOUND'),
  unavailable('UNAVAILABLE'),
  extractionFailed('EXTRACTION_FAILED'),
  rateLimited('RATE_LIMITED'),
  backendOffline('BACKEND_OFFLINE');

  const ApiErrorCode(this.wire);
  final String wire;

  String get description => switch (this) {
    ApiErrorCode.unauthorized => 'Revisa el token del dispositivo.',
    ApiErrorCode.notFound => 'No existe o se borró.',
    ApiErrorCode.unavailable => 'El video está bloqueado o es privado.',
    ApiErrorCode.extractionFailed =>
      'YouTube cambió algo y el backend aún no se actualiza.',
    ApiErrorCode.rateLimited => 'Demasiadas peticiones; espera un momento.',
    ApiErrorCode.backendOffline => 'El backend no responde.',
  };
}

class ApiException implements Exception {
  const ApiException(this.code, [this.message]);

  final ApiErrorCode code;
  final String? message;

  @override
  String toString() => '${code.wire}: ${message ?? code.description}';
}
