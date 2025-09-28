/// NexusEvent Flutter SDK
/// 
/// 一个跨平台的消息推送SDK，支持向Discord、Slack等多种平台发送通知消息。
/// 
/// ## 基本用法
/// 
/// ```dart
/// import 'package:nexusevent_flutter/nexusevent.dart';
/// 
/// // 添加Discord发送器
/// NexusEvent.instance.addDiscordSender(
///   'main_discord', 
///   'https://discord.com/api/webhooks/YOUR_WEBHOOK_URL'
/// );
/// 
/// // 发送消息
/// final message = EventMessage(
///   title: '测试消息',
///   content: '这是一条测试消息',
///   url: 'https://example.com',
///   author: '测试用户',
///   platform: Platform.discord,
/// );
/// 
/// await NexusEvent.instance.send('main_discord', message);
/// ```
library nexusevent_flutter;

// 导出核心类型
export 'src/core/types.dart';

// 导出主要的SDK类
export 'src/nexus_event.dart';

// 导出具体的发送器实现
export 'src/senders/discord_sender.dart';

// 为了向后兼容，也导出旧的工具类（但标记为废弃）
// export 'src/utils/discord_utils.dart';
