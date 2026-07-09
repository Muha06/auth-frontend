class UnauthenticatedException implements Exception {
  const UnauthenticatedException();

  @override
  String toString() => 'User is not authenticated.';
}
