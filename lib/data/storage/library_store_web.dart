// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

class LibraryStore {
  static Future<dynamic> invoke(String method,
      [Map<String, dynamic> data = const {}]) async {
    final library = globalContext.getProperty<JSObject?>('GalleryLibrary'.toJS);
    if (library == null) {
      if (method == 'list') {
        return {'models': <dynamic>[], 'covers': <dynamic>[]};
      }
      throw Exception('模型库未就绪，请重新打开应用');
    }
    final result = await library
        .callMethod<JSPromise<JSString>>(
            'invoke'.toJS, method.toJS, jsonEncode(data).toJS)
        .toDart;
    final decoded = jsonDecode(result.toDart) as Map<String, dynamic>;
    if (decoded['error'] != null) throw Exception(decoded['error']);
    return decoded['value'];
  }
}
