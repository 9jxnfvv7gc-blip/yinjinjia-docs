/// 应用配置文件
/// 
/// 这个文件包含所有云端服务的配置
/// 在生产环境，这些值应该从环境变量或配置文件读取

class AppConfig {
  // ========== 云端API服务器配置 ==========
  
  /// 生产环境API服务器地址
  /// TODO: 替换为你的实际服务器地址
  static const String productionApiUrl = 'https://your-api-server.com';
  
  /// 开发环境API服务器地址
  /// 可以是本地开发服务器或测试服务器
  static const String developmentApiUrl = 'http://localhost:8081';
  
  /// 当前使用的API服务器地址
  /// 根据构建类型自动选择（开发/生产）
  static String get apiBaseUrl {
    // TODO: 根据Flutter的构建模式自动切换
    // 暂时使用开发环境，后续可以通过环境变量控制
    const bool isProduction = bool.fromEnvironment('PRODUCTION', defaultValue: false);
    return isProduction ? productionApiUrl : developmentApiUrl;
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
  
  /// 当前用户是否为管理员
  /// TODO: 应该从登录状态或服务器获取
  /// 暂时可以通过配置或SharedPreferences设置
  static bool get isAdmin {
    // TODO: 从SharedPreferences或服务器获取用户角色
    // 暂时返回true（开发阶段），生产环境应该从登录状态获取
    return true; // 改为false可以隐藏上传按钮
  }
}

