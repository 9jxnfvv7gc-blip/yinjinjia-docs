import 'package:flutter/material.dart';
import 'simple_home_page_safe.dart';

/// 简化版主页面（使用安全版本）
class SimpleHomePage extends StatelessWidget {
  const SimpleHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 直接使用安全版本
    return const SimpleHomePageSafe();
  }
}

