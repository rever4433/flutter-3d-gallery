import 'package:flutter/foundation.dart';

/// 3D 模型数据类
@immutable
class Model3D {
  /// 唯一标识，同时用作封面的 localStorage key
  final String id;

  /// 展示名称
  final String name;

  /// 所属分类
  final ModelCategory category;

  /// 一句话描述
  final String description;

  /// 模型地址。支持两种写法：
  ///  - 裸文件名 / 绝对路径 —— 作为 Web 静态资源从站点根目录加载
  ///    （例如 `'house.glb'` 会请求 `https://host/house.glb`）
  ///  - 完整 URL —— 直接使用
  final String modelPath;

  /// 封面图（可选）。三种来源，优先级从低到高：
  ///
  ///  1. 这里的 [coverImage] —— 静态封面，可以是
  ///     `assets/covers/xxx.jpg` 这样的 Flutter asset，
  ///     也可以是 `covers/xxx.jpg` / 完整 URL 这样的网络资源；
  ///  2. 用户在查看器里「设为封面」后缓存在本地的截图（优先级更高，
  ///     因为它反映的是用户自己调好的角度）；
  ///  3. 两者都没有时，[CoverImage] 会按 [id] 生成一张确定性的程序化封面。
  final String? coverImage;

  /// 进入查看器时是否默认自动旋转
  final bool autoRotate;

  /// 检索标签（参与搜索匹配）
  final List<String> tags;

  const Model3D({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.modelPath,
    this.coverImage,
    this.autoRotate = true,
    this.tags = const [],
  });

  bool get hasCoverImage => coverImage != null && coverImage!.trim().isNotEmpty;

  /// 搜索用的小写索引串
  String get searchIndex => [
        name,
        description,
        category.displayName,
        ...tags,
      ].join(' ').toLowerCase();

  /// 模型文件名（用于展示）
  String get fileName {
    final segments = modelPath.split('/');
    return segments.isEmpty ? modelPath : segments.last;
  }

  Model3D copyWith({
    String? name,
    ModelCategory? category,
    String? description,
    String? modelPath,
    String? coverImage,
    bool? autoRotate,
    List<String>? tags,
  }) {
    return Model3D(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      modelPath: modelPath ?? this.modelPath,
      coverImage: coverImage ?? this.coverImage,
      autoRotate: autoRotate ?? this.autoRotate,
      tags: tags ?? this.tags,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Model3D && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

/// 模型分类
///
/// [key] 用于查主题色（见 `AppColors.categorySeeds`）与本地存储，
/// 所以重命名枚举值时请一并更新色板。
enum ModelCategory {
  architecture('architecture', '建筑'),
  animal('animal', '动物'),
  cartoon('cartoon', '卡通'),
  vehicle('vehicle', '载具');

  final String key;
  final String displayName;

  const ModelCategory(this.key, this.displayName);

  static ModelCategory? fromKey(String key) {
    for (final c in ModelCategory.values) {
      if (c.key == key) return c;
    }
    return null;
  }
}
