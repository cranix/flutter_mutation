class LazyMutateApi {
  static Future<String> get() async {
    await Future.delayed(const Duration(milliseconds: 3000));
    return "done";
  }
  static Future<String> get2() async {
    await Future.delayed(const Duration(milliseconds: 3000));
    return "done2";
  }
}
