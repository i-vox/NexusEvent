/// 支持的平台类型
enum Platform {
  discord('discord'),
  slack('slack'),
  telegram('telegram'),
  webhook('webhook'),
  teams('teams');

  const Platform(this.value);
  final String value;
}

/// 事件消息的数据结构
class EventMessage {
  /// 消息标题
  final String title;
  
  /// 消息内容
  final String? content;
  
  /// 相关URL链接
  final String? url;
  
  /// 消息作者
  final String? author;
  
  
  /// 消息颜色（十六进制），如 0x33ccff
  final int? color;
  
  /// 附加的元数据
  final Map<String, dynamic>? metadata;
  
  /// 时间戳
  final DateTime? timestamp;

  EventMessage({
    required String title,
    this.content,
    this.url,
    this.author,
    this.color,
    this.metadata,
    this.timestamp,
  }) : title = _validateTitle(title);
  
  static String _validateTitle(String title) {
    if (title.trim().isEmpty) {
      throw ArgumentError('Message title cannot be empty');
    }
    if (title.length > 2000) {
      throw ArgumentError('Message title too long (max 2000 characters)');
    }
    return title.trim();
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'url': url,
      'author': author,
      'color': color,
      'metadata': metadata,
      'timestamp': timestamp?.toIso8601String(),
    };
  }

  factory EventMessage.fromJson(Map<String, dynamic> json) {
    if (json['title'] == null || json['title'].toString().trim().isEmpty) {
      throw ArgumentError('Message title cannot be null or empty');
    }
    
    return EventMessage(
      title: json['title'].toString(),
      content: json['content']?.toString(),
      url: json['url']?.toString(),
      author: json['author']?.toString(),
      color: json['color'] is int ? json['color'] as int : null,
      metadata: json['metadata'] is Map ? Map<String, dynamic>.from(json['metadata']) : null,
      timestamp: json['timestamp'] != null 
          ? DateTime.tryParse(json['timestamp'].toString())
          : null,
    );
  }
}

/// 事件发送器的抽象接口
abstract class EventSender {
  /// 平台标识
  Platform get platform;
  
  /// 发送事件消息
  Future<void> send(EventMessage message);
  
  /// 验证配置是否有效
  Future<bool> validateConfig();
}

/// 发送器的配置基类
abstract class SenderConfig {
  /// 平台类型
  final Platform platform;
  
  /// 配置参数
  final Map<String, dynamic> config;

  const SenderConfig({
    required this.platform,
    required this.config,
  });
}

/// Discord平台的配置
class DiscordConfig extends SenderConfig {
  DiscordConfig({required String webhookUrl})
      : super(
          platform: Platform.discord,
          config: {'webhookUrl': webhookUrl},
        );

  String get webhookUrl => config['webhookUrl'];
}

/// Slack平台的配置
class SlackConfig extends SenderConfig {
  SlackConfig({
    required String webhookUrl,
    String? channel,
  }) : super(
          platform: Platform.slack,
          config: {
            'webhookUrl': webhookUrl,
            if (channel != null) 'channel': channel,
          },
        );

  String get webhookUrl => config['webhookUrl'];
  String? get channel => config['channel'];
}

/// 通用Webhook的配置
class WebhookConfig extends SenderConfig {
  WebhookConfig({
    required String url,
    Map<String, String>? headers,
    String method = 'POST',
  }) : super(
          platform: Platform.webhook,
          config: {
            'url': url,
            if (headers != null) 'headers': headers,
            'method': method,
          },
        );

  String get url => config['url'];
  Map<String, String>? get headers => config['headers']?.cast<String, String>();
  String get method => config['method'] ?? 'POST';
}

/// 广播发送结果
class BroadcastResult {
  /// 总发送器数量
  final int total;
  
  /// 成功发送的数量
  final int successful;
  
  /// 失败发送的数量
  final int failed;
  
  /// 各发送器的错误信息
  final Map<String, Exception> errors;
  
  const BroadcastResult({
    required this.total,
    required this.successful,
    required this.failed,
    required this.errors,
  });
  
  /// 是否所有发送都成功
  bool get isAllSuccessful => failed == 0;
  
  /// 是否所有发送都失败
  bool get isAllFailed => successful == 0 && total > 0;
  
  /// 成功率
  double get successRate => total > 0 ? successful / total : 0.0;
}
