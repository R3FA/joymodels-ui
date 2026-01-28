class ForbiddenException implements Exception {
  final String message;

  ForbiddenException([
    this.message = 'You do not have permission to access this resource.',
  ]);

  @override
  String toString() => message;
}
