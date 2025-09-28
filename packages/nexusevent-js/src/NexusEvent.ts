import { EventSender, EventMessage, Platform, DiscordConfig, BroadcastResult } from './types';
import { DiscordSender } from './senders/DiscordSender';

/**
 * NexusEvent SDK的主入口类
 */
export class NexusEvent {
  private static instance: NexusEvent;
  private senders: Map<string, EventSender> = new Map();

  private constructor() {
    // 私有构造函数，确保单例模式
  }

  /**
   * 获取NexusEvent单例实例
   */
  static getInstance(): NexusEvent {
    if (!NexusEvent.instance) {
      NexusEvent.instance = new NexusEvent();
    }
    return NexusEvent.instance;
  }

  /**
   * 添加事件发送器
   * 
   * @param name 发送器的唯一标识名称
   * @param sender 事件发送器实例
   */
  addSender(name: string, sender: EventSender): void {
    if (!name || name.trim().length === 0) {
      throw new Error('Sender name cannot be empty');
    }
    this.senders.set(name.trim(), sender);
  }

  /**
   * 移除事件发送器
   * 
   * @param name 发送器的名称
   * @returns 是否成功移除
   */
  removeSender(name: string): boolean {
    if (!name || name.trim().length === 0) {
      return false;
    }
    return this.senders.delete(name.trim());
  }

  /**
   * 获取所有已注册的发送器名称
   */
  get senderNames(): string[] {
    return Array.from(this.senders.keys());
  }

  /**
   * 发送事件消息到指定的发送器
   * 
   * @param senderName 发送器名称
   * @param message 要发送的消息
   */
  async send(senderName: string, message: EventMessage): Promise<void> {
    if (!senderName || senderName.trim().length === 0) {
      throw new Error('Sender name cannot be empty');
    }
    
    const sender = this.senders.get(senderName.trim());
    if (!sender) {
      throw new Error(`发送器 "${senderName}" 不存在`);
    }

    await sender.send(message);
  }

  /**
   * 发送事件消息到所有已注册的发送器
   * 
   * @param message 要发送的消息
   * @param platforms 可选：仅发送到指定平台，如果为空则发送到所有平台
   * @param failFast 是否在第一个发送失败时立即停止，默认为false
   */
  async broadcast(message: EventMessage, platforms?: Platform[], failFast: boolean = false): Promise<BroadcastResult> {
    if (this.senders.size === 0) {
      return { total: 0, successful: 0, failed: 0, errors: {} };
    }
    
    const promises: Promise<void>[] = [];
    const senderNames: string[] = [];
    
    for (const [name, sender] of this.senders.entries()) {
      if (!platforms || platforms.includes(sender.platform)) {
        promises.push(sender.send(message));
        senderNames.push(name);
      }
    }
    
    if (promises.length === 0) {
      return { total: 0, successful: 0, failed: 0, errors: {} };
    }
    
    const errors: Record<string, Error> = {};
    let successful = 0;
    
    if (failFast) {
      // 快速失败模式使用 Promise.all
      await Promise.all(promises);
      successful = promises.length;
    } else {
      // 继续模式：记录所有错误但不停止
      const results = await Promise.allSettled(promises);
      
      for (let i = 0; i < results.length; i++) {
        if (results[i].status === 'fulfilled') {
          successful++;
        } else {
          const rejectedResult = results[i] as PromiseRejectedResult;
          errors[senderNames[i]] = new Error(`发送器 "${senderNames[i]}" 失败: ${rejectedResult.reason}`);
        }
      }
    }
    
    return {
      total: promises.length,
      successful,
      failed: promises.length - successful,
      errors,
    };
  }

  /**
   * 验证指定发送器的配置
   * 
   * @param senderName 发送器名称
   */
  async validateSender(senderName: string): Promise<boolean> {
    const sender = this.senders.get(senderName);
    if (!sender) {
      return false;
    }

    return await sender.validateConfig();
  }

  /**
   * 验证所有发送器的配置
   * 
   * @returns 一个Map，键为发送器名称，值为验证结果
   */
  async validateAllSenders(): Promise<Record<string, boolean>> {
    const results: Record<string, boolean> = {};
    
    for (const [name, sender] of this.senders.entries()) {
      results[name] = await sender.validateConfig();
    }

    return results;
  }

  /**
   * 便捷方法：快速添加Discord发送器
   * 
   * @param name 发送器名称
   * @param webhookUrl Discord Webhook URL
   */
  addDiscordSender(name: string, webhookUrl: string): void {
    const config: DiscordConfig = {
      platform: Platform.DISCORD,
      config: { webhookUrl },
    };
    const sender = new DiscordSender(config);
    this.addSender(name, sender);
  }

  /**
   * 清空所有发送器
   */
  clear(): void {
    this.senders.clear();
  }
}