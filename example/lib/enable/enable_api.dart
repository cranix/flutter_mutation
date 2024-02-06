class EnableApi {
  static Future<String> get() async {
    await Future.delayed(const Duration(milliseconds: 500));
    print("EnableApi.get()");
    return "success";
  }
}
