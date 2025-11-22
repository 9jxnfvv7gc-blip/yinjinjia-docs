import 'package:flutter/material.dart';

// 条件导入：Web平台使用stub，其他平台使用完整版本
import 'video_page.dart' if (dart.library.html) 'video_page_stub.dart';
import 'music_page.dart' if (dart.library.html) 'music_page_stub.dart';
import 'simple_home_page.dart'; // 简化版界面

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '我的原创内容',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // 使用简化版界面（视频和音乐统一在一个页面）
      home: const SimpleHomePage(),
      // 如果需要使用原来的分类界面，可以改为：
      // home: const HomePage(),
    );
  }
}

// 保留原来的分类界面代码（备用）
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade700,
                Colors.purple.shade700,
                Colors.pink.shade700,
              ],
            ),
          ),
        ),
        title: const Row(
          children: [
            Icon(Icons.play_circle_filled, color: Colors.white, size: 28),
            SizedBox(width: 8),
            Text(
              '影音播放器',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.video_library),
              text: '视频',
            ),
            Tab(
              icon: Icon(Icons.music_note),
              text: '音乐',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          VideoPage(),
          MusicPage(),
        ],
      ),
    );
  }
}
