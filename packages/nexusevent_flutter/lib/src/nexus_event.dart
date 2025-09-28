import 'core/types.dart';
import 'senders/discord_sender.dart';

/// NexusEvent SDK的主入口类
class NexusEvent {
  static final NexusEvent _instance = NexusEvent._internal();
  factory NexusEvent() => _instance;
  NexusEvent._internal();

  /// 单例访问器
  static NexusEvent get instance => _instance;

  final Map<String, EventSender> _senders = {};

  /// 添加事件发送器
  /// 
  /// [name] 发送器的唯一标识名称
  /// [sender] 事件发送器实例
  void addSender(String name, EventSender sender) {
    if (name.trim().isEmpty) {
      throw ArgumentError('Sender name cannot be empty');
    }
    _senders[name.trim()] = sender;
  }

  /// 移除事件发送器
  /// 
  /// [name] 发送器的名称
  /// 返回是否成功移除
  bool removeSender(String name) {
    if (name.trim().isEmpty) {
      return false;
    }
    return _senders.remove(name.trim()) != null;
  }

  /// 获取所有已注册的发送器名称
  List<String> get senderNames => _senders.keys.toList();

  /// 发送事件消息到指定的发送器
  /// 
  /// [senderName] 发送器名称
  /// [message] 要发送的消息
  Future<void> send(String senderName, EventMessage message) async {
    if (senderName.trim().isEmpty) {
      throw ArgumentError('Sender name cannot be empty');
    }
    
    final sender = _senders[senderName.trim()];
    if (sender == null) {
      throw ArgumentError('发送器 \"$senderName\" 不存在');
    }

    await sender.send(message);
  }

  /// 发送事件消息到所有已注册的发送器
  /// 
  /// [message] 要发送的消息
  /// [platforms] 可选：仅发送到指定平台，如果为空则发送到所有平台
  /// [failFast] 是否在第一个发送失败时立即停止，默认为false
  Future<BroadcastResult> broadcast(EventMessage message, {List<Platform>? platforms, bool failFast = false}) async {
    if (_senders.isEmpty) {
      return BroadcastResult(total: 0, successful: 0, failed: 0, errors: {});
    }
    
    final futures = <Future<void>>[];
    final senderNames = <String>[];
    
    for (final entry in _senders.entries) {
      if (platforms == null || platforms.contains(entry.value.platform)) {
        futures.add(entry.value.send(message));
        senderNames.add(entry.key);
      }
    }
    
    if (futures.isEmpty) {
      return BroadcastResult(total: 0, successful: 0, failed: 0, errors: {});
    }
    
    final errors = <String, Exception>{};
    int successful = 0;
    
    if (failFast) {
      // 快速失败模式使用 Future.wait
      await Future.wait(futures);
      successful = futures.length;
    } else {
      // 继续模式：记录所有错误但不停止
      final results = await Future.wait(
        futures.asMap().entries.map((entry) async {
          try {
            await entry.value;
            return null; // 成功
          } catch (e) {
            return Exception('发送器 "${senderNames[entry.key]}" 失败: $e');
          }
        }),
        eagerError: false,
      );
      
      for (int i = 0; i < results.length; i++) {
        if (results[i] == null) {
          successful++;
        } else {
          errors[senderNames[i]] = results[i]!;
        }
      }
    }
    
    return BroadcastResult(
      total: futures.length,
      successful: successful,
      failed: futures.length - successful,
      errors: errors,
    );
  }

  /// 验证指定发送器的配置
  /// 
  /// [senderName] 发送器名称
  Future<bool> validateSender(String senderName) async {
    final sender = _senders[senderName];
    if (sender == null) {
      return false;
    }

    return await sender.validateConfig();
  }

  /// 验证所有发送器的配置
  /// 
  /// 返回一个Map，键为发送器名称，值为验证结果
  Future<Map<String, bool>> validateAllSenders() async {
    final results = <String, bool>{};
    
    for (final entry in _senders.entries) {
      results[entry.key] = await entry.value.validateConfig();
    }

    return results;
  }

  /// 便捷方法：快速添加Discord发送器
  /// 
  /// [name] 发送器名称
  /// [webhookUrl] Discord Webhook URL
  void addDiscordSender(String name, String webhookUrl) {
    final config = DiscordConfig(webhookUrl: webhookUrl);
    final sender = DiscordSender(config);
    addSender(name, sender);
  }

  /// 清空所有发送器
  void clear() {
    _senders.clear();
  }
}