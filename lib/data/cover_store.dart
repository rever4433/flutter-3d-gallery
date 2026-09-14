import 'dart:convert';

import 'storage/key_value_store.dart';

/// 封面本地存储。
///
/// 用户在查看器里「设为封面」后，截图会以 data URL 的形式存进
/// `localStorage`，下次打开依然生效 —— 不需要后端。
///
/// 容量策略：`localStorage` 单域名通常只有 ~5MB，
/// 因此这里维护了一个 LRU 索引，写入超出配额时会淘汰最旧的封面。
///
/// 具体的键值存储走 [KeyValueStore]，平台差异被条件导入隔离在
/// `storage/` 目录下，所以这个文件是纯 Dart，可以被单测覆盖。
abstract final class CoverStore {
  static const _prefix = 'gallery3d.cover.v1.';
  static const _indexKey = '${_prefix}__index';

  /// 存储不可用时的内存兜底（隐私模式等），保证 UI 不崩
  static final Map<String, String> _memory = {};

  static final KeyValueStore _kv = KeyValueStore.instance;

  static String _key(String modelId) => '$_prefix$modelId';

  // ── 索引（LRU） ─────────────────────────────────────────────────────────

  static Map<String, int> _readIndex() {
    final raw = _kv.read(_indexKey);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return decoded.map((k, v) => MapEntry('$k', v is int ? v : 0));
      }
    } catch (_) {
      // 索引损坏：直接重建
    }
    return {};
  }

  static void _writeIndex(Map<String, int> index) {
    _kv.write(_indexKey, jsonEncode(index));
  }

  // ── 读写 ────────────────────────────────────────────────────────────────

  /// 读取全部已保存的封面：`modelId -> dataUrl`
  static Map<String, String> readAll() {
    final result = Map<String, String>.from(_memory);

    for (final id in _readIndex().keys) {
      final value = _kv.read(_key(id));
      if (value != null && value.isNotEmpty) result[id] = value;
    }
    return result;
  }

  static String? read(String modelId) {
    final memory = _memory[modelId];
    if (memory != null) return memory;
    return _kv.read(_key(modelId));
  }

  /// 写入封面。配额不足时淘汰最旧的记录后重试。
  ///
  /// 返回 `true` 表示已持久化，`false` 表示只写进了内存兜底。
  static bool write(String modelId, String dataUrl) {
    final index = _readIndex()
      ..[modelId] = DateTime.now().millisecondsSinceEpoch;

    if (!_kv.isPersistent) {
      _memory[modelId] = dataUrl;
      return false;
    }

    for (var attempt = 0; attempt < 12; attempt++) {
      if (_kv.write(_key(modelId), dataUrl)) {
        _writeIndex(index);
        return true;
      }

      // 配额不足 —— 淘汰最旧的一条再试
      final oldest = _oldestId(index, except: modelId);
      if (oldest == null) break;
      _kv.remove(_key(oldest));
      index.remove(oldest);
    }

    _memory[modelId] = dataUrl;
    _writeIndex(index);
    return false;
  }

  static String? _oldestId(Map<String, int> index, {required String except}) {
    String? candidate;
    var oldest = 1 << 62;
    for (final entry in index.entries) {
      if (entry.key == except) continue;
      if (entry.value < oldest) {
        oldest = entry.value;
        candidate = entry.key;
      }
    }
    return candidate;
  }

  static void remove(String modelId) {
    _memory.remove(modelId);

    final index = _readIndex()..remove(modelId);
    _writeIndex(index);
    _kv.remove(_key(modelId));
  }

  static void clear() {
    _memory.clear();
    for (final id in _readIndex().keys) {
      _kv.remove(_key(id));
    }
    _kv.remove(_indexKey);
  }

  /// 已用存储的量级，用于展示
  static int approximateBytes() {
    var bytes = 0;
    for (final value in readAll().values) {
      bytes += value.length;
    }
    return bytes;
  }
}
