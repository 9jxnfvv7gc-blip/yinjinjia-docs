import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'legal_content.dart';

/// 协议查看页面（应用内显示）
class LegalViewPage extends StatelessWidget {
  final String title;
  final String content;

  const LegalViewPage({
    super.key,
    required this.title,
    required this.content,
  });

  /// 显示用户协议页面
  static void showTerms(BuildContext context) {
    try {
      // 确保 context 有效
      if (!context.mounted) {
        if (kDebugMode) {
          print('⚠️ Context 已失效，无法打开用户协议');
        }
        return;
      }
      
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            try {
              return const LegalViewPage(
                title: '用户协议',
                content: LegalContent.termsContent,
              );
            } catch (e, stackTrace) {
              if (kDebugMode) {
                print('❌ 构建用户协议页面失败: $e');
                print('📋 堆栈: $stackTrace');
              }
              // 返回错误页面
              return Scaffold(
                appBar: AppBar(title: const Text('用户协议')),
                body: const Center(
                  child: Text('加载失败，请重试'),
                ),
              );
            }
          },
        ),
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ 打开用户协议页面失败: $e');
        print('📋 堆栈: $stackTrace');
      }
    }
  }

  /// 显示隐私政策页面
  static void showPrivacy(BuildContext context) {
    try {
      // 确保 context 有效
      if (!context.mounted) {
        if (kDebugMode) {
          print('⚠️ Context 已失效，无法打开隐私政策');
        }
        return;
      }
      
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            try {
              return const LegalViewPage(
                title: '隐私政策',
                content: LegalContent.privacyContent,
              );
            } catch (e, stackTrace) {
              if (kDebugMode) {
                print('❌ 构建隐私政策页面失败: $e');
                print('📋 堆栈: $stackTrace');
              }
              // 返回错误页面
              return Scaffold(
                appBar: AppBar(title: const Text('隐私政策')),
                body: const Center(
                  child: Text('加载失败，请重试'),
                ),
              );
            }
          },
        ),
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ 打开隐私政策页面失败: $e');
        print('📋 堆栈: $stackTrace');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('📄 LegalViewPage.build: title=$title, content.length=${content.length}');
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blue.shade700,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (kDebugMode) {
              print('🔙 点击返回按钮');
            }
            Navigator.of(context).pop();
          },
          tooltip: '返回',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    try {
      // 将 Markdown 格式的内容转换为 Widget
      final lines = content.split('\n');
      final widgets = <Widget>[];

      for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 12));
        continue;
      }

      if (line.startsWith('# ')) {
        // 一级标题
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 16),
            child: Text(
              line.substring(2),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
            ),
          ),
        );
      } else if (line.startsWith('## ')) {
        // 二级标题
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 12),
            child: Text(
              line.substring(3),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
            ),
          ),
        );
      } else if (line.startsWith('### ')) {
        // 三级标题
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              line.substring(4),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
            ),
          ),
        );
      } else if (line.startsWith('- ') || line.startsWith('  - ')) {
        // 列表项
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 16)),
                Expanded(
                  child: Text(
                    line.replaceFirst(RegExp(r'^[\s-]+'), ''),
                    style: const TextStyle(fontSize: 15, height: 1.6),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (line.startsWith(RegExp(r'^\d+\.'))) {
        // 有序列表
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${line.split('.')[0]}. ',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Text(
                    line.substring(line.indexOf('.') + 1).trim(),
                    style: const TextStyle(fontSize: 15, height: 1.6),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (line.startsWith('**') && line.endsWith('**')) {
        // 粗体文本
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Text(
              line.replaceAll('**', ''),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                height: 1.6,
              ),
            ),
          ),
        );
      } else if (line == '---') {
        // 分隔线
        widgets.add(
          const Divider(height: 32),
        );
      } else {
        // 普通文本（处理粗体标记）
        String displayText = line;
        
        // 检查是否包含粗体标记
        if (line.contains('**')) {
          // 处理 **粗体** 标记
          List<TextSpan> spans = [];
          final boldPattern = RegExp(r'\*\*(.*?)\*\*');
          int lastEnd = 0;
          
          for (final match in boldPattern.allMatches(line)) {
            // 添加粗体前的普通文本
            if (match.start > lastEnd) {
              spans.add(TextSpan(
                text: line.substring(lastEnd, match.start),
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ));
            }
            // 添加粗体文本
            spans.add(TextSpan(
              text: match.group(1),
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ));
            lastEnd = match.end;
          }
          // 添加剩余的普通文本
          if (lastEnd < line.length) {
            spans.add(TextSpan(
              text: line.substring(lastEnd),
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Colors.black87,
              ),
            ));
          }
          
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: Colors.black87,
                    fontFamily: null, // 使用系统默认字体
                  ),
                  children: spans,
                ),
              ),
            ),
          );
        } else {
          // 没有粗体标记，直接显示
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              child: Text(
                displayText,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
            ),
          );
        }
      }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      );
    } catch (e) {
      // 如果解析失败，显示原始文本
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            content,
            style: const TextStyle(fontSize: 15, height: 1.6),
          ),
        ),
      );
    }
  }
}

