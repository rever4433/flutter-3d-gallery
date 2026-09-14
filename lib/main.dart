import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/gallery_provider.dart';
import 'platform/mobile_bridge.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

final galleryNavigator = GlobalKey<NavigatorState>();

void main() {
  MobileBridge.registerBack(() {
    final nav = galleryNavigator.currentState;
    if (nav == null || !nav.canPop()) return false;
    nav.pop();
    return true;
  });
  runApp(const Gallery3DApp());
}

class Gallery3DApp extends StatelessWidget {
  const Gallery3DApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GalleryProvider(),
      child: MaterialApp(
        title: '3D Gallery',
        navigatorKey: galleryNavigator,
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        scrollBehavior: const _AppScrollBehavior(),
        home: const HomeScreen(),
      ),
    );
  }
}

/// 滚动行为。
///
/// 去掉 M3 的 overscroll 发光/拉伸效果（那是很强的 Material 信号），
/// 并允许鼠标拖拽滚动 —— 在桌面浏览器上横向拖动分类栏更顺手。
class _AppScrollBehavior extends MaterialScrollBehavior {
  const _AppScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

  @override
  Set<PointerDeviceKind> get dragDevices => const {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}
