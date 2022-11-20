class AsyncGetApi {
  static Future<int> get() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return 1;
  }
}
