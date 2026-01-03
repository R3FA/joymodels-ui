class SessionExpiredException implements Exception {
  final String message;

  SessionExpiredException([
    this.message = 'Session expired.  Please login again.',
  ]);

  @override
  String toString() => message;
}
