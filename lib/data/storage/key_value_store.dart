/// 键值存储的平台适配入口。
///
/// 数据层不应该直接依赖 `dart:html` —— 否则 `GalleryProvider` 这类纯逻辑
/// 就没法在 VM 上跑单测了。这里用条件导入把平台差异隔离在一个文件里：
///
///  * Web（`dart.library.js_interop` 为真）→ `localStorage`
///  * 其他平台 → 无持久化，[KeyValueStore.write] 返回 `false`，
///    由上层决定怎么兜底
library;

export 'key_value_store_stub.dart'
    if (dart.library.js_interop) 'key_value_store_web.dart';
