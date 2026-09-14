import '../models/model3d.dart';

/// 模型仓库 —— 管理所有 3D 模型
///
/// 使用方式：
///  1. 把 `.glb` 文件放到 `web/` 目录（站点根目录），
///     例如 `web/house.glb`；
///  2. 在下面的 [registerModels] 里登记一条 [Model3D]；
///  3. 封面图有四种给法（见 README「模型封面图」），
///     什么都不给的话会自动生成一张程序化封面。
abstract final class ModelRepository {
  static final List<Model3D> _models = [];

  /// 注册所有模型
  static void registerModels() {
    _models
      ..clear()
      ..addAll(const [
        Model3D(
          id: 'model_01',
          name: '未命名模型',
          category: ModelCategory.architecture,
          description: '用户添加的 3D 模型，可在查看器里自由旋转、缩放并一键设为封面。',
          modelPath: 'fb6dd1f3-1d3b-4a46-b80a-a5d67902fc96.glb',
          tags: ['glb', '示例'],
        ),

        // ── 新增模型请照抄下面的模板 ──────────────────────────────────────
        //
        // Model3D(
        //   id: 'house_01',
        //   name: '小房子',
        //   category: ModelCategory.architecture,
        //   description: '一个温馨的卡通小房子',
        //   modelPath: 'house.glb',
        //   // 封面图（可选）——三种写法：
        //   coverImage: 'assets/covers/house.jpg', // 1. Flutter asset
        //   // coverImage: 'covers/house.jpg',     // 2. web/covers/ 下的静态文件
        //   // coverImage: 'https://…/house.jpg',  // 3. 远程图片
        //   tags: ['小屋', '卡通'],
        // ),
      ]);
  }

  static List<Model3D> getAll() => List.unmodifiable(_models);

  static List<Model3D> getByCategory(ModelCategory category) =>
      _models.where((m) => m.category == category).toList();

  /// 获取所有分类（仅包含有模型的分类）
  static List<ModelCategory> getActiveCategories() {
    return ModelCategory.values
        .where((c) => _models.any((m) => m.category == c))
        .toList();
  }

  /// 每个分类下的模型数量
  static Map<ModelCategory, int> getCategoryCounts() {
    return {
      for (final c in ModelCategory.values)
        c: _models.where((m) => m.category == c).length,
    };
  }

  static Model3D? getById(String id) {
    for (final m in _models) {
      if (m.id == id) return m;
    }
    return null;
  }
}
