import axios, { AxiosInstance } from 'axios';
import { EventSender, EventMessage, Platform, DiscordConfig } from '../types';

/**
 * Discord平台的事件发送器
 */
export class DiscordSender implements EventSender {
  public readonly platform = Platform.DISCORD;
  private readonly config: DiscordConfig;
  private readonly httpClient: AxiosInstance;

  constructor(config: DiscordConfig) {
    this.config = config;
    
    this.httpClient = axios.create({
      timeout: 15000,
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'NexusEvent-JS/0.1.1',
      },
      // 设置重试拦截器
      validateStatus: (status) => status < 600, // 除了600+都认为是成功的
    });
  }

  async send(message: EventMessage): Promise<void> {
    // 输入验证
    if (!message.title || message.title.trim().length === 0) {
      throw new Error('Message title cannot be empty');
    }
    
    // URL格式验证
    if (!this.isValidDiscordWebhookUrl(this.config.config.webhookUrl)) {
      throw new Error('Invalid Discord webhook URL format');
    }
    
    // 检查webhook配置
    if (this.config.config.webhookUrl.includes('YOUR_WEBHOOK_URL')) {
      throw new Error('Discord Webhook URL has not been configured');
    }

    const payload = this.buildPayload(message);
    await this.sendWithRetry(payload, message.title);
  }

  /**
   * 带有重试机制的发送方法
   */
  private async sendWithRetry(payload: Record<string, any>, title: string, maxRetries: number = 3): Promise<void> {
    let attempts = 0;
    let backoffDelay = 1000; // 1秒
    
    while (attempts <= maxRetries) {
      try {
        attempts++;
        const response = await this.httpClient.post(this.config.config.webhookUrl, payload);
        
        // 检查HTTP状态码
        if (response.status >= 400) {
          throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }
        
        console.log(`成功发送消息到 Discord: ${title}`);
        return; // 成功后直接返回
      } catch (error: any) {
        const isRetriable = this.isRetriableError(error);
        const isLastAttempt = attempts > maxRetries;
        
        console.error(`发送到 Discord 失败 (尝试 ${attempts}/${maxRetries + 1}):`, error.message || error);
        
        if (isLastAttempt || !isRetriable) {
          // 最后一次尝试或不可重试的错误
          throw this.createMeaningfulError(error, title);
        }
        
        // 等待后重试，使用指数退避
        console.log(`将在 ${backoffDelay / 1000} 秒后重试...`);
        await new Promise(resolve => setTimeout(resolve, backoffDelay));
        backoffDelay = Math.min(backoffDelay * 2, 30000); // 最多30秒
      }
    }
  }

  async validateConfig(): Promise<boolean> {
    try {
      return this.isValidDiscordWebhookUrl(this.config.config.webhookUrl);
    } catch {
      return false;
    }
  }

  /**
   * 构建Discord webhook的payload
   */
  private buildPayload(message: EventMessage): Record<string, any> {
    const payload: Record<string, any> = {};

    // 如果有URL，将其作为内容的一部分发送，这样Discord会自动生成预览
    if (message.url) {
      payload.content = `「${message.title}」 ${message.url}`;
    } else {
      payload.content = message.title;
    }

    // 可以选择性地添加embeds来丰富显示效果
    if (message.content || message.author) {
      payload.embeds = [{
        title: message.title,
        ...(message.content && { description: message.content }),
        ...(message.url && { url: message.url }),
        color: message.color || 0x33ccff, // 默认浅蓝色
        ...(message.author && {
          fields: [{
            name: 'UP主',
            value: message.author,
            inline: true,
          }]
        }),
        footer: {
          text: 'NexusEvent 通知',
        },
        ...(message.timestamp && {
          timestamp: message.timestamp.toISOString(),
        }),
      }];
    }

    return payload;
  }
  
  /**
   * 验证Discord Webhook URL的安全性和格式
   */
  private isValidDiscordWebhookUrl(url: string): boolean {
    if (url.includes('YOUR_WEBHOOK_URL') || url.includes('WEBHOOK_URL')) {
      return false; // 占位符URL
    }
    
    try {
      const urlObj = new URL(url);
      
      // 基本格式检查
      if (urlObj.protocol !== 'https:' || 
          urlObj.hostname !== 'discord.com' || 
          !urlObj.pathname.startsWith('/api/webhooks/')) {
        return false;
      }
      
      // 检查路径段结构：/api/webhooks/{webhook_id}/{token}
      const pathSegments = urlObj.pathname.split('/').filter(s => s.length > 0);
      if (pathSegments.length !== 4) {
        return false;
      }
      
      // 检查webhook ID和token是否是有效格式
      const webhookId = pathSegments[2];
      const token = pathSegments[3];
      
      // webhook ID和token不能为空，且不能是明显的无效值
      if (!webhookId || !token || 
          webhookId === 'invalid' || token === 'invalid' ||
          webhookId === 'url' || token === 'url') {
        return false;
      }
      
      // webhook ID应该是数字（Discord webhook ID是数字ID）
      if (!/^\d+$/.test(webhookId)) {
        return false;
      }
      
      // token应该是合理的字符串（字母数字、连字符、下划线）
      if (!/^[A-Za-z0-9\-_]+$/.test(token)) {
        return false;
      }
      
      return true;
    } catch {
      return false;
    }
  }
  
  /**
   * 判断错误是否可以重试
   */
  private isRetriableError(error: any): boolean {
    // Axios网络错误
    if (error.code) {
      const retriableCodes = ['ECONNRESET', 'ENOTFOUND', 'ECONNREFUSED', 'ETIMEDOUT'];
      if (retriableCodes.includes(error.code)) {
        return true;
      }
    }
    
    // HTTP状态码检查
    if (error.response && error.response.status) {
      const status = error.response.status;
      // 5xx 服务器错误和 429 频率限制可以重试
      if (status >= 500 || status === 429) {
        return true;
      }
    }
    
    // 超时错误
    if (error.message && error.message.includes('timeout')) {
      return true;
    }
    
    return false;
  }
  
  /**
   * 创建有意义的错误信息
   */
  private createMeaningfulError(error: any, title: string): Error {
    if (error.response) {
      const status = error.response.status;
      const data = error.response.data;
      
      switch (status) {
        case 400:
          return new Error(`Discord Webhook请求格式错误：${data?.message || '无法发送消息'}`);
        case 401:
          return new Error('Discord Webhook身份验证失败，请检查Webhook URL');
        case 404:
          return new Error('Discord Webhook不存在，请检查URL是否正确');
        case 429:
          return new Error('Discord API请求频率过高，请稍后重试');
        default:
          if (status >= 500) {
            return new Error(`Discord服务器错误 (HTTP ${status})，请稍后重试`);
          }
          return new Error(`Discord API错误 (HTTP ${status}): ${data?.message || error.message}`);
      }
    }
    
    // 网络错误
    if (error.code) {
      switch (error.code) {
        case 'ENOTFOUND':
          return new Error('无法解析Discord域名，请检查网络连接');
        case 'ECONNREFUSED':
          return new Error('连接被Discord服务器拒绝');
        case 'ETIMEDOUT':
        case 'ECONNRESET':
          return new Error('连接Discord超时，请检查网络连接');
        default:
          return new Error(`网络错误: ${error.code}`);
      }
    }
    
    // 超时错误
    if (error.message && error.message.includes('timeout')) {
      return new Error('请求Discord超时，请稍后重试');
    }
    
    // 默认错误
    return new Error(`发送消息“${title}”到Discord失败: ${error.message || error}`);
  }
  
  /**
   * 释放资源
   */
  dispose(): void {
    // Axios不需要显式关闭，但可以取消正在进行的请求
    // 这里可以添加取消逻辑
  }
}
