class AsyncGet2Api {
  static Future<String> get() async {
    await Future.delayed(const Duration(milliseconds: 500));
    print("async_get2.get()");
    return "success";
  }
  static Future<String> get2() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    print("async_get2.get2()");
    return "success2";
  }
  static Future<String> get3() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    print("async_get2.get3()");
    return "success3";
  }
}
