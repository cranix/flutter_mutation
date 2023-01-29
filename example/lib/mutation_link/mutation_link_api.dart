class MutationLinkApi {
  static Future<String> get1() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return "get1 success";
  }
  static Future<String> get2() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return "get2 success";
  }
}