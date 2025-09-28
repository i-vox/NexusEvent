import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/types.dart';

/// Discord平台的事件发送器
class DiscordSender implements EventSender {
  final DiscordConfig _config;
  final Dio _dio;

  DiscordSender(this._config) : _dio = Dio() {
    // 网络配置
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
    _dio.options.sendTimeout = const Duration(seconds: 15);
    
    // 设置User-Agent
    _dio.options.headers['User-Agent'] = 'NexusEvent-Flutter/0.1.1';
    
    // 添加拦截器用于统一错误处理
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        debugPrint('Discord API Error: ${error.message}');
        handler.next(error);
      },
    ));
  }

  @override
  Platform get platform => Platform.discord;

  @override
  Future<void> send(EventMessage message) async {
    // 输入验证
    if (message.title.trim().isEmpty) {
      throw ArgumentError('Message title cannot be empty');
    }
    
    // URL格式验证
    if (!_isValidDiscordWebhookUrl(_config.webhookUrl)) {
      throw ArgumentError('Invalid Discord webhook URL format');
    }
    
    // 检查webhook配置
    if (_config.webhookUrl.contains('YOUR_WEBHOOK_URL') || _config.webhookUrl.contains('WEBHOOK_URL')) {
      throw StateError('Discord Webhook URL has not been configured');
    }
    
    // 在调试模式下输出日志但不发送
    if (kDebugMode) {
      debugPrint('[DEBUG] Would send message to Discord: ${message.title}');
      return;
    }

    final payload = _buildPayload(message);
    await _sendWithRetry(payload, message.title);
  }

  /// 带有重试机制的发送方法
  Future<void> _sendWithRetry(Map<String, dynamic> payload, String title, {int maxRetries = 3}) async {
    int attempts = 0;
    Duration backoffDelay = const Duration(seconds: 1);
    
    while (attempts <= maxRetries) {
      try {
        attempts++;
        await _dio.post(_config.webhookUrl, data: payload);
        debugPrint('成功发送消息到 Discord: $title');
        return; // 成功后直接返回
      } on DioException catch (e) {
        final isRetriable = _isRetriableError(e);
        final isLastAttempt = attempts > maxRetries;
        
        debugPrint('发送到 Discord 失败 (尝试 $attempts/${maxRetries + 1}): ${e.message}');
        
        if (isLastAttempt || !isRetriable) {
          // 最后一次尝试或不可重试的错误
          throw _createMeaningfulException(e, title);
        }
        
        // 等待后重试，使用指数退避
        debugPrint('将在 ${backoffDelay.inSeconds} 秒后重试...');
        await Future.delayed(backoffDelay);
        backoffDelay = Duration(seconds: (backoffDelay.inSeconds * 2).clamp(1, 30));
      } catch (e) {
        // 非-DioException错误不重试
        debugPrint('发送到 Discord 失败: $e');
        rethrow;
      }
    }
  }

  @override
  Future<bool> validateConfig() async {
    try {
      return _isValidDiscordWebhookUrl(_config.webhookUrl);
    } catch (e) {
      return false;
    }
  }

  /// 构建Discord webhook的payload
  Map<String, dynamic> _buildPayload(EventMessage message) {
    final payload = <String, dynamic>{};

    // 如果有URL，将其作为内容的一部分发送，这样Discord会自动生成预览
    if (message.url != null && message.url!.isNotEmpty) {
      payload['content'] = '「${message.title}」 ${message.url}';
    } else {
      payload['content'] = message.title;
    }

    // 可以选择性地添加embeds来丰富显示效果
    if (message.content != null || message.author != null) {
      payload['embeds'] = [
        {
          'title': message.title,
          if (message.content != null) 'description': message.content,
          if (message.url != null) 'url': message.url,
          'color': message.color ?? 0x33ccff, // 默认浅蓝色
          if (message.author != null)
            'fields': [
              {
                'name': 'UP主',
                'value': message.author,
                'inline': true,
              }
            ],
          'footer': {
            'text': 'NexusEvent 通知',
          },
          if (message.timestamp != null)
            'timestamp': message.timestamp!.toIso8601String(),
        }
      ];
    }

    return payload;
  }
  
  /// 验证Discord Webhook URL的安全性和格式
  bool _isValidDiscordWebhookUrl(String url) {
    if (url.contains('YOUR_WEBHOOK_URL') || url.contains('WEBHOOK_URL')) {
      return false; // 占位符URL
    }
    
    try {
      final uri = Uri.parse(url);
      
      // 基本格式检查
      if (uri.scheme != 'https' || 
          uri.host != 'discord.com' || 
          !uri.path.startsWith('/api/webhooks/')) {
        return false;
      }
      
      // 检查路径段结构：/api/webhooks/{webhook_id}/{token}
      if (uri.pathSegments.length != 4) {
        return false;
      }
      
      // 检查webhook ID和token是否是有效格式
      final webhookId = uri.pathSegments[2];
      final token = uri.pathSegments[3];
      
      // webhook ID和token不能为空，且不能是明显的无效值
      if (webhookId.isEmpty || token.isEmpty || 
          webhookId == 'invalid' || token == 'invalid' ||
          webhookId == 'url' || token == 'url') {
        return false;
      }
      
      // webhook ID应该是数字（Discord webhook ID是数字ID）
      if (!RegExp(r'^\d+$').hasMatch(webhookId)) {
        return false;
      }
      
      // token应该是合理的字符串（字母数字、连字符、下划线）
      if (!RegExp(r'^[A-Za-z0-9\-_]+$').hasMatch(token)) {
        return false;
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// 判断错误是否可以重试
  bool _isRetriableError(DioException e) {
    // 网络错误和超时错误可以重试
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return true;
    }
    
    // HTTP状态码检查
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      // 5xx 服务器错误和 429 频率限制可以重试
      if (statusCode != null && (statusCode >= 500 || statusCode == 429)) {
        return true;
      }
    }
    
    return false;
  }
  
  /// 创建有意义的异常信息
  Exception _createMeaningfulException(DioException e, String title) {
    final statusCode = e.response?.statusCode;
    final responseData = e.response?.data;
    
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return Exception('连接Discord超时，请检查网络连接');
      case DioExceptionType.sendTimeout:
        return Exception('发送数据超时，请稍后重试');
      case DioExceptionType.receiveTimeout:
        return Exception('接收Discord响应超时');
      case DioExceptionType.badResponse:
        if (statusCode == 400) {
          return Exception('Discord Webhook请求格式错误：${responseData ?? "无法发送消息"}')
;
        } else if (statusCode == 401) {
          return Exception('Discord Webhook身份验证失败，请检查Webhook URL');
        } else if (statusCode == 404) {
          return Exception('Discord Webhook不存在，请检查URL是否正确');
        } else if (statusCode == 429) {
          return Exception('Discord API请求频率过高，请稍后重试');
        } else if (statusCode != null && statusCode >= 500) {
          return Exception('Discord服务器错误 (HTTP $statusCode)，请稍后重试');
        }
        return Exception('Discord API错误 (HTTP ${statusCode ?? "Unknown"}): ${responseData ?? e.message}');
      case DioExceptionType.connectionError:
        return Exception('无法连接到Discord，请检查网络连接');
      default:
        return Exception('发送消息“$title”到Discord失败: ${e.message}');
    }
  }
  
  /// 释放资源
  void dispose() {
    _dio.close();
  }
}

/// 向后兼容的工具类，保留原有的API
@Deprecated('使用 DiscordSender 和新的 EventMessage 架构代替')
class DiscordUtils {
  static const String _webhookUrl =
      'https://discord.com/api/webhooks/YOUR_WEBHOOK_URL';

  /// 发送点赞视频的URL到指定的Discord频道
  ///
  /// [videoTitle] - 视频的标题
  /// [videoUrl] - 视频的完整URL
  /// [author] - 视频作者
  static Future<void> sendLikeNotification({
    required String videoTitle,
    required String videoUrl,
    required String author,
  }) async {
    final config = DiscordConfig(webhookUrl: _webhookUrl);
    final sender = DiscordSender(config);
    
    final message = EventMessage(
      title: videoTitle,
      url: videoUrl,
      author: author,
      color: 0x33ccff,
    );

    await sender.send(message);
  }
}