# NexusEvent JavaScript SDK

一个用于JavaScript/TypeScript的跨平台消息推送SDK，支持向Discord、Slack、Telegram等多种平台发送通知消息。

[![npm version](https://badge.fury.io/js/@nexusevent%2Fnexusevent-js.svg)](https://www.npmjs.com/package/@nexusevent/nexusevent-js)
[![TypeScript](https://img.shields.io/badge/TypeScript-Ready-blue.svg)](https://www.typescriptlang.org/)

## 🚀 快速开始

### 安装

```bash
# npm
npm install @nexusevent/nexusevent-js

# yarn
yarn add @nexusevent/nexusevent-js

# pnpm
pnpm add @nexusevent/nexusevent-js
```

### 基本使用

```javascript
import { NexusEvent, Platform } from '@nexusevent/nexusevent-js';

// 获取SDK实例
const nexus = NexusEvent.getInstance();

// 添加Discord发送器
nexus.addDiscordSender('main_discord', 'https://discord.com/api/webhooks/YOUR_WEBHOOK_URL');

// 发送消息
const message = {
  title: '新视频点赞',
  content: '《JavaScript开发指南》',
  url: 'https://example.com/video/123',
  author: 'UP主名称',
  platform: Platform.DISCORD,
  timestamp: new Date(),
};

await nexus.send('main_discord', message);
```

### CommonJS使用

```javascript
const { NexusEvent, Platform } = require('@nexusevent/nexusevent-js');

// 使用方式相同
const nexus = NexusEvent.getInstance();
// ...
```

## 📚 详细用法

### 配置发送器

#### Discord发送器

```typescript
import { NexusEvent, DiscordSender, DiscordConfig, Platform } from '@nexusevent/nexusevent-js';

// 方法1：使用便捷方法
nexus.addDiscordSender('discord_main', webhookUrl);

// 方法2：手动创建
const config: DiscordConfig = {
  platform: Platform.DISCORD,
  config: { webhookUrl }
};
const sender = new DiscordSender(config);
nexus.addSender('discord_main', sender);
```

### 发送消息

#### 基本消息

```typescript
import { EventMessage, Platform } from '@nexusevent/nexusevent-js';

const message: EventMessage = {
  title: '简单通知',
  platform: Platform.DISCORD,
};

await nexus.send('discord_main', message);
```

#### 富文本消息

```typescript
const message: EventMessage = {
  title: '详细通知',
  content: '这里是详细内容',
  url: 'https://example.com',
  author: '消息作者',
  platform: Platform.DISCORD,
  color: 0x00ff00, // 绿色
  timestamp: new Date(),
};

await nexus.send('discord_main', message);
```

### 广播消息

```typescript
// 发送到所有已注册的发送器
await nexus.broadcast(message);

// 只发送到Discord平台
await nexus.broadcast(message, [Platform.DISCORD]);
```

### 验证配置

```typescript
// 验证单个发送器
const isValid = await nexus.validateSender('discord_main');
if (!isValid) {
  console.log('Discord配置无效');
}

// 验证所有发送器
const results = await nexus.validateAllSenders();
Object.entries(results).forEach(([name, isValid]) => {
  console.log(`${name}: ${isValid ? '有效' : '无效'}`);
});
```

## 🛠️ API参考

### EventMessage

消息对象的数据结构：

```typescript
interface EventMessage {
  title: string;                    // 必需：消息标题
  content?: string;                 // 可选：详细内容
  url?: string;                    // 可选：相关链接
  author?: string;                 // 可选：消息作者
  platform: Platform;             // 必需：目标平台
  color?: number;                  // 可选：消息颜色（十六进制）
  metadata?: Record<string, any>;  // 可选：附加数据
  timestamp?: Date;                // 可选：时间戳
}
```

### Platform

支持的平台类型：

```typescript
enum Platform {
  DISCORD = 'discord',      // Discord
  SLACK = 'slack',          // Slack (计划中)
  TELEGRAM = 'telegram',    // Telegram (计划中)
  WEBHOOK = 'webhook',      // 自定义Webhook (计划中)
  TEAMS = 'teams'           // Microsoft Teams (计划中)
}
```

### NexusEvent

SDK主入口类的主要方法：

```typescript
class NexusEvent {
  // 单例访问
  static getInstance(): NexusEvent;
  
  // 添加发送器
  addSender(name: string, sender: EventSender): void;
  addDiscordSender(name: string, webhookUrl: string): void;
  
  // 移除发送器
  removeSender(name: string): void;
  
  // 发送消息
  async send(senderName: string, message: EventMessage): Promise<void>;
  async broadcast(message: EventMessage, platforms?: Platform[]): Promise<void>;
  
  // 验证配置
  async validateSender(senderName: string): Promise<boolean>;
  async validateAllSenders(): Promise<Record<string, boolean>>;
  
  // 获取信息
  get senderNames(): string[];
  
  // 清理
  clear(): void;
}
```

## 💡 实用示例

### Node.js后端服务

```javascript
import { NexusEvent, Platform } from '@nexusevent/nexusevent-js';
import express from 'express';

const app = express();
const nexus = NexusEvent.getInstance();

// 初始化Discord发送器
nexus.addDiscordSender('alerts', process.env.DISCORD_WEBHOOK_URL);

// API端点：发送通知
app.post('/api/notify', async (req, res) => {
  try {
    const { title, content, url } = req.body;
    
    const message = {
      title,
      content,
      url,
      platform: Platform.DISCORD,
      timestamp: new Date(),
    };

    await nexus.send('alerts', message);
    res.json({ success: true });
  } catch (error) {
    console.error('发送通知失败:', error);
    res.status(500).json({ error: 'Failed to send notification' });
  }
});

app.listen(3000);
```

### 错误处理和重试

```typescript
async function sendWithRetry(message: EventMessage, maxRetries = 3) {
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      await nexus.send('discord_main', message);
      console.log('消息发送成功');
      return;
    } catch (error) {
      console.error(`发送失败 (尝试 ${attempt}/${maxRetries}):`, error);
      
      if (attempt === maxRetries) {
        throw new Error(`消息发送失败，已重试 ${maxRetries} 次`);
      }
      
      // 等待后重试
      await new Promise(resolve => setTimeout(resolve, 1000 * attempt));
    }
  }
}
```

### 环境配置

```typescript
// config.ts
export const config = {
  discord: {
    webhookUrl: process.env.DISCORD_WEBHOOK_URL || '',
    enabled: process.env.NODE_ENV === 'production'
  }
};

// notification.ts
import { config } from './config';

class NotificationService {
  private nexus = NexusEvent.getInstance();

  constructor() {
    if (config.discord.enabled && config.discord.webhookUrl) {
      this.nexus.addDiscordSender('main', config.discord.webhookUrl);
    }
  }

  async notify(message: Omit<EventMessage, 'platform'>) {
    if (!config.discord.enabled) {
      console.log('通知已禁用:', message.title);
      return;
    }

    const fullMessage = {
      ...message,
      platform: Platform.DISCORD,
      timestamp: new Date(),
    };

    await this.nexus.send('main', fullMessage);
  }
}

export const notificationService = new NotificationService();
```

### 浏览器中使用 (Webpack/Vite)

```typescript
// main.ts
import { NexusEvent, Platform } from '@nexusevent/nexusevent-js';

// 注意：在浏览器中需要处理CORS问题
const nexus = NexusEvent.getInstance();

// 只在开发环境使用（避免暴露Webhook URL）
if (process.env.NODE_ENV === 'development') {
  nexus.addDiscordSender('dev', process.env.VUE_APP_DISCORD_WEBHOOK);
}

// 发送客户端错误通知
window.addEventListener('error', async (event) => {
  if (process.env.NODE_ENV === 'development') {
    const message = {
      title: '客户端错误',
      content: `${event.error?.message || '未知错误'}`,
      platform: Platform.DISCORD,
      color: 0xff0000, // 红色
    };

    try {
      await nexus.send('dev', message);
    } catch (err) {
      console.error('发送错误通知失败:', err);
    }
  }
});
```

## 🔧 高级配置

### 自定义发送器

```typescript
import { EventSender, EventMessage, Platform } from '@nexusevent/nexusevent-js';
import axios from 'axios';

class CustomWebhookSender implements EventSender {
  public readonly platform = Platform.WEBHOOK;
  
  constructor(private webhookUrl: string) {}

  async send(message: EventMessage): Promise<void> {
    const payload = {
      text: message.title,
      content: message.content,
      url: message.url,
      timestamp: message.timestamp?.toISOString(),
    };

    await axios.post(this.webhookUrl, payload);
    console.log('自定义webhook消息发送成功');
  }

  async validateConfig(): Promise<boolean> {
    try {
      new URL(this.webhookUrl);
      return true;
    } catch {
      return false;
    }
  }
}

// 使用自定义发送器
const customSender = new CustomWebhookSender('https://your-webhook-url.com');
nexus.addSender('custom', customSender);
```

### 批量操作

```typescript
// 批量添加发送器
const senders = [
  { name: 'discord1', url: 'https://discord.com/api/webhooks/1/...' },
  { name: 'discord2', url: 'https://discord.com/api/webhooks/2/...' },
];

senders.forEach(({ name, url }) => {
  nexus.addDiscordSender(name, url);
});

// 批量验证
const results = await nexus.validateAllSenders();
const invalidSenders = Object.entries(results)
  .filter(([, isValid]) => !isValid)
  .map(([name]) => name);

if (invalidSenders.length > 0) {
  console.warn('无效的发送器:', invalidSenders);
}
```

## 🐛 故障排除

### 常见问题

1. **网络请求失败**
   ```typescript
   // 添加请求超时和重试
   import axios from 'axios';
   
   const sender = new DiscordSender(config);
   // Discord发送器内部会处理网络错误
   ```

2. **CORS问题（浏览器环境）**
   - Discord Webhook支持CORS，但建议通过后端代理
   - 或使用服务器端渲染

3. **TypeScript类型错误**
   ```typescript
   // 确保正确导入类型
   import type { EventMessage, Platform } from '@nexusevent/nexusevent-js';
   ```

### 调试模式

```typescript
// 启用详细日志
const message = {
  title: 'Debug Test',
  platform: Platform.DISCORD,
};

try {
  await nexus.send('discord_main', message);
  console.log('✅ 发送成功');
} catch (error) {
  console.error('❌ 发送失败:', error);
  
  // 检查发送器配置
  const isValid = await nexus.validateSender('discord_main');
  console.log('配置有效性:', isValid);
}
```

## 📄 许可证

Apache License 2.0 - 详见 [LICENSE](../../LICENSE) 文件。

Apache 2.0 比 MIT 更严格，包含专利保护条款，为贡献者和用户提供更好的法律保护。

## 🤝 贡献

欢迎提交Issue和Pull Request！请查看我们的[贡献指南](../../docs/CONTRIBUTING.md)。
