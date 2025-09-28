/**
 * NexusEvent JavaScript SDK
 * 
 * 一个跨平台的消息推送SDK，支持向Discord、Slack等多种平台发送通知消息。
 * 
 * @example
 * ```typescript
 * import { NexusEvent, EventMessage, Platform } from '@nexusevent/nexusevent-js';
 * 
 * // 添加Discord发送器
 * const nexus = NexusEvent.getInstance();
 * nexus.addDiscordSender('main_discord', 'https://discord.com/api/webhooks/YOUR_WEBHOOK_URL');
 * 
 * // 发送消息
 * const message: EventMessage = {
 *   title: '新视频点赞',
 *   content: '《JavaScript开发指南》',
 *   url: 'https://example.com/video/123',
 *   author: 'UP主名称',
 *   platform: Platform.DISCORD,
 *   timestamp: new Date(),
 * };
 * 
 * await nexus.send('main_discord', message);
 * ```
 */

// 导出核心类型
export * from './types';

// 导出主要的SDK类
export { NexusEvent } from './NexusEvent';

// 导出具体的发送器实现
export { DiscordSender } from './senders/DiscordSender';

// 便捷的单例访问
import { NexusEvent } from './NexusEvent';
export const nexusEvent = NexusEvent.getInstance();
