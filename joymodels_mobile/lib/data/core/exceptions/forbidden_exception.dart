class ForbiddenException implements Exception {
  final String message;

  ForbiddenException([
    this.message =
        'Access denied. You do not have permission to access this resource.',
  ]);

  @override
  String toString() => message;
}
