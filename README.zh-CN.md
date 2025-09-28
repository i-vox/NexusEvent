# NexusEvent

[English](README.md) | 中文

一个跨平台的消息推送SDK，支持向Discord、Slack、Telegram等多种平台发送通知消息。

## ✨ 特性

- 🚀 **跨平台支持**: 统一API支持多个消息平台
- 📱 **多语言SDK**: Flutter/Dart 和 JavaScript/TypeScript
- 🛡️ **安全可靠**: 严格的输入验证和错误处理
- 🔄 **自动重试**: 网络失败时的指数退避重试机制
- 📤 **广播消息**: 一次性发送到多个平台
- 📚 **完善文档**: 详细的API文档和使用示例

## 🚀 快速开始

### Flutter SDK

#### 安装

##### 方式一：从GitHub Releases下载（推荐）

从[GitHub Releases](https://github.com/i-vox/NexusEvent/releases)下载最新的Flutter包并解压到项目中：

```bash
# 下载并解压Flutter包
wget https://github.com/i-vox/NexusEvent/releases/download/v0.1.2/nexusevent_flutter-v0.1.2.tar.gz
tar -xzf nexusevent_flutter-v0.1.2.tar.gz -C your_project/packages/
```

然后在`pubspec.yaml`中添加：

```yaml
dependencies:
  nexusevent_flutter:
    path: ./packages/nexusevent_flutter
```

##### 方式二：从pub.dev安装

```yaml
dependencies:
  nexusevent_flutter: ^0.1.2
```

#### 使用
```dart
import 'package:nexusevent_flutter/nexusevent.dart';

// 添加Discord发送器
NexusEvent.instance.addDiscordSender(
  'main', 
  'https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN'
);

// 发送消息
final message = EventMessage(
  title: '新消息通知',
  content: '这是消息内容',
  url: 'https://example.com',
  author: '发送者',
  color: 0x33ccff,
);

await NexusEvent.instance.send('main', message);
```

### JavaScript SDK

#### 安装

首先配置npm使用GitHub Packages：

```bash
npm config set @i-vox:registry https://npm.pkg.github.com
```

然后安装包：

```bash
npm install @i-vox/nexusevent-js
```

#### 使用
```javascript
import { NexusEvent } from '@i-vox/nexusevent-js';

// 获取单例实例
const nexus = NexusEvent.getInstance();

// 添加Discord发送器
nexus.addDiscordSender(
  'main', 
  'https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN'
);

// 发送消息
const message = {
  title: '新消息通知',
  content: '这是消息内容',
  url: 'https://example.com',
  author: '发送者',
  color: 0x33ccff,
};

await nexus.send('main', message);
```

## 📦 支持的平台

| 平台 | 状态 | Flutter | JavaScript |
|------|------|---------|------------|
| Discord | ✅ 已支持 | ✅ | ✅ |
| Slack | 🔄 计划中 | 🔄 | 🔄 |
| Telegram | 🔄 计划中 | 🔄 | 🔄 |

## 🔧 高级功能

### 广播消息
```dart
// Flutter
final result = await NexusEvent.instance.broadcast(message);
print('成功: ${result.successful}, 失败: ${result.failed}');
```

```javascript
// JavaScript
const result = await nexus.broadcast(message);
console.log(`成功: ${result.successful}, 失败: ${result.failed}`);
```

### 配置验证
```dart
// Flutter
final isValid = await NexusEvent.instance.validateSender('main');
```

```javascript
// JavaScript
const isValid = await nexus.validateSender('main');
```

## 📖 文档

- [Flutter Demo](examples/flutter_demo/)
- [JavaScript Demo](examples/js-demo/)
- [安全策略](.github/SECURITY.md)
- [发布流程指南](RELEASE_PROCESS.md)

## 🛠️ 开发

### 项目结构
```
NexusEvent/
├── packages/
│   ├── nexusevent-core/       # 核心类型定义
│   ├── nexusevent_flutter/    # Flutter SDK
│   └── nexusevent-js/         # JavaScript SDK
├── examples/
│   ├── flutter_demo/          # Flutter示例
│   └── js-demo/              # JavaScript示例
└── README.md                  # 项目文档
```

### 本地开发

#### 克隆项目
```bash
git clone https://github.com/i-vox/NexusEvent.git
cd NexusEvent
```

#### Flutter开发
```bash
cd packages/nexusevent_flutter
flutter pub get
flutter test
```

#### JavaScript开发
```bash
cd packages/nexusevent-js
npm install
npm test
npm run build
```

## 🤝 贡献

欢迎贡献代码！请查看我们的[问题模板](.github/ISSUE_TEMPLATE/)了解如何报告错误和请求功能。

1. Fork 项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

## 📄 许可证

本项目采用 Apache License 2.0 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🔗 链接

- [GitHub仓库](https://github.com/i-vox/NexusEvent)
- [GitHub Packages - JavaScript SDK](https://github.com/i-vox/NexusEvent/packages)
- [GitHub Releases - Flutter SDK](https://github.com/i-vox/NexusEvent/releases)
- [问题反馈](https://github.com/i-vox/NexusEvent/issues)

---

如果这个项目对你有帮助，请给个 ⭐️ 支持一下！