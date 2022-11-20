class GlobalStateApi {
  static Future<String> postLogin() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return "authToken";
  }
}