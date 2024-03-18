import 'dart:math';

class AsyncGetApi3 {
  static Future<bool> get() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Random().nextBool();
  }

  static Future<int> getError() async {
    await Future.delayed(const Duration(milliseconds: 500));
    throw "error";
    return 1;
  }
}
