# 3D Gallery

基于 Flutter Web 与 `<model-viewer>` 的个人 3D 模型画廊。导入模型、旋转缩放查看、保存封面，在浏览器或 Android 手机上管理自己的模型收藏。

**推荐仓库名：`flutter-3d-gallery`**

## 功能

- **交互预览**：旋转、缩放查看 3D 模型。
- **本地导入**：支持自包含 GLB，单个文件上限 100 MB，验证文件头、版本、长度与外部资源依赖。
- **模型管理**：搜索、分类筛选、重命名、修改分类和删除。
- **自定义封面**：首次成功加载导入模型时自动生成封面，也可调整视角后点击“设为封面”。
- **本地模型库**：通过 IndexedDB 保存导入模型、元数据和封面，无需业务后端。
- **深色界面**：响应式网格、毛玻璃面板与键盘交互。
- **Android 封装**：使用 WebView 加载打包后的网页，支持系统文件选择与部分文件管理器的分享导入。

## 平台与技术栈

| 部分 | 实现 |
| --- | --- |
| 页面与状态 | Flutter / Dart、Provider |
| 3D 查看器 | Web DOM 中的 `<model-viewer>` 3.5.0 |
| 模型库 | IndexedDB + JavaScript 桥接 |
| Android 安装包 | `android-apk/` 中的 WebView + WebViewAssetLoader |
| 主题与字体 | `lib/theme/` 自定义主题、内置 Inter 字体 |

主要运行路径是 **浏览器** 和 **Android WebView 封装**。仓库中的其他 Flutter 平台目录不代表对应原生平台的 3D 查看器已适配；Android 包请使用下方专用脚本构建。

## 快速开始

准备 Flutter SDK（其 Dart 版本须满足 `pubspec.yaml` 中的 `^3.5.0`）、Chrome，以及构建预览用的 Python 3。

在项目根目录执行：

```bash
flutter pub get
flutter run -d chrome
```

也可构建静态站点后预览：

```bash
flutter build web --release
python3 -m http.server 9090 --directory build/web
```

浏览器访问 `http://localhost:9090`。网页资源需通过 HTTP 服务加载，不能直接双击 `index.html`。

## 使用方法

1. 点击首页“导入模型”，选择自包含 `.glb` 文件。
2. 打开模型，调整视角；点击“设为封面”保存当前画面。
3. 长按模型卡片或点击“…”重命名、修改分类或删除。
4. 使用搜索框与分类筛选定位收藏。

模型库存储在当前浏览器来源下，不会自动跨设备同步。切换域名或端口会进入不同的存储空间；清理站点数据会移除本地模型库。Android 卸载或清除应用数据也会删除本地模型库。

## 构建 Android APK

准备 Java 17 或以上、Android SDK Platform 35 / Build Tools 35，以及可下载构建依赖的网络。

```bash
# ANDROID_HOME 指向本机 Android SDK
bash scripts/build-apk.sh
adb install -r build/apk/3D-Gallery.apk
```

脚本先构建 Flutter Web，再打包到 Android WebView 应用中，输出 `build/apk/3D-Gallery.apk`。当前输出为 **debug 签名的侧载包**；覆盖安装需要保留相同签名。

完整要求、MIUI / HyperOS 适配与限制见 [Android 构建说明](android-apk/README.md)。

## 添加内置模型

运行时导入无需修改代码。若要随应用一起发布模型，将文件放入 `web/`，并在 `lib/data/model_repository.dart` 的注册列表中添加：

```dart
Model3D(
  id: 'house_01',
  name: '小房子',
  category: ModelCategory.architecture,
  description: '一个温馨的卡通小房子',
  modelPath: 'house.glb',
  coverImage: 'assets/covers/house.jpg', // 可选
  tags: ['小屋', '卡通'],
),
```

静态封面放入 `assets/covers/`。未设置图片时会显示程序化封面。查看器可加载 glTF 资源，但应用内文件导入仅支持自包含 GLB；涉及外部贴图的资源还需正确配置路径与跨域访问。

## 项目结构

```text
lib/
  data/                 模型登记、持久存储与平台适配
  models/               模型数据与分类
  platform/             Web JavaScript 桥接
  providers/            筛选、搜索与模型库状态
  screens/              首页与 3D 查看器
  theme/                颜色、排版、间距和动效
  widgets/              卡片、封面、筛选器等组件
web/                    网页入口、模型库脚本与内置 GLB
assets/                 字体、许可证与静态封面
android-apk/            Android WebView 封装工程
scripts/build-apk.sh     APK 构建入口
test/                   Dart、浏览器与视觉回归测试
```

## 开发与验证

```bash
flutter analyze
flutter test
flutter test --platform chrome
```

数据层测试在 Dart VM 上运行；带有浏览器限制的 UI 测试需通过 Chrome 执行。仅在有意修改视觉基线后更新快照：

```bash
flutter test --platform chrome --update-goldens
```

`test/library_storage.browser.js` 与 `test/model_retry.browser.js` 提供额外的浏览器回归检查，使用方法见 Android 说明。平台视图在 Flutter 测试中不能完整模拟真实 DOM 挂载，模型渲染、截图与手机文件选择仍需在实际运行环境验证。

## 已知限制

- 不包含云同步、模型导出或应用商店发布流程。
- Web 版本加载外部查看器资源，中文回退字体也可能需要网络；不承诺完全离线。
- 跨域模型或贴图缺少允许访问的响应头时，可能无法加载或截图。
- 当前使用 `dart:html` 的 Web 路径，不能直接视为 WebAssembly 或原生平台实现。
- 本地模型库受浏览器配额和设备空间限制，请保留原始模型文件。

## 许可证

项目代码采用 [MIT License](LICENSE)。Inter 字体采用 [SIL Open Font License 1.1](assets/fonts/LICENSE-Inter.txt)。模型资源的使用与再分发权限以其来源授权为准。
