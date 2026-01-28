class SessionExpiredException implements Exception {
  final String message;

  SessionExpiredException([
    this.message = 'Your session has expired. Please log in again.',
  ]);

  @override
  String toString() => message;
}
