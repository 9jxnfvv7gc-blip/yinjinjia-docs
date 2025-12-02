import 'dart:io';
import 'services/auth_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// 应用配置文件
/// 
/// 这个文件包含所有云端服务的配置
/// 在生产环境，这些值应该从环境变量或配置文件读取

class AppConfig {
  // ========== 云端API服务器配置 ==========
  
  /// 生产环境API服务器地址（香港服务器）- 用于iOS和海外市场
  static const String productionApiUrl = 'http://47.243.177.166:8081';
  
  /// 北京服务器地址（用于Android和国内市场）- 视频服务器
  static const String beijingApiUrl = 'http://39.107.137.136:8081';
  
  /// 北京链接服务器地址（用于Android国内版 - 只提供链接列表）
  static const String beijingLinkApiUrl = 'http://39.107.137.136:8082';
  
  /// 开发环境API服务器地址（本地开发）
  static const String developmentApiUrl = 'http://localhost:8081';
  
  /// 缓存的包名（用于判断版本）
  static String? _cachedPackageName;
  
  /// 设置包名（在应用启动时调用）
  static Future<void> initializePackageName() async {
    if (Platform.isAndroid && _cachedPackageName == null) {
      try {
        final packageInfo = await PackageInfo.fromPlatform();
        _cachedPackageName = packageInfo.packageName;
      } catch (e) {
        // 如果获取失败，忽略错误
        _cachedPackageName = null;
      }
    }
  }
  
  /// 当前使用的API服务器地址
  /// 根据平台和包名自动选择：
  /// - Android Google Play版本（包名包含googleplay）：使用香港服务器
  /// - Android 国内版本（包名包含domestic）：使用北京服务器
  /// - iOS: 使用香港服务器（App Store上架）
  /// - 其他平台: 使用香港服务器
  static String get apiBaseUrl {
    // 根据平台选择服务器
    if (Platform.isAndroid) {
      // 检查包名，判断是Google Play版本还是国内版本
      if (_cachedPackageName != null) {
        if (_cachedPackageName!.contains('googleplay')) {
          // Google Play版本：使用香港服务器
          return productionApiUrl;  // http://47.243.177.166:8081
        } else if (_cachedPackageName!.contains('domestic')) {
          // 国内版本：使用北京服务器
          return beijingApiUrl;  // http://39.107.137.136:8081
        }
      }
      // 如果无法判断包名，默认使用北京服务器（兼容旧版本）
      return beijingApiUrl;  // http://39.107.137.136:8081
    } else if (Platform.isIOS) {
      // iOS应用使用香港服务器（用于App Store上架）
      return productionApiUrl;  // http://47.243.177.166:8081
    } else {
      // 其他平台（macOS、Web等）使用香港服务器
      return productionApiUrl;  // http://47.243.177.166:8081
    }
    
    // 临时使用本地服务器（用于快速测试）
    // 确保 Mac 和 iOS 设备在同一 WiFi，Mac IP: 192.168.10.103
    // return 'http://192.168.10.103:8081';
  }
  
  // ========== 阿里云OSS配置 ==========
  
  /// OSS Endpoint
  /// TODO: 替换为你的实际OSS Endpoint
  static const String ossEndpoint = 'oss-cn-hangzhou.aliyuncs.com';
  
  /// OSS Bucket名称
  /// TODO: 替换为你的实际Bucket名称
  static const String ossBucketName = 'your-bucket-name';
  
  /// OSS访问域名（如果配置了CDN，使用CDN域名）
  /// TODO: 替换为你的实际访问域名
  static const String ossCdnUrl = 'https://your-cdn-domain.com';
  
  // ========== API接口路径 ==========
  
  /// 获取分类列表
  static String get categoriesUrl => '$apiBaseUrl/api/categories';
  
  /// 获取视频列表
  static String listVideosUrl(String categoryPath) => 
      '$apiBaseUrl/api/list/${Uri.encodeComponent(categoryPath)}';
  
  /// 上传视频
  static String get uploadVideoUrl => '$apiBaseUrl/api/upload';
  
  /// 删除视频
  static String get deleteVideoUrl => '$apiBaseUrl/api/delete';
  
  /// 重命名视频
  static String get renameVideoUrl => '$apiBaseUrl/api/rename';
  
  /// 移动视频
  static String get moveVideoUrl => '$apiBaseUrl/api/move';
  
  /// 保存排序
  static String get saveOrderUrl => '$apiBaseUrl/api/save_order';
  
  /// 获取视频信息
  static String videoInfoUrl(String filePath) => 
      '$apiBaseUrl/api/info?file_path=${Uri.encodeComponent(filePath)}';
  
  // ========== 应用配置 ==========
  
  /// 请求超时时间（秒）
  static const int requestTimeoutSeconds = 30;
  
  /// 上传超时时间（秒）
  static const int uploadTimeoutSeconds = 300; // 5分钟
  
  /// 是否自动连接服务器（移动端应设为true）
  static const bool autoConnectServer = true;
  
  /// 是否显示调试信息
  static const bool showDebugInfo = false;
  
  // ========== 用户权限配置 ==========
  
  /// 是否启用管理员模式（只有管理员才能上传内容）
  /// TODO: 后续应该从服务器获取用户角色，或通过登录验证
  static const bool enableAdminMode = true;
  
  /// 当前用户是否为管理员（授权用户）
  /// 从 SharedPreferences 获取授权状态
  /// 注意：这是一个异步方法，需要 await
  static Future<bool> isAdmin() async {
    // 使用 AuthService 检查授权状态
    return await AuthService.isAuthorized();
  }
  
  /// 同步方法：检查缓存中的授权状态（可能不准确）
  /// 注意：这个方法可能返回过期的状态，应该优先使用 isAdmin()
  static bool get isAdminSync {
    // 返回 false 作为安全默认值，强制使用异步方法
    return false;
  }
}

