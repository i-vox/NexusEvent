# NexusEvent Flutter SDK

一个用于Flutter的跨平台消息推送SDK，支持向Discord、Slack、Telegram等多种平台发送通知消息。

## 🚀 快速开始

### 安装

在你的`pubspec.yaml`中添加依赖：

```yaml
dependencies:
  nexusevent_flutter: ^0.1.0
```

然后运行：

```bash
flutter pub get
```

### 基本使用

```dart
import 'package:nexusevent_flutter/nexusevent.dart';

// 添加Discord发送器
NexusEvent.instance.addDiscordSender(
  'main_discord', 
  'https://discord.com/api/webhooks/YOUR_WEBHOOK_URL'
);

// 发送消息
final message = EventMessage(
  title: '新视频点赞',
  content: '《Flutter开发指南》',
  url: 'https://example.com/video/123',
  author: 'UP主名称',
  platform: Platform.discord,
);

await NexusEvent.instance.send('main_discord', message);
```

## 📚 详细用法

### 配置发送器

#### Discord发送器

```dart
// 方法1：使用便捷方法
NexusEvent.instance.addDiscordSender('discord_main', webhookUrl);

// 方法2：手动创建
final config = DiscordConfig(webhookUrl: webhookUrl);
final sender = DiscordSender(config);
NexusEvent.instance.addSender('discord_main', sender);
```

### 发送消息

#### 基本消息

```dart
final message = EventMessage(
  title: '简单通知',
  platform: Platform.discord,
);

await NexusEvent.instance.send('discord_main', message);
```

#### 富文本消息

```dart
final message = EventMessage(
  title: '详细通知',
  content: '这里是详细内容',
  url: 'https://example.com',
  author: '消息作者',
  platform: Platform.discord,
  color: 0x00ff00, // 绿色
  timestamp: DateTime.now(),
);

await NexusEvent.instance.send('discord_main', message);
```

### 广播消息

```dart
// 发送到所有已注册的发送器
await NexusEvent.instance.broadcast(message);

// 只发送到Discord平台
await NexusEvent.instance.broadcast(message, platforms: [Platform.discord]);
```

### 验证配置

```dart
// 验证单个发送器
final isValid = await NexusEvent.instance.validateSender('discord_main');
if (!isValid) {
  print('Discord配置无效');
}

// 验证所有发送器
final results = await NexusEvent.instance.validateAllSenders();
results.forEach((name, isValid) {
  print('$name: ${isValid ? '有效' : '无效'}');
});
```

## 🛠️ API参考

### EventMessage

消息对象的数据结构：

```dart
class EventMessage {
  final String title;           // 必需：消息标题
  final String? content;        // 可选：详细内容
  final String? url;           // 可选：相关链接
  final String? author;        // 可选：消息作者
  final Platform platform;     // 必需：目标平台
  final int? color;           // 可选：消息颜色（十六进制）
  final Map<String, dynamic>? metadata; // 可选：附加数据
  final DateTime? timestamp;   // 可选：时间戳
}
```

### Platform

支持的平台类型：

```dart
enum Platform {
  discord,    // Discord
  slack,      // Slack (计划中)
  telegram,   // Telegram (计划中)
  webhook,    // 自定义Webhook (计划中)
  teams       // Microsoft Teams (计划中)
}
```

### NexusEvent

SDK主入口类的主要方法：

```dart
class NexusEvent {
  // 单例访问
  static NexusEvent get instance;
  
  // 添加发送器
  void addSender(String name, EventSender sender);
  void addDiscordSender(String name, String webhookUrl);
  
  // 移除发送器
  void removeSender(String name);
  
  // 发送消息
  Future<void> send(String senderName, EventMessage message);
  Future<void> broadcast(EventMessage message, {List<Platform>? platforms});
  
  // 验证配置
  Future<bool> validateSender(String senderName);
  Future<Map<String, bool>> validateAllSenders();
  
  // 获取信息
  List<String> get senderNames;
  
  // 清理
  void clear();
}
```

## 💡 实用示例

### 视频点赞通知

```dart
Future<void> sendLikeNotification({
  required String videoTitle,
  required String videoUrl,
  required String author,
}) async {
  final message = EventMessage(
    title: '新视频获得点赞 👍',
    content: '「$videoTitle」',
    url: videoUrl,
    author: author,
    platform: Platform.discord,
    color: 0x33ccff,
    timestamp: DateTime.now(),
  );

  await NexusEvent.instance.send('discord_main', message);
}
```

### 错误处理

```dart
try {
  await NexusEvent.instance.send('discord_main', message);
  print('消息发送成功');
} catch (e) {
  print('发送失败: $e');
  // 处理错误，例如重试或使用备用发送器
}
```

### 条件发送

```dart
Future<void> sendNotificationSafely(EventMessage message) async {
  // 检查是否在生产环境
  if (kReleaseMode) {
    // 验证配置后再发送
    final isValid = await NexusEvent.instance.validateSender('discord_main');
    if (isValid) {
      await NexusEvent.instance.send('discord_main', message);
    } else {
      print('配置无效，跳过发送');
    }
  } else {
    print('开发环境，跳过发送: ${message.title}');
  }
}
```

## 🔧 高级配置

### 自定义发送器

如果需要支持其他平台，可以实现`EventSender`接口：

```dart
class CustomSender implements EventSender {
  @override
  Platform get platform => Platform.webhook;

  @override
  Future<void> send(EventMessage message) async {
    // 实现自定义发送逻辑
  }

  @override
  Future<bool> validateConfig() async {
    // 实现配置验证
    return true;
  }
}

// 使用自定义发送器
final customSender = CustomSender();
NexusEvent.instance.addSender('custom', customSender);
```

## 🐛 故障排除

### 常见问题

1. **"Discord Webhook URL尚未配置"**
   - 确保你的Webhook URL是有效的Discord URL
   - 检查URL格式：`https://discord.com/api/webhooks/...`

2. **"发送器不存在"**
   - 确保在发送消息前已添加发送器
   - 检查发送器名称是否正确

3. **网络请求失败**
   - 检查网络连接
   - 验证Webhook URL是否仍然有效
   - 确保Discord服务器可访问

### 调试模式

在开发时，SDK会在调试模式下跳过实际发送，只打印日志：

```dart
import 'package:flutter/foundation.dart';

if (kDebugMode) {
  print('当前在调试模式，消息不会实际发送');
}
```

## 📄 许可证

Apache License 2.0 - 详见 [LICENSE](../../LICENSE) 文件。
