class MutationException implements Exception {
  final String message;

  const MutationException(this.message);

  @override
  String toString() {
    return "MutationException($message)";
  }
}
