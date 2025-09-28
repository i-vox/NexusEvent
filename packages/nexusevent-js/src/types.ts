/**
 * 支持的平台类型
 */
export enum Platform {
  DISCORD = 'discord',
  SLACK = 'slack',
  TELEGRAM = 'telegram',
  WEBHOOK = 'webhook',
  TEAMS = 'teams'
}

/**
 * 事件消息的数据结构
 */
export interface EventMessage {
  /** 消息标题 */
  title: string;
  
  /** 消息内容 */
  content?: string;
  
  /** 相关URL链接 */
  url?: string;
  
  /** 消息作者 */
  author?: string;
  
  
  /** 消息颜色（十六进制），如 0x33ccff */
  color?: number;
  
  /** 附加的元数据 */
  metadata?: Record<string, any>;
  
  /** 时间戳 */
  timestamp?: Date;
}

/**
 * 事件发送器的抽象接口
 */
export interface EventSender {
  /** 平台标识 */
  readonly platform: Platform;
  
  /** 
   * 发送事件消息
   * @param message 要发送的消息
   */
  send(message: EventMessage): Promise<void>;
  
  /** 
   * 验证配置是否有效
   */
  validateConfig(): Promise<boolean>;
}

/**
 * 发送器的配置接口
 */
export interface SenderConfig {
  /** 平台类型 */
  platform: Platform;
  
  /** 配置参数，不同平台有不同的参数 */
  config: Record<string, any>;
}

/**
 * Discord平台的配置
 */
export interface DiscordConfig extends SenderConfig {
  platform: Platform.DISCORD;
  config: {
    webhookUrl: string;
  };
}

/**
 * Slack平台的配置
 */
export interface SlackConfig extends SenderConfig {
  platform: Platform.SLACK;
  config: {
    webhookUrl: string;
    channel?: string;
  };
}

/**
 * 通用Webhook的配置
 */
export interface WebhookConfig extends SenderConfig {
  platform: Platform.WEBHOOK;
  config: {
    url: string;
    headers?: Record<string, string>;
    method?: 'POST' | 'PUT';
  };
}

/**
 * 广播发送结果
 */
export interface BroadcastResult {
  /** 总发送器数量 */
  total: number;
  
  /** 成功发送的数量 */
  successful: number;
  
  /** 失败发送的数量 */
  failed: number;
  
  /** 各发送器的错误信息 */
  errors: Record<string, Error>;
}
