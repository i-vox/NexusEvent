# NexusEvent

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Flutter](https://img.shields.io/badge/Flutter-SDK-blue.svg)](https://flutter.dev)
[![TypeScript](https://img.shields.io/badge/TypeScript-Ready-blue.svg)](https://www.typescriptlang.org/)
[![CI](https://github.com/i-vox/NexusEvent/actions/workflows/ci.yml/badge.svg)](https://github.com/i-vox/NexusEvent/actions)

**🌍 Read this in other languages: [中文](README.zh-CN.md)**

A cross-platform messaging SDK that supports sending notification messages to multiple platforms like Discord, Slack, Telegram, and more.

## 🎯 Project Goals

- **Unified API**: Provide a consistent interface for different messaging platforms
- **Multi-language Support**: Support Flutter, JavaScript, Python, Go, and other programming languages
- **Easily Extensible**: Simple plugin architecture for adding new platform support
- **Developer Friendly**: Clear documentation and examples for quick integration

## 🏗️ Project Structure

```
NexusEvent/
├── packages/                    # SDK packages for different languages
│   ├── nexusevent-core/         # Core type definitions
│   ├── nexusevent_flutter/      # Flutter/Dart SDK
│   └── nexusevent-js/           # JavaScript/TypeScript SDK
├── examples/                    # Usage examples
│   ├── flutter_demo/            # Flutter demo app
│   └── js-demo/                 # JavaScript demo script
└── README.md                    # Project documentation
```

## 🚀 Quick Start

### Flutter SDK

```dart
import 'package:nexusevent_flutter/nexusevent.dart';

// Add Discord sender
NexusEvent.instance.addDiscordSender(
  'main_discord', 
  'https://discord.com/api/webhooks/YOUR_WEBHOOK_URL'
);

// Send message
final message = EventMessage(
  title: 'New Video Liked',
  content: 'Flutter Development Guide',
  url: 'https://example.com/video/123',
  author: 'Channel Name',
);

await NexusEvent.instance.send('main_discord', message);
```

### JavaScript SDK

```javascript
import { NexusEvent, Platform } from '@nexusevent/nexusevent-js';

// Get SDK instance
const nexus = NexusEvent.getInstance();

// Add Discord sender
nexus.addDiscordSender('main_discord', 'https://discord.com/api/webhooks/YOUR_WEBHOOK_URL');

// Send message
const message = {
  title: 'New Video Liked',
  content: 'JavaScript Development Guide',
  url: 'https://example.com/video/123',
  author: 'Channel Name',
  timestamp: new Date(),
};

await nexus.send('main_discord', message);
```

## 📦 Supported Platforms

| Platform | Status | Flutter | JavaScript | Python | Go |
|----------|--------|---------|------------|--------|----|  
| Discord | ✅ Supported | ✅ | ✅ | 🚧 | 🚧 |
| Slack | 🚧 In Development | 🚧 | 🚧 | 🚧 | 🚧 |
| Telegram | 📋 Planned | 📋 | 📋 | 📋 | 📋 |
| Teams | 📋 Planned | 📋 | 📋 | 📋 | 📋 |
| Custom Webhook | 📋 Planned | 📋 | 📋 | 📋 | 📋 |

## 🛠️ Development Status

- ✅ Core architecture design completed
- ✅ Flutter SDK Discord support
- ✅ JavaScript SDK Discord support  
- ✅ Basic demo applications
- 🚧 JavaScript SDK in development
- 📋 Other language SDKs planned

## 📖 Documentation

- [Flutter Demo](examples/flutter_demo/)
- [JavaScript Demo](examples/js-demo/)
- [Security Policy](.github/SECURITY.md)

## 🚀 Installation

### Flutter

Add to your `pubspec.yaml`:

```yaml
dependencies:
  nexusevent_flutter: ^0.1.1
```

### JavaScript/TypeScript

```bash
npm install @nexusevent/nexusevent-js
```

## 🔧 Features

### Core Features
- 🎯 **Unified API Design**: Consistent interface across different languages
- 🛡️ **Error Handling**: Comprehensive exception handling mechanism
- 🔍 **Configuration Validation**: Automatic validation of webhook URLs and configurations
- 📤 **Broadcast Functionality**: Send messages to multiple platforms simultaneously
- 🎨 **Rich Messages**: Support for embedded messages, colors, authors, etc.

### Flutter SDK Features
- 📱 **Native Flutter Integration**: Built specifically for Flutter/Dart
- 🔄 **Backward Compatibility**: Maintains compatibility with existing APIs
- 🧪 **Comprehensive Testing**: Unit tests with 80%+ coverage

### JavaScript SDK Features
- 📦 **TypeScript Support**: Complete type definitions
- 🌐 **Multiple Module Formats**: Supports both CommonJS and ES Modules
- 🎯 **Singleton Pattern**: Convenient SDK instance management

## 💡 Usage Examples

### Video Like Notification

```dart
// Flutter
Future<void> sendLikeNotification({
  required String videoTitle,
  required String videoUrl, 
  required String author,
}) async {
  final message = EventMessage(
    title: 'New Video Liked 👍',
    content: '「$videoTitle」',
    url: videoUrl,
    author: author,
    color: 0x33ccff,
    timestamp: DateTime.now(),
  );

  await NexusEvent.instance.send('discord_main', message);
}
```

```javascript
// JavaScript
async function sendLikeNotification({ videoTitle, videoUrl, author }) {
  const message = {
    title: 'New Video Liked 👍',
    content: `「${videoTitle}」`,
    url: videoUrl,
    author: author,
    color: 0x33ccff,
    timestamp: new Date(),
  };

  await nexus.send('discord_main', message);
}
```

### Error Handling

```dart
// Flutter
try {
  await NexusEvent.instance.send('discord_main', message);
  print('Message sent successfully');
} catch (e) {
  print('Failed to send: $e');
  // Handle error, e.g., retry or use backup sender
}
```

```javascript
// JavaScript
try {
  await nexus.send('discord_main', message);
  console.log('Message sent successfully');
} catch (error) {
  console.error('Failed to send:', error);
  // Handle error, e.g., retry or use backup sender
}
```

## 🤝 Contributing

We welcome all forms of contributions! Please see our [Issue Templates](.github/ISSUE_TEMPLATE/) for bug reports and feature requests.

### Development Setup

1. Clone the repository
```bash
git clone https://github.com/your-org/NexusEvent.git
cd NexusEvent
```

2. Flutter SDK Development
```bash
cd packages/nexusevent_flutter
flutter pub get
flutter analyze
flutter test
```

3. JavaScript SDK Development
```bash
cd packages/nexusevent-js
npm install
npm run build
npm test
```

## 📄 License

This project is licensed under the [Apache License 2.0](LICENSE).

Apache 2.0 is more restrictive than MIT and includes patent protection clauses, providing better legal protection for both contributors and users.

## 🌟 Star History

If you find this project useful, please consider giving it a star! ⭐

## 🔗 Links

- **Documentation**: [Full Documentation](docs/)
- **Issues**: [GitHub Issues](https://github.com/your-org/NexusEvent/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-org/NexusEvent/discussions)
- **Flutter Package**: [pub.dev](https://pub.dev/packages/nexusevent_flutter)
- **JavaScript Package**: [npm](https://www.npmjs.com/package/@nexusevent/nexusevent-js)