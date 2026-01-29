class NetworkException implements Exception {
  final String message;

  NetworkException([
    this.message = 'No internet connection or server is unavailable.',
  ]);

  @override
  String toString() => message;
}
