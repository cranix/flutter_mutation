class GettingStartedApi {
  static Future<String> get() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return "done";
  }
}
