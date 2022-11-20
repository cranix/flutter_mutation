class CachingApi {
  static Future<CachingResponse> get() async {
    await Future.delayed(const Duration(milliseconds: 3000));
    return CachingResponse(
        "test title", "cranix", "caching example contents");
  }
}

class CachingResponse {
  final String title;
  final String nickname;
  final String contents;

  CachingResponse(this.title, this.nickname, this.contents);
}
