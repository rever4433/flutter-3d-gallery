// 这个文件是 Web 专用实现，平台差异被刻意收在这一个文件里。
// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

/// `localStorage` 实现。
///
/// 隐私模式下访问 `window.localStorage` 会直接抛异常，
/// 所以每个成员都必须包在 try/catch 里。
class KeyValueStore {
  KeyValueStore._();

  static final KeyValueStore instance = KeyValueStore._();

  html.Storage? get _storage {
    try {
      return html.window.localStorage;
    } catch (_) {
      return null;
    }
  }

  bool get isPersistent => _storage != null;

  String? read(String key) {
    try {
      return _storage?[key];
    } catch (_) {
      return null;
    }
  }

  /// 返回 `false` 通常意味着配额已满（`QuotaExceededError`）
  bool write(String key, String value) {
    final storage = _storage;
    if (storage == null) return false;
    try {
      storage[key] = value;
      return true;
    } catch (_) {
      return false;
    }
  }

  void remove(String key) {
    try {
      _storage?.remove(key);
    } catch (_) {
      // 忽略
    }
  }

  void clear() {
    try {
      _storage?.clear();
    } catch (_) {
      // 忽略
    }
  }
}
