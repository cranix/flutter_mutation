class AsyncGetApi {
  static Future<int> get() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return 1;
  }
  static Future<int> getError() async {
    await Future.delayed(const Duration(milliseconds: 500));
    throw "error";
    return 1;
  }
}
