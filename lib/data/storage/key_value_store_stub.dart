/// 非 Web 平台的空实现：不持久化任何东西。
///
/// 这个 App 的 3D 预览依赖 `<model-viewer>`，实际只跑在 Web 上；
/// 这个分支存在的意义是让数据层的逻辑可以在 VM 上被单测覆盖。
class KeyValueStore {
  KeyValueStore._();

  static final KeyValueStore instance = KeyValueStore._();

  /// 平台是否支持持久化
  bool get isPersistent => false;

  String? read(String key) => null;

  /// 返回 `false` 表示没有真正写入
  bool write(String key, String value) => false;

  void remove(String key) {}

  void clear() {}
}
