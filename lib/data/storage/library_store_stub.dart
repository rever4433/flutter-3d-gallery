class LibraryStore {
  static Future<dynamic> invoke(String method,
      [Map<String, dynamic> data = const {}]) async {
    if (method == 'list') return {'models': <dynamic>[], 'covers': <dynamic>[]};
    throw Exception('请在手机或浏览器中使用模型库');
  }
}
