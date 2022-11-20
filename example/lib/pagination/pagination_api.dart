import 'dart:math';

class PaginationApi {
  static Future<PaginationResponse> getList([String? nextPageKey]) async {
    await Future.delayed(const Duration(milliseconds: 500));
    List<String> list = [];
    for (int i = 0; i < 5; i++) {
      list.add("item_${Random().nextInt(500)}");
    }
    return PaginationResponse(list, null);
  }
}

class PaginationResponse {
  final List<String> list;
  final String? nextPageKey;

  PaginationResponse(this.list, this.nextPageKey);
}
